import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../domain/entities/book.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';

/// Discover Page - Browse books (Map + List view)
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isMapView = false;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  Timer? _searchDebounce;
  String _query = '';
  late BookBloc _bookBloc;
  String? _currentUserId;
  late final GetUserByIdUseCase _getUserByIdUseCase;
  final Map<String, Future<User?>> _userCache = {};
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  _DiscoverFilters _filters = const _DiscoverFilters();

  /// Last successfully loaded list, kept on screen while a refresh runs.
  List<Book>? _books;

  static const double _nearbyRadiusKm = AppConstants.defaultSearchRadius;
  static const double _pinnedHeaderExtent = 124;

  @override
  void initState() {
    super.initState();
    _bookBloc = getIt<BookBloc>()..add(const LoadAllBooks());
    _currentUserId = getIt<FirebaseService>().auth.currentUser?.uid;
    _getUserByIdUseCase = getIt<GetUserByIdUseCase>();
    _primeLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    _bookBloc.close();
    super.dispose();
  }

  /// Picks up the position without prompting, when access was already granted,
  /// so distances show up from the first frame.
  Future<void> _primeLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
      final position =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
            ),
          );
      if (mounted && _currentPosition == null) {
        setState(() => _currentPosition = position);
      }
    } catch (_) {
      // Distances are optional; the list works without them.
    }
  }

  Future<void> _refresh() async {
    _bookBloc.add(const LoadAllBooks());
    await _bookBloc.stream
        .firstWhere((state) => state is BookLoaded || state is BookError)
        .timeout(const Duration(seconds: 12), onTimeout: () => _bookBloc.state);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return BlocProvider.value(
      value: _bookBloc,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<BookBloc, BookState>(
            listener: (context, state) {
              if (state is BookLoaded) {
                _books = state.books;
              } else if (state is BookAdded) {
                context.read<BookBloc>().add(const LoadAllBooks());
              }
            },
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: AppMotion.medium,
                child: _isMapView
                    ? KeyedSubtree(
                        key: const ValueKey('map'),
                        child: _buildMapLayout(state),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('list'),
                        child: _buildListLayout(state),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header, search and quick filters
  // ---------------------------------------------------------------------------

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(
                  _currentPosition != null
                      ? 'Books near you'
                      : 'Books in the circle',
                  color: context.colors.primary,
                ),
                const SizedBox(height: 2),
                Text(
                  'Find your next read',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.headlineMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _ViewToggle(
            isMapView: _isMapView,
            onChanged: (value) => setState(() => _isMapView = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final colors = context.colors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      hintText: 'Title, author or genre',
                      contentPadding: EdgeInsets.zero,
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border.copyWith(
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.6,
                        ),
                      ),
                      prefixIcon: const Icon(LucideIcons.search, size: 20),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(LucideIcons.x, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleIconButton(
                icon: LucideIcons.slidersHorizontal,
                tooltip: 'Filters',
                size: 50,
                badge: _filters.advancedCount > 0,
                onPressed: _showFilterSheet,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            children: [
              _FilterPill(
                label: 'All',
                selected: _filters.mode == null,
                onTap: () => _setFilters(_filters.copyWith(mode: null)),
              ),
              _FilterPill(
                label: 'Free',
                icon: BookMode.donate.icon,
                tone: AppTone.donate,
                selected: _filters.mode == BookMode.donate,
                onTap: () => _toggleMode(BookMode.donate),
              ),
              _FilterPill(
                label: 'Swap',
                icon: BookMode.exchange.icon,
                tone: AppTone.exchange,
                selected: _filters.mode == BookMode.exchange,
                onTap: () => _toggleMode(BookMode.exchange),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 9, 10, 9),
                child: VerticalDivider(
                  width: 1,
                  color: context.colors.outlineVariant,
                ),
              ),
              _FilterPill(
                label: 'Within ${_nearbyRadiusKm.round()} km',
                icon: LucideIcons.mapPin,
                loading: _isFetchingLocation,
                selected: _filters.nearbyOnly,
                onTap: _isFetchingLocation
                    ? null
                    : () => _toggleNearby(!_filters.nearbyOnly),
              ),
              _FilterPill(
                label: 'Available now',
                icon: LucideIcons.circleCheck,
                selected: _filters.onlyAvailable,
                onTap: () => _setFilters(
                  _filters.copyWith(onlyAvailable: !_filters.onlyAvailable),
                ),
              ),
              if (_filters.genre != null)
                _FilterPill(
                  label: _filters.genre!,
                  selected: true,
                  removable: true,
                  onTap: () => _setFilters(_filters.copyWith(genre: null)),
                ),
              if (_filters.minCondition != null)
                _FilterPill(
                  label:
                      '${AppConstants.bookConditions[_filters.minCondition!]} or better',
                  selected: true,
                  removable: true,
                  onTap: () =>
                      _setFilters(_filters.copyWith(minCondition: null)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _setFilters(_DiscoverFilters filters) {
    setState(() => _filters = filters);
  }

  void _toggleMode(BookMode mode) {
    _setFilters(_filters.copyWith(mode: _filters.mode == mode ? null : mode));
  }

  void _clearAll() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _filters = const _DiscoverFilters();
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (!mounted) return;

    setState(() {}); // Update suffix icon immediately.
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _query = value.trim().toLowerCase());
    });
  }

  Future<void> _toggleNearby(bool selected) async {
    if (selected) {
      final ready = await _ensureLocationReady();
      if (!ready) {
        return;
      }
    }

    if (!mounted) return;
    _setFilters(_filters.copyWith(nearbyOnly: selected));
  }

  Future<void> _showFilterSheet() async {
    final books = _withoutOwn(_books ?? const []);
    final result = await showAppSheet<_DiscoverFilters>(
      context,
      builder: (_) => _FilterSheet(
        initial: _filters,
        radiusKm: _nearbyRadiusKm.round(),
        countFor: (draft) => _applyFilters(books, draft).length,
        ensureLocation: _ensureLocationReady,
      ),
    );

    if (!mounted || result == null) return;
    _setFilters(result);
  }

  // ---------------------------------------------------------------------------
  // List view
  // ---------------------------------------------------------------------------

  Widget _buildListLayout(BookState state) {
    final loaded = _books;
    final List<Widget> content;

    if (loaded == null) {
      if (state is BookError) {
        content = [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: 'Could not load books',
              message: state.message,
              onRetry: () => _bookBloc.add(const LoadAllBooks()),
            ),
          ),
        ];
      } else {
        content = [
          const SliverFillRemaining(
            child: BookListSkeleton(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                AppSpacing.navClearance,
              ),
            ),
          ),
        ];
      }
    } else {
      final others = _withoutOwn(loaded);
      final books = _applyAllFilters(loaded);

      if (others.isEmpty) {
        content = [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _bottomCleared(_buildEmptyState()),
          ),
        ];
      } else if (books.isEmpty) {
        content = [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _bottomCleared(_buildNoResults()),
          ),
        ];
      } else {
        content = [
          SliverToBoxAdapter(child: _buildResultSummary(books.length)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              AppSpacing.navClearance,
            ),
            sliver: SliverList.separated(
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _buildBookCard(books[index]),
            ),
          ),
        ];
      }
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      edgeOffset: _pinnedHeaderExtent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(child: _buildTitleRow()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              extent: _pinnedHeaderExtent,
              child: _buildSearchAndFilters(),
            ),
          ),
          ...content,
        ],
      ),
    );
  }

  /// Keeps centred states visually centred above the floating nav bar.
  Widget _bottomCleared(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.navClearance - 24),
      child: child,
    );
  }

  Widget _buildResultSummary(int count) {
    final sortedByDistance = _currentPosition != null;
    final hasFilters = _filters.activeCount > 0 || _query.isNotEmpty;
    final label = count == 1 ? '1 book' : '$count books';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: sortedByDistance
                          ? '  ·  nearest first'
                          : '  ·  from readers around you',
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            if (hasFilters)
              TextButton(
                onPressed: _clearAll,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Clear filters'),
              )
            else
              const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: LucideIcons.bookOpen,
      title: 'No books here yet',
      message:
          'Be the first to put a book into the circle. Someone nearby is '
          'probably looking for it.',
      actionLabel: 'Share a book',
      actionIcon: LucideIcons.plus,
      onAction: () => context.push(RoutePaths.addBook),
      secondaryLabel: 'Refresh',
      onSecondary: () => _bookBloc.add(const LoadAllBooks()),
    );
  }

  Widget _buildNoResults() {
    return AppEmptyState(
      icon: LucideIcons.searchX,
      tone: AppTone.neutral,
      title: 'No books match',
      message: _filters.nearbyOnly
          ? 'Nothing within ${_nearbyRadiusKm.round()} km right now. Try a '
                'wider search or fewer filters.'
          : 'Try a different title or author, or loosen the filters.',
      actionLabel: 'Clear filters',
      actionIcon: LucideIcons.filterX,
      onAction: _clearAll,
    );
  }

  Widget _buildBookCard(Book book) {
    final distance = _distanceLabel(book);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => context.push('/book/${book.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            imageUrl: book.coverUrl,
            title: book.title,
            width: 78,
            heroTag: 'discover_book_${book.id}',
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 117),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: StatusPill.mode(book.mode, dense: true)),
                      if (book.status != BookStatus.available) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: StatusPill.book(book.status, dense: true),
                        ),
                      ],
                      const Spacer(),
                      if (distance != null)
                        MetaItem(icon: LucideIcons.mapPin, label: distance),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConditionMeter(condition: book.condition),
                  const SizedBox(height: AppSpacing.md),
                  _buildOwnerSummary(book.ownerId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSummary(String ownerId) {
    final future = _userCache[ownerId] ??= _fetchUser(ownerId);

    return FutureBuilder<User?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              Skeleton(width: 22, height: 22, radius: AppRadius.pill),
              SizedBox(width: AppSpacing.sm),
              Skeleton(width: 96, height: 10),
            ],
          );
        }

        final user = snapshot.data;
        return Row(
          children: [
            UserAvatar(
              photoUrl: user?.photoUrl,
              name: user?.name,
              radius: 11,
              verified: user?.verifiedBadge == true,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                user?.name ?? 'A reader',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (user != null && user.ratingAvg > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              RatingBadge(rating: user.ratingAvg),
            ],
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Map view
  // ---------------------------------------------------------------------------

  Widget _buildMapLayout(BookState state) {
    final loaded = _books;

    Widget body;
    if (loaded == null) {
      body = state is BookError
          ? AppErrorState(
              title: 'Could not load books',
              message: state.message,
              onRetry: () => _bookBloc.add(const LoadAllBooks()),
            )
          : const AppLoading(message: 'Finding books around you');
    } else {
      body = _buildMap(_applyAllFilters(loaded));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleRow(),
        _buildSearchAndFilters(),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
            child: ColoredBox(
              color: context.colors.surfaceContainer,
              child: body,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(List<Book> books) {
    final position = _currentPosition;
    final LatLng center;
    if (position != null) {
      center = LatLng(position.latitude, position.longitude);
    } else if (books.isNotEmpty) {
      center = LatLng(
        books.first.location.latitude,
        books.first.location.longitude,
      );
    } else {
      center = const LatLng(23.8103, 90.4125); // Dhaka
    }

    final points = [
      if (position != null) LatLng(position.latitude, position.longitude),
      for (final book in books)
        LatLng(book.location.latitude, book.location.longitude),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13.0,
            // Open wide enough to show every match, however far it is.
            initialCameraFit: points.length > 1
                ? CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.fromLTRB(56, 88, 56, 150),
                    maxZoom: 14,
                  )
                : null,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.boichokro',
            ),
            if (position != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(position.latitude, position.longitude),
                    width: 44,
                    height: 44,
                    child: const _MyLocationDot(),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final book in books)
                  Marker(
                    point: LatLng(
                      book.location.latitude,
                      book.location.longitude,
                    ),
                    width: 132,
                    height: 78,
                    alignment: Alignment.topCenter,
                    child: _BookPin(
                      book: book,
                      onTap: () => _showBookPreview(book),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          top: AppSpacing.lg,
          left: AppSpacing.lg,
          child: _MapChip(
            label: books.isEmpty
                ? 'No books match here'
                : books.length == 1
                ? '1 book on the map'
                : '${books.length} books on the map',
          ),
        ),
        Positioned(
          top: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Column(
            children: [
              CircleIconButton(
                icon: LucideIcons.locateFixed,
                tooltip: 'My location',
                onPressed: _isFetchingLocation ? null : _centerOnMe,
              ),
              const SizedBox(height: AppSpacing.sm),
              CircleIconButton(
                icon: LucideIcons.refreshCcw,
                tooltip: 'Refresh',
                onPressed: () => _bookBloc.add(const LoadAllBooks()),
              ),
            ],
          ),
        ),
        if (books.isEmpty && (_filters.activeCount > 0 || _query.isNotEmpty))
          Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            bottom: AppSpacing.navClearance,
            child: AppCard(
              elevated: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nothing matches your search and filters.',
                      style: context.text.bodyMedium,
                    ),
                  ),
                  TextButton(onPressed: _clearAll, child: const Text('Clear')),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _centerOnMe() async {
    if (_currentPosition == null) {
      await _ensureLocationReady();
    }
    final position = _currentPosition;
    if (position == null || !mounted || !_isMapView) return;
    setState(() {}); // Show the location dot if it just became available.
    _mapController.move(LatLng(position.latitude, position.longitude), 14);
  }

  void _showBookPreview(Book book) {
    final distance = _distanceLabel(book);

    showAppSheet<void>(
      context,
      builder: (sheetContext) => SheetScaffold(
        title: 'On the map',
        subtitle: book.location.address,
        footer: FilledButton.icon(
          onPressed: () {
            Navigator.pop(sheetContext);
            context.push('/book/${book.id}');
          },
          icon: const Icon(LucideIcons.bookOpen, size: 18),
          label: const Text('View this book'),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(imageUrl: book.coverUrl, title: book.title, width: 88),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      StatusPill.mode(book.mode, dense: true),
                      if (book.status != BookStatus.available)
                        StatusPill.book(book.status, dense: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    book.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: sheetContext.text.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sheetContext.text.bodySmall?.copyWith(
                      color: sheetContext.colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConditionMeter(condition: book.condition),
                  if (distance != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    MetaItem(icon: LucideIcons.mapPin, label: '$distance away'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------

  Future<bool> _ensureLocationReady() async {
    if (_currentPosition != null) {
      return true;
    }
    if (_isFetchingLocation) {
      return false;
    }

    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showAppSnack(
            context,
            'Turn on location services to see nearby books.',
            tone: AppTone.warning,
          );
        }
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Prominent Disclosure for Google Play Policy Compliance
        if (mounted) {
          final bool? shouldRequest = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                icon: Icon(
                  LucideIcons.mapPin,
                  color: dialogContext.colors.primary,
                ),
                title: const Text('Location Access Required'),
                content: const Text(
                  'Boichokro needs your location to find and display nearby books available for exchange. '
                  'Your location is only used locally to calculate distance and is not continuously tracked.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Deny'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              );
            },
          );

          if (shouldRequest != true) {
            return false;
          }
        }

        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          showAppSnack(
            context,
            'Location permission is needed to show books near you.',
            tone: AppTone.warning,
            action: permission == LocationPermission.deniedForever
                ? SnackBarAction(
                    label: 'Settings',
                    onPressed: Geolocator.openAppSettings,
                  )
                : null,
          );
        }
        return false;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return true;
    } catch (error) {
      if (mounted) {
        showAppSnack(
          context,
          'Could not determine your location. Please try again.',
          tone: AppTone.danger,
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      } else {
        _isFetchingLocation = false;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  List<Book> _withoutOwn(List<Book> books) {
    return books
        .where(
          (book) => _currentUserId == null || book.ownerId != _currentUserId,
        )
        .toList();
  }

  List<Book> _applyAllFilters(List<Book> books) {
    final refined = _applyFilters(
      _applySearchFilter(_withoutOwn(books)),
      _filters,
    );

    if (_currentPosition != null) {
      refined.sort((a, b) {
        final aDistance = _computeDistanceMeters(a) ?? double.infinity;
        final bDistance = _computeDistanceMeters(b) ?? double.infinity;
        return aDistance.compareTo(bDistance);
      });
    }

    return refined;
  }

  List<Book> _applySearchFilter(List<Book> books) {
    final query = _query;
    if (query.isEmpty) {
      return List<Book>.from(books);
    }

    return books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.genres.any((genre) => genre.toLowerCase().contains(query)),
        )
        .toList();
  }

  List<Book> _applyFilters(List<Book> books, _DiscoverFilters filters) {
    return books.where((book) {
      if (filters.genre != null &&
          !book.genres.any(
            (g) => g.toLowerCase() == filters.genre!.toLowerCase(),
          )) {
        return false;
      }

      // Condition index 0 is the best ("Like New"), so "X or better" keeps
      // books whose index is at most X.
      if (filters.minCondition != null &&
          book.condition > filters.minCondition!) {
        return false;
      }

      if (filters.mode != null && book.mode != filters.mode) {
        return false;
      }

      if (filters.onlyAvailable && book.status != BookStatus.available) {
        return false;
      }

      if (filters.nearbyOnly) {
        if (_currentPosition == null) {
          return false;
        }
        if (!_isWithinRadius(book)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _isWithinRadius(Book book) {
    final distance = _computeDistanceMeters(book);
    if (distance == null) {
      return false;
    }
    return distance <= _nearbyRadiusKm * 1000;
  }

  double? _computeDistanceMeters(Book book) {
    final position = _currentPosition;
    if (position == null) {
      return null;
    }

    try {
      return Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        book.location.latitude,
        book.location.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  /// Null when the reader's position is unknown.
  String? _distanceLabel(Book book) {
    final distance = _computeDistanceMeters(book);
    if (distance == null) {
      return null;
    }

    if (distance < 1000) {
      return '${distance.round()} m';
    }

    final km = distance / 1000;
    return km >= 10 ? '${km.round()} km' : '${km.toStringAsFixed(1)} km';
  }

  Future<User?> _fetchUser(String userId) async {
    final result = await _getUserByIdUseCase(GetUserByIdParams(userId));
    return result.fold((_) => null, (user) => user);
  }
}

class _DiscoverFilters {
  const _DiscoverFilters({
    this.genre,
    this.minCondition,
    this.mode,
    this.onlyAvailable = false,
    this.nearbyOnly = false,
  });

  final String? genre;
  final int? minCondition;
  final BookMode? mode;
  final bool onlyAvailable;
  final bool nearbyOnly;

  /// Filters that only the sheet exposes; drives the dot on the filter button.
  int get advancedCount =>
      (genre != null ? 1 : 0) + (minCondition != null ? 1 : 0);

  int get activeCount =>
      advancedCount +
      (mode != null ? 1 : 0) +
      (onlyAvailable ? 1 : 0) +
      (nearbyOnly ? 1 : 0);

  static const Object _sentinel = Object();

  _DiscoverFilters copyWith({
    Object? genre = _sentinel,
    Object? minCondition = _sentinel,
    Object? mode = _sentinel,
    bool? onlyAvailable,
    bool? nearbyOnly,
  }) {
    return _DiscoverFilters(
      genre: identical(genre, _sentinel) ? this.genre : genre as String?,
      minCondition: identical(minCondition, _sentinel)
          ? this.minCondition
          : minCondition as int?,
      mode: identical(mode, _sentinel) ? this.mode : mode as BookMode?,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
    );
  }
}

/// Keeps search and quick filters reachable while the list scrolls.
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent
                ? context.colors.outlineVariant
                : Colors.transparent,
          ),
        ),
      ),
      child: Align(alignment: Alignment.topCenter, child: child),
    );
  }

  @override
  bool shouldRebuild(_PinnedHeaderDelegate oldDelegate) => true;
}

/// List / map switch.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isMapView, required this.onChanged});

  final bool isMapView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment({
      required IconData icon,
      required String tooltip,
      required bool selected,
      required bool value,
    }) {
      return Tooltip(
        message: tooltip,
        child: Material(
          color: selected ? context.colors.primary : Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: selected ? null : () => onChanged(value),
            child: SizedBox(
              width: 44,
              height: 38,
              child: Icon(
                icon,
                size: 18,
                color: selected
                    ? context.colors.onPrimary
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            icon: LucideIcons.list,
            tooltip: 'List view',
            selected: !isMapView,
            value: false,
          ),
          segment(
            icon: LucideIcons.map,
            tooltip: 'Map view',
            selected: isMapView,
            value: true,
          ),
        ],
      ),
    );
  }
}

/// Quick filter pill. Selected pills take the colour of their [tone].
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tone = AppTone.primary,
    this.loading = false,
    this.removable = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final AppTone tone;
  final bool loading;
  final bool removable;

  @override
  Widget build(BuildContext context) {
    final toneColors = context.tone(tone);
    final foreground = selected
        ? toneColors.foreground
        : context.colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected ? toneColors.background : context.colors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? toneColors.solid : context.colors.outlineVariant,
            width: selected ? 1.2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading) ...[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: selected ? toneColors.foreground : toneColors.solid,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: foreground,
                    fontSize: 13,
                  ),
                ),
                if (removable) ...[
                  const SizedBox(width: 6),
                  Icon(LucideIcons.x, size: 14, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Map marker for a book: a pin in the mode colour with the title beneath.
class _BookPin extends StatelessWidget {
  const _BookPin({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = context.tone(book.mode.tone);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tone.solid,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.surface, width: 2.5),
              boxShadow: context.softShadow,
            ),
            child: Icon(
              book.mode.icon,
              color: context.colors.surface,
              size: 18,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 132),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: context.colors.outlineVariant),
            ),
            child: Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.onSurface,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Container(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.surface, width: 3),
        ),
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Text(
        label,
        style: context.text.labelMedium?.copyWith(
          color: context.colors.onSurface,
        ),
      ),
    );
  }
}

/// All filters in one place. Edits a draft and reports how many books match
/// before the reader commits.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initial,
    required this.radiusKm,
    required this.countFor,
    required this.ensureLocation,
  });

  final _DiscoverFilters initial;
  final int radiusKm;
  final int Function(_DiscoverFilters filters) countFor;
  final Future<bool> Function() ensureLocation;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _DiscoverFilters _draft = widget.initial;
  bool _locating = false;

  void _update(_DiscoverFilters filters) => setState(() => _draft = filters);

  Future<void> _setNearby(bool value) async {
    if (!value) {
      _update(_draft.copyWith(nearbyOnly: false));
      return;
    }
    setState(() => _locating = true);
    final ready = await widget.ensureLocation();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (ready) _draft = _draft.copyWith(nearbyOnly: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.countFor(_draft);

    return SheetScaffold(
      title: 'Filters',
      subtitle: 'Narrow down the books you see',
      trailing: TextButton(
        onPressed: _draft.activeCount == 0
            ? null
            : () => _update(const _DiscoverFilters()),
        child: const Text('Reset'),
      ),
      footer: FilledButton(
        onPressed: () => Navigator.of(context).pop(_draft),
        child: Text(
          count == 0
              ? 'No books match'
              : count == 1
              ? 'Show 1 book'
              : 'Show $count books',
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('How it is shared'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            runSpacing: AppSpacing.sm,
            children: [
              _pill(
                label: 'All',
                selected: _draft.mode == null,
                onTap: () => _update(_draft.copyWith(mode: null)),
              ),
              _pill(
                label: 'Free to take',
                icon: BookMode.donate.icon,
                tone: AppTone.donate,
                selected: _draft.mode == BookMode.donate,
                onTap: () => _update(_draft.copyWith(mode: BookMode.donate)),
              ),
              _pill(
                label: 'Swap',
                icon: BookMode.exchange.icon,
                tone: AppTone.exchange,
                selected: _draft.mode == BookMode.exchange,
                onTap: () => _update(_draft.copyWith(mode: BookMode.exchange)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Eyebrow('Genre'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            runSpacing: AppSpacing.sm,
            children: [
              _pill(
                label: 'Any genre',
                selected: _draft.genre == null,
                onTap: () => _update(_draft.copyWith(genre: null)),
              ),
              for (final genre in AppConstants.bookGenres)
                _pill(
                  label: genre,
                  selected: _draft.genre == genre,
                  onTap: () => _update(
                    _draft.copyWith(
                      genre: _draft.genre == genre ? null : genre,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Eyebrow('Condition'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            runSpacing: AppSpacing.sm,
            children: [
              _pill(
                label: 'Any condition',
                selected: _draft.minCondition == null,
                onTap: () => _update(_draft.copyWith(minCondition: null)),
              ),
              // The last step ("Worn or better") is the same as "Any".
              for (
                int index = 0;
                index < AppConstants.bookConditions.length - 1;
                index++
              )
                _pill(
                  label: index == 0
                      ? AppConstants.bookConditions[index]
                      : '${AppConstants.bookConditions[index]} or better',
                  selected: _draft.minCondition == index,
                  onTap: () => _update(
                    _draft.copyWith(
                      minCondition: _draft.minCondition == index ? null : index,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text('Within ${widget.radiusKm} km of me'),
            subtitle: Text(
              _locating
                  ? 'Finding your location…'
                  : 'Uses your location only to measure distance',
            ),
            value: _draft.nearbyOnly,
            onChanged: _locating ? null : _setNearby,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available now'),
            subtitle: const Text('Hide books that are already requested'),
            value: _draft.onlyAvailable,
            onChanged: (value) =>
                _update(_draft.copyWith(onlyAvailable: value)),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    AppTone tone = AppTone.primary,
  }) {
    return SizedBox(
      height: 40,
      child: _FilterPill(
        label: label,
        icon: icon,
        tone: tone,
        selected: selected,
        onTap: onTap,
      ),
    );
  }
}
