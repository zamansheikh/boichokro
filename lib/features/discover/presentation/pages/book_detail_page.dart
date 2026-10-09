import '../../../profile/presentation/pages/user_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../../l10n/book/gen/book_l10n.dart';
import '../../../chats/presentation/bloc/chat_bloc.dart';
import '../../../chats/presentation/bloc/chat_event.dart';
import '../../../chats/presentation/bloc/chat_state.dart';
import '../../../library/domain/entities/request.dart';
import '../../../library/domain/usecases/get_request_by_id_usecase.dart';
import '../../../library/presentation/widgets/request_timeline_widget.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/book_usecases.dart';
import '../../domain/usecases/user_usecases.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';
import '../bloc/request/request_bloc.dart';
import '../bloc/request/request_event.dart';
import '../bloc/request/request_state.dart';

/// Book Detail Page - Display full book information
class BookDetailPage extends StatefulWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final BookBloc _bookBloc;
  late final RequestBloc _requestBloc;
  late final GetUserByIdUseCase _getUserByIdUseCase;

  Book? _currentBook;

  // Owner view: every request made for this book.
  List<BookRequest> _requestsForBook = [];
  bool _requestListLoading = false;
  String? _requestListError;

  // Seeker view: the viewer's own open request for this book, if any.
  BookRequest? _myRequest;

  final Map<String, Future<User?>> _userCache = {};
  final Map<String, Future<Book?>> _offeredBookCache = {};
  final GlobalKey _requestsSectionKey = GlobalKey();
  Position? _cachedPosition; // for distance calculation

  @override
  void initState() {
    super.initState();
    _bookBloc = getIt<BookBloc>()..add(LoadBookById(widget.bookId));
    _requestBloc = getIt<RequestBloc>();
    _getUserByIdUseCase = getIt<GetUserByIdUseCase>();
    _fetchLocation();
  }

  @override
  void dispose() {
    _bookBloc.close();
    _requestBloc.close();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  String? get _currentUserId => getIt<FirebaseService>().auth.currentUser?.uid;

  BookL10n get _l => BookL10n.of(context);

  bool _isOwnerOf(Book book) {
    final currentUserId = _currentUserId;
    return currentUserId != null && currentUserId == book.ownerId;
  }

  bool _isOwnerViewingCurrentBook() {
    final book = _currentBook;
    if (book == null) return false;
    return _isOwnerOf(book);
  }

  /// Distance between the viewer and the book, or null when the location is
  /// unknown (permission not granted, or still being fetched).
  String? _distanceLabel(Book book) {
    final pos = _cachedPosition;
    if (pos == null) return null;
    final distanceMeters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      book.location.latitude,
      book.location.longitude,
    );
    return _l.distanceAway(context.distance(distanceMeters));
  }

  Future<void> _fetchLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      if (mounted) setState(() => _cachedPosition = pos);
    } catch (_) {}
  }

  Future<User?> _getUserFuture(String userId) {
    return _userCache[userId] ??= _fetchUser(userId);
  }

  Future<User?> _fetchUser(String userId) async {
    final result = await _getUserByIdUseCase(GetUserByIdParams(userId));
    return result.fold((_) => null, (user) => user);
  }

  Future<Book?> _getOfferedBookFuture(String bookId) {
    return _offeredBookCache[bookId] ??= _fetchBook(bookId);
  }

  Future<Book?> _fetchBook(String bookId) async {
    final result = await getIt<GetBookByIdUseCase>()(GetBookByIdParams(bookId));
    return result.fold((_) => null, (book) => book);
  }

  Future<BookRequest?> _loadActiveRequest(String requestId) async {
    final useCase = getIt<GetRequestByIdUseCase>();
    final result = await useCase(GetRequestByIdParams(requestId));
    return result.fold((_) => null, (request) => request);
  }

  bool _isOpen(BookRequest request) =>
      request.status == RequestStatus.pending ||
      request.status == RequestStatus.accepted;

  List<BookRequest> _sortedRequestsForDisplay(List<BookRequest> requests) {
    final sorted = List<BookRequest>.from(requests);
    sorted.sort((a, b) {
      final priorityDiff =
          _statusPriority(a.status) - _statusPriority(b.status);
      if (priorityDiff != 0) return priorityDiff;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  int _statusPriority(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 0;
      case RequestStatus.accepted:
        return 1;
      case RequestStatus.completed:
        return 2;
      case RequestStatus.declined:
        return 3;
      case RequestStatus.cancelled:
        return 4;
    }
  }

  // ---------------------------------------------------------------------------
  // Bloc reactions
  // ---------------------------------------------------------------------------

  void _onBookLoaded(Book book) {
    if (!mounted) return;
    final currentUserId = _currentUserId;
    final bool isOwner = currentUserId != null && currentUserId == book.ownerId;
    final bool bookChanged = _currentBook?.id != book.id;
    final String? activeId = book.activeRequestId;

    setState(() {
      _currentBook = book;

      if (!isOwner) {
        _requestsForBook = [];
        _requestListLoading = false;
        _requestListError = null;
      }
    });

    if (isOwner && (bookChanged || _requestsForBook.isEmpty)) {
      setState(() {
        _requestListLoading = true;
        _requestListError = null;
      });
      _requestBloc.add(LoadRequestsForBook(book.id));
    }

    if (!isOwner && currentUserId != null) {
      // Find out whether the viewer already has a request on this book.
      if (bookChanged) _requestBloc.add(LoadMyRequests(currentUserId));
      if (activeId != null && activeId.isNotEmpty) {
        _loadActiveRequest(activeId).then((request) {
          if (!mounted || request == null) return;
          if (request.seekerId == currentUserId && _isOpen(request)) {
            setState(() => _myRequest = request);
          }
        });
      }
    }
  }

  void _onBookState(BuildContext context, BookState state) {
    if (state is BookDetailLoaded) {
      _onBookLoaded(state.book);
    } else if (state is BookUpdated) {
      _onBookLoaded(state.book);
    } else if (state is BookAdded) {
      _onBookLoaded(state.book);
    } else if (state is BookDeleted) {
      showAppSnack(
        context,
        BookL10n.of(context).listingRemovedSnack,
        tone: AppTone.success,
      );
      if (context.canPop()) context.pop();
    } else if (state is BookError && _currentBook != null) {
      // The book is already on screen; keep it and report the failure.
      showAppSnack(context, state.message, tone: AppTone.danger);
    }
  }

  void _onRequestState(BuildContext context, RequestState state) {
    if (!mounted) return;

    if (!_isOwnerViewingCurrentBook()) {
      _onSeekerRequestState(state);
      return;
    }

    if (state is RequestLoading) {
      setState(() {
        _requestListLoading = true;
        _requestListError = null;
      });
    } else if (state is RequestLoaded) {
      final requests = state.requests;
      final filtered = requests
          .where((request) => request.bookId == widget.bookId)
          .toList();
      setState(() {
        _requestsForBook = _sortedRequestsForDisplay(filtered);
        _requestListLoading = false;
        _requestListError = null;
      });
    } else if (state is RequestUpdated) {
      final updatedRequest = state.request;
      if (updatedRequest.bookId == widget.bookId) {
        _requestBloc.add(LoadRequestsForBook(widget.bookId));
        _bookBloc.add(LoadBookById(widget.bookId));
      }
    } else if (state is RequestDeleted) {
      _requestBloc.add(LoadRequestsForBook(widget.bookId));
    } else if (state is RequestError) {
      final message = state.message;
      setState(() {
        _requestListLoading = false;
        _requestListError = message;
      });
    }
  }

  void _onSeekerRequestState(RequestState state) {
    final userId = _currentUserId;
    if (userId == null) return;

    if (state is RequestLoaded) {
      final mine = _sortedRequestsForDisplay(
        state.requests
            .where(
              (request) =>
                  request.bookId == widget.bookId &&
                  request.seekerId == userId &&
                  _isOpen(request),
            )
            .toList(),
      );
      setState(() => _myRequest = mine.isEmpty ? null : mine.first);
    } else if (state is RequestCreated) {
      final created = state.request;
      if (created.bookId == widget.bookId) {
        setState(() => _myRequest = created);
      }
    }
  }

  /// The book to show for [state]. While a refresh is in flight the last
  /// loaded book stays on screen instead of flashing a spinner.
  Book? _bookFor(BookState state) {
    if (state is BookDetailLoaded) return state.book;
    if (state is BookAdded) return state.book;
    if (state is BookUpdated) return state.book;
    if (state is BookDeleted || state is BookLoaded) return null;
    return _currentBook;
  }

  // ---------------------------------------------------------------------------
  // Page
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bookBloc),
        BlocProvider.value(value: _requestBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<BookBloc, BookState>(listener: _onBookState),
          BlocListener<RequestBloc, RequestState>(listener: _onRequestState),
        ],
        child: BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            final book = _bookFor(state);
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  tooltip: context.core.commonBack,
                  icon: const Icon(LucideIcons.arrowLeft),
                  onPressed: () => context.pop(),
                ),
                actions: book == null
                    ? null
                    : [
                        IconButton(
                          tooltip: _l.shareTooltip,
                          icon: const Icon(LucideIcons.share2),
                          onPressed: () => _shareBook(book),
                        ),
                        IconButton(
                          tooltip: _l.moreOptions,
                          icon: const Icon(LucideIcons.ellipsisVertical),
                          onPressed: () => _showMoreOptions(book),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
              ),
              body: book != null
                  ? _buildBookDetail(context, book)
                  : _buildPlaceholder(context, state),
              bottomNavigationBar: book != null
                  ? _buildActionBar(context, book)
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, BookState state) {
    if (state is BookError) {
      return AppErrorState(
        title: _l.openErrorTitle,
        message: state.message,
        onRetry: () => _bookBloc.add(LoadBookById(widget.bookId)),
      );
    }
    if (state is BookDeleted) {
      return AppEmptyState(
        icon: LucideIcons.trash2,
        tone: AppTone.neutral,
        title: _l.removedTitle,
        message: _l.removedMessage,
        actionLabel: _l.goBack,
        actionIcon: LucideIcons.arrowLeft,
        onAction: () => context.pop(),
      );
    }
    if (state is BookLoaded) {
      return AppEmptyState(
        icon: LucideIcons.searchX,
        tone: AppTone.neutral,
        title: _l.notFoundTitle,
        message: _l.notFoundMessage,
        actionLabel: _l.goBack,
        actionIcon: LucideIcons.arrowLeft,
        onAction: () => context.pop(),
      );
    }
    return const _BookDetailSkeleton();
  }

  Widget _buildBookDetail(BuildContext context, Book book) {
    final bool isOwner = _isOwnerOf(book);
    final description = book.description?.trim() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(context, book),
          const SizedBox(height: AppSpacing.xxl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusPill.mode(book.mode),
              StatusPill.book(book.status),
              if (isOwner)
                StatusPill(
                  label: _l.yourListingPill,
                  icon: LucideIcons.userCheck,
                  tone: AppTone.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            book.title,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: context.text.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _l.authorByline(book.author),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          if (isOwner) ...[
            const SizedBox(height: AppSpacing.xxxl),
            KeyedSubtree(
              key: _requestsSectionKey,
              child: _buildOwnerRequestsSection(context, book),
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),
          SectionHeader(title: _l.aboutCopyTitle),
          const SizedBox(height: AppSpacing.md),
          _buildFactsCard(context, book, isOwner: isOwner),

          if (description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxxl),
            SectionHeader(
              title: isOwner ? _l.yourNoteTitle : _l.fromOwnerTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: context.text.bodyLarge?.copyWith(height: 1.6),
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),
          SectionHeader(title: isOwner ? _l.listedByYouTitle : _l.ownerTitle),
          const SizedBox(height: AppSpacing.md),
          _buildOwnerCard(context, book),

          if (!isOwner && book.status != BookStatus.completed) ...[
            const SizedBox(height: AppSpacing.xxxl),
            SectionHeader(title: _l.howItWorksTitle),
            const SizedBox(height: AppSpacing.md),
            _HowItWorks(mode: book.mode),
          ],
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, Book book) {
    final tone = context.tone(book.mode.tone);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: tone.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      alignment: Alignment.center,
      child: BookCover(
        imageUrl: book.coverUrl,
        title: book.title,
        width: 164,
        heroTag: 'discover_book_${book.id}',
      ),
    );
  }

  Widget _buildFactsCard(
    BuildContext context,
    Book book, {
    required bool isOwner,
  }) {
    final distance = isOwner ? null : _distanceLabel(book);
    final address = book.location.address?.trim() ?? '';
    final isbn = book.isbn?.trim() ?? '';

    final rows = <Widget>[
      _FactRow(
        icon: LucideIcons.bookOpen,
        label: _l.factCondition,
        child: ConditionMeter(condition: book.condition),
      ),
      if (distance != null)
        _FactRow(
          icon: LucideIcons.navigation,
          label: _l.factDistance,
          value: distance,
        ),
      if (address.isNotEmpty)
        _FactRow(icon: LucideIcons.mapPin, label: _l.factArea, value: address),
      _FactRow(
        icon: LucideIcons.calendarDays,
        label: _l.factListed,
        value:
            '${context.relativeTime(book.createdAt)} · ${context.date(book.createdAt, 'MMM d, yyyy')}',
      ),
      if (isbn.isNotEmpty)
        _FactRow(icon: LucideIcons.hash, label: _l.factIsbn, value: isbn),
      if (book.genres.isNotEmpty)
        _FactRow(
          icon: LucideIcons.tags,
          label: _l.factGenres,
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final genre in book.genres)
                StatusPill(label: context.genreLabel(genre), dense: true),
            ],
          ),
        ),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.colors.outlineVariant),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _buildOwnerCard(BuildContext context, Book book) {
    return FutureBuilder<User?>(
      future: _getUserFuture(book.ownerId),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final user = snapshot.data;

        if (isLoading) {
          return const AppCard(
            child: Row(
              children: [
                Skeleton(width: 52, height: 52, radius: AppRadius.pill),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 140, height: 16),
                      SizedBox(height: AppSpacing.sm),
                      Skeleton(width: 90, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (user == null) {
          return AppCard(
            child: Row(
              children: [
                const UserAvatar(radius: 26),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    _l.ownerUnavailable,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return AppCard(
          onTap: () => context.push(userProfilePath(user.id)),
          child: Row(
            children: [
              UserAvatar(
                photoUrl: user.photoUrl,
                name: user.name,
                radius: 26,
                verified: user.verifiedBadge,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    RatingBadge(rating: user.ratingAvg, swaps: user.totalSwaps),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Owner: incoming requests
  // ---------------------------------------------------------------------------

  Widget _buildOwnerRequestsSection(BuildContext context, Book book) {
    final requests = _requestsForBook;
    final isLoading = _requestListLoading;
    final errorMessage = _requestListError;
    void retry() => _requestBloc.add(LoadRequestsForBook(book.id));

    // Pending and accepted requests are the ones the owner can act on.
    final openRequests = requests.where(_isOpen).toList();
    final pendingCount = openRequests
        .where((r) => r.status == RequestStatus.pending)
        .length;

    final String? subtitle;
    if (isLoading && requests.isNotEmpty) {
      subtitle = _l.requestsRefreshing;
    } else if (pendingCount > 0) {
      subtitle = _l.requestsWaiting(pendingCount);
    } else {
      subtitle = null;
    }

    final content = <Widget>[];

    if (isLoading && requests.isEmpty) {
      content.add(
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Skeleton(width: 44, height: 44, radius: AppRadius.pill),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: Skeleton(height: 16)),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Skeleton(height: 44, radius: AppRadius.md),
            ],
          ),
        ),
      );
    } else if (errorMessage != null && requests.isEmpty) {
      content.add(
        AppBanner(
          tone: AppTone.danger,
          icon: LucideIcons.circleAlert,
          title: _l.requestsLoadErrorTitle,
          message: errorMessage,
          actionLabel: context.core.commonRetry,
          onAction: retry,
        ),
      );
    } else if (requests.isEmpty) {
      content.add(
        AppCard(
          child: AppEmptyState(
            compact: true,
            icon: LucideIcons.inbox,
            title: _l.requestsEmptyTitle,
            message: _l.requestsEmptyMessage,
          ),
        ),
      );
    } else {
      if (errorMessage != null) {
        content.add(
          AppBanner(
            tone: AppTone.danger,
            icon: LucideIcons.circleAlert,
            message: errorMessage,
            actionLabel: context.core.commonRetry,
            onAction: retry,
          ),
        );
      }
      if (openRequests.isEmpty) {
        content.add(
          AppBanner(tone: AppTone.neutral, message: _l.requestsNoneOpen),
        );
      }
      for (final request in openRequests) {
        content.add(_buildOwnerRequestCard(context, request, book));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: _l.requestsTitle, subtitle: subtitle),
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < content.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          content[i],
        ],
      ],
    );
  }

  Widget _buildOwnerRequestCard(
    BuildContext context,
    BookRequest request,
    Book book,
  ) {
    final bool isPending = request.status == RequestStatus.pending;
    final bool isAccepted = request.status == RequestStatus.accepted;
    final offeredBookId = request.offeredBookId;
    final acceptedAt = request.acceptedAt;
    final chatRoomId = request.chatRoomId;

    return FutureBuilder<User?>(
      future: _getUserFuture(request.seekerId),
      builder: (context, userSnapshot) {
        final seeker = userSnapshot.data;
        final seekerLoading =
            userSnapshot.connectionState == ConnectionState.waiting;

        return AppCard(
          borderColor: isPending
              ? context.tone(request.status.tone).solid.withValues(alpha: 0.45)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Who is asking + request status.
              Row(
                children: [
                  UserAvatar(
                    photoUrl: seeker?.photoUrl,
                    name: seeker?.name,
                    radius: 22,
                    verified: seeker?.verifiedBadge ?? false,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seeker?.name ??
                              (seekerLoading
                                  ? context.core.commonLoading
                                  : context.core.aReader),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        if (seeker != null)
                          RatingBadge(
                            rating: seeker.ratingAvg,
                            swaps: seeker.totalSwaps,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusPill.request(request.status, dense: true),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.xs,
                children: [
                  MetaItem(
                    icon: LucideIcons.clock,
                    label: _l.requestedTime(
                      context.relativeTime(request.createdAt),
                    ),
                  ),
                  if (acceptedAt != null)
                    MetaItem(
                      icon: LucideIcons.check,
                      label: _l.acceptedTime(context.relativeTime(acceptedAt)),
                      color: context.palette.success,
                    ),
                ],
              ),
              if (offeredBookId != null && offeredBookId.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _buildOfferedBook(context, offeredBookId),
              ],
              const SizedBox(height: AppSpacing.md),
              RequestTimelineWidget(request: request, isSeeker: false),
              const SizedBox(height: AppSpacing.lg),
              if (isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _declineRequest(request),
                        icon: const Icon(LucideIcons.x, size: 18),
                        label: _oneLine(_l.decline),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.error,
                          side: BorderSide(color: context.colors.error),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _acceptRequest(request, book),
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: _oneLine(_l.accept),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (isAccepted && !request.ownerConfirmed)
                FilledButton.icon(
                  onPressed: () => _confirmHandover(request),
                  icon: const Icon(LucideIcons.packageCheck, size: 18),
                  label: _oneLine(_l.confirmHandover),
                ),
              if (isAccepted && request.ownerConfirmed)
                AppBanner(
                  tone: AppTone.success,
                  icon: LucideIcons.circleCheck,
                  message: _l.handoverConfirmedBanner,
                ),
              if (!isPending && chatRoomId != null) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('${RoutePaths.chat}/$chatRoomId'),
                  icon: const Icon(LucideIcons.messageCircle, size: 18),
                  label: _oneLine(_l.openChat),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// The book a reader offers in return (exchange requests only).
  Widget _buildOfferedBook(BuildContext context, String offeredBookId) {
    final tone = context.tone(AppTone.exchange);
    return FutureBuilder<Book?>(
      future: _getOfferedBookFuture(offeredBookId),
      builder: (context, snapshot) {
        final offered = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Material(
          color: tone.background.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: offered == null
                ? null
                : () => context.push('/book/${offered.id}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (offered != null)
                    BookCover(
                      imageUrl: offered.coverUrl,
                      title: offered.title,
                      width: 40,
                      elevated: false,
                    )
                  else
                    const Skeleton(width: 40, height: 60),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(_l.offersInExchange, color: tone.foreground),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          offered?.title ??
                              (isLoading
                                  ? _l.offeredLoading
                                  : _l.offeredUnavailable),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            color: tone.foreground,
                          ),
                        ),
                        if (offered != null)
                          Text(
                            offered.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              color: tone.foreground,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (offered != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: tone.foreground,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _acceptRequest(BookRequest request, Book book) async {
    final confirmed = await _showConfirmationDialog(
      title: _l.acceptDialogTitle,
      message: book.mode == BookMode.donate
          ? _l.acceptDialogMessageDonate
          : _l.acceptDialogMessageExchange,
      confirmLabel: _l.acceptDialogConfirm,
    );
    if (!confirmed || !mounted) return;
    _handleOwnerRequestAction(
      request,
      RequestStatus.accepted,
      progressLabel: _l.acceptProgress,
      successMessage: _l.acceptSuccess,
      successTone: AppTone.success,
    );
  }

  Future<void> _declineRequest(BookRequest request) async {
    final confirmed = await _showConfirmationDialog(
      title: _l.declineDialogTitle,
      message: _l.declineDialogMessage,
      confirmLabel: _l.declineDialogConfirm,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _handleOwnerRequestAction(
      request,
      RequestStatus.declined,
      progressLabel: _l.declineProgress,
      successMessage: _l.declineSuccess,
      successTone: AppTone.warning,
    );
  }

  Future<void> _confirmHandover(BookRequest request) async {
    final confirmed = await _showConfirmationDialog(
      title: _l.handoverDialogTitle,
      message: _l.handoverDialogMessage,
      confirmLabel: _l.handoverDialogConfirm,
    );
    if (!confirmed || !mounted) return;
    _handleConfirmExchange(request);
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.core.commonCancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: dialogContext.colors.error,
                    foregroundColor: dialogContext.colors.onError,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleOwnerRequestAction(
    BookRequest request,
    RequestStatus status, {
    required String progressLabel,
    required String successMessage,
    required AppTone successTone,
  }) {
    final l = _l;
    _requestBloc.add(
      UpdateRequestStatus(requestId: request.id, status: status),
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: _requestBloc,
        child: BlocListener<RequestBloc, RequestState>(
          listener: (listenerContext, state) {
            if (state is RequestUpdated) {
              final updatedRequest = state.request;
              if (updatedRequest.id != request.id) return;
              Navigator.pop(dialogContext);
              showAppSnack(listenerContext, successMessage, tone: successTone);
            } else if (state is RequestError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              showAppSnack(
                listenerContext,
                l.requestUpdateFailed(message),
                tone: AppTone.danger,
              );
            }
          },
          child: _ProgressDialog(label: progressLabel),
        ),
      ),
    );
  }

  void _handleConfirmExchange(BookRequest request) {
    final currentUser = getIt<FirebaseService>().auth.currentUser;
    final l = _l;

    if (currentUser == null) {
      showAppSnack(context, l.signInToConfirm);
      return;
    }

    _requestBloc.add(
      ConfirmExchange(requestId: request.id, userId: currentUser.uid),
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: _requestBloc,
        child: BlocListener<RequestBloc, RequestState>(
          listener: (listenerContext, state) {
            if (state is RequestUpdated) {
              Navigator.pop(dialogContext);
              if (!mounted) return;
              _bookBloc.add(LoadBookById(widget.bookId));
              showAppSnack(
                listenerContext,
                l.exchangeConfirmRecorded,
                tone: AppTone.success,
              );
            } else if (state is RequestError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              showAppSnack(
                listenerContext,
                l.exchangeConfirmFailed(message),
                tone: AppTone.danger,
              );
            }
          },
          child: _ProgressDialog(label: l.exchangeConfirmProgress),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pinned action bar
  // ---------------------------------------------------------------------------

  Widget _buildActionBar(BuildContext context, Book book) {
    return _isOwnerOf(book)
        ? _buildOwnerActionBar(context, book)
        : _buildSeekerActionBar(context, book);
  }

  Widget _buildSeekerActionBar(BuildContext context, Book book) {
    final myRequest = _myRequest;

    if (myRequest != null && myRequest.status == RequestStatus.accepted) {
      final chatRoomId = myRequest.chatRoomId;
      return _ActionBar(
        statusIcon: LucideIcons.handshake,
        statusTone: AppTone.success,
        status: _l.seekerBarAccepted,
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: chatRoomId != null
                  ? () => context.push('${RoutePaths.chat}/$chatRoomId')
                  : () => _handleMessageOwner(book),
              icon: const Icon(LucideIcons.messageCircle, size: 18),
              label: _oneLine(_l.openChat),
            ),
          ),
        ],
      );
    }

    if (myRequest != null) {
      return _ActionBar(
        statusIcon: LucideIcons.clock,
        statusTone: AppTone.warning,
        status: _l.seekerBarRequestSent(
          context.relativeTime(myRequest.createdAt).toLowerCase(),
        ),
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleMessageOwner(book),
              icon: const Icon(LucideIcons.messageCircle, size: 18),
              label: _oneLine(_l.messageOwner),
            ),
          ),
        ],
      );
    }

    if (book.status != BookStatus.available) {
      return _ActionBar(
        statusIcon: book.status.icon,
        statusTone: book.status.tone,
        status: book.status == BookStatus.completed
            ? _l.seekerBarCompleted
            : _l.seekerBarBusy,
        children: [
          Expanded(
            child: FilledButton(
              onPressed: null,
              child: _oneLine(_l.notAvailable),
            ),
          ),
        ],
      );
    }

    final isDonate = book.mode == BookMode.donate;
    return _ActionBar(
      children: [
        Tooltip(
          message: _l.messageOwner,
          child: OutlinedButton(
            onPressed: () => _handleMessageOwner(book),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(52, 52),
              fixedSize: const Size(52, 52),
            ),
            child: const Icon(LucideIcons.messageCircle, size: 20),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _handleRequestBook(book),
            icon: Icon(book.mode.icon, size: 18),
            label: _oneLine(isDonate ? _l.requestThisBook : _l.offerSwap),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerActionBar(BuildContext context, Book book) {
    final openRequests = _requestsForBook.where(_isOpen).toList();
    final pending = openRequests
        .where((r) => r.status == RequestStatus.pending)
        .toList();
    final accepted = openRequests
        .where((r) => r.status == RequestStatus.accepted)
        .toList();

    if (accepted.isNotEmpty) {
      final request = accepted.first;
      final chatRoomId = request.chatRoomId;
      final chatButton = chatRoomId == null
          ? null
          : OutlinedButton.icon(
              onPressed: () => context.push('${RoutePaths.chat}/$chatRoomId'),
              icon: const Icon(LucideIcons.messageCircle, size: 18),
              label: _oneLine(_l.openChat),
            );

      if (request.ownerConfirmed) {
        return _ActionBar(
          statusIcon: LucideIcons.hourglass,
          statusTone: AppTone.exchange,
          status: _l.ownerBarWaitingReader,
          children: [if (chatButton != null) Expanded(child: chatButton)],
        );
      }
      return _ActionBar(
        statusIcon: LucideIcons.handshake,
        statusTone: AppTone.primary,
        status: _l.ownerBarAccepted,
        children: [
          if (chatRoomId != null) ...[
            Tooltip(
              message: _l.openChat,
              child: OutlinedButton(
                onPressed: () => context.push('${RoutePaths.chat}/$chatRoomId'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(52, 52),
                  fixedSize: const Size(52, 52),
                ),
                child: const Icon(LucideIcons.messageCircle, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _confirmHandover(request),
              icon: const Icon(LucideIcons.packageCheck, size: 18),
              label: _oneLine(_l.confirmHandover),
            ),
          ),
        ],
      );
    }

    if (pending.isNotEmpty) {
      return _ActionBar(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _scrollToRequests,
              icon: const Icon(LucideIcons.inbox, size: 18),
              label: _oneLine(_l.ownerBarReviewRequests(pending.length)),
            ),
          ),
        ],
      );
    }

    if (book.status == BookStatus.available) {
      return _ActionBar(
        statusIcon: LucideIcons.circleCheck,
        statusTone: AppTone.success,
        status: _l.ownerBarLive,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editBook(book),
              icon: const Icon(LucideIcons.pencil, size: 18),
              label: _oneLine(_l.editListing),
            ),
          ),
        ],
      );
    }

    return _ActionBar(
      statusIcon: book.status.icon,
      statusTone: book.status.tone,
      status: book.status == BookStatus.completed
          ? _l.ownerBarCompleted
          : _l.ownerBarInProgress(book.status.label(context).toLowerCase()),
      children: const [],
    );
  }

  void _scrollToRequests() {
    final target = _requestsSectionKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: AppMotion.slow,
      curve: AppMotion.curve,
    );
  }

  // ---------------------------------------------------------------------------
  // Share + overflow menu
  // ---------------------------------------------------------------------------

  void _shareBook(Book book) {
    final shareText = _l.shareText(
      book.title,
      book.author,
      book.mode.label(context),
      context.conditionLabel(book.condition),
    );
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _showMoreOptions(Book book) {
    final isOwner = _isOwnerOf(book);
    final canChange = book.status == BookStatus.available;

    showAppSheet<void>(
      context,
      builder: (sheetContext) {
        final l = BookL10n.of(sheetContext);
        final danger = sheetContext.colors.error;
        return SheetScaffold(
          title: isOwner ? l.manageListingTitle : l.moreOptions,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: isOwner
                ? [
                    ListTile(
                      enabled: canChange,
                      leading: const Icon(LucideIcons.pencil),
                      title: Text(l.editListing),
                      subtitle: canChange
                          ? null
                          : Text(l.actionBlockedSubtitle),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _editBook(book);
                      },
                    ),
                    ListTile(
                      enabled: canChange,
                      leading: Icon(
                        LucideIcons.trash2,
                        color: canChange ? danger : null,
                      ),
                      title: Text(
                        l.deleteListing,
                        style: canChange ? TextStyle(color: danger) : null,
                      ),
                      subtitle: canChange
                          ? null
                          : Text(l.actionBlockedSubtitle),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _deleteBook(book);
                      },
                    ),
                  ]
                : [
                    ListTile(
                      leading: const Icon(LucideIcons.bookmarkPlus),
                      title: Text(l.saveToWishlist),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _saveToWishlist(book);
                      },
                    ),
                    ListTile(
                      leading: const Icon(LucideIcons.flag),
                      title: Text(l.reportBook),
                      subtitle: Text(l.reportBookSubtitle),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _reportBook(book);
                      },
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.ban, color: danger),
                      title: Text(
                        l.blockOwner,
                        style: TextStyle(color: danger),
                      ),
                      subtitle: Text(l.blockOwnerSubtitle),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _blockOwner(book);
                      },
                    ),
                  ],
          ),
        );
      },
    );
  }

  Future<void> _editBook(Book book) async {
    await context.push('/book/${book.id}/edit', extra: book);
    if (!mounted) return;
    _bookBloc.add(LoadBookById(widget.bookId));
  }

  Future<void> _deleteBook(Book book) async {
    final confirmed = await _showConfirmationDialog(
      title: _l.deleteDialogTitle,
      message: _l.deleteDialogMessage(book.title),
      confirmLabel: _l.deleteListing,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _bookBloc.add(DeleteBook(book.id));
  }

  Future<void> _reportBook(Book book) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAppSnack(context, _l.signInToReport);
      return;
    }
    final confirmed = await _showConfirmationDialog(
      title: _l.reportDialogTitle,
      message: _l.reportDialogMessage,
      confirmLabel: _l.reportDialogConfirm,
    );
    if (!confirmed) return;
    try {
      await getIt<FirebaseService>().firestore.collection('reports').add({
        'reporterId': userId,
        'bookId': book.id,
        'ownerId': book.ownerId,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'book',
      });
      if (!mounted) return;
      showAppSnack(context, _l.reportSuccess, tone: AppTone.success);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, _l.reportFailed('$e'), tone: AppTone.danger);
    }
  }

  Future<void> _blockOwner(Book book) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAppSnack(context, _l.signInToBlock);
      return;
    }
    final confirmed = await _showConfirmationDialog(
      title: _l.blockDialogTitle,
      message: _l.blockDialogMessage,
      confirmLabel: _l.blockOwner,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await getIt<FirebaseService>().firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
            'blockedUsers': FieldValue.arrayUnion([book.ownerId]),
          });
      if (!mounted) return;
      showAppSnack(context, _l.blockSuccess, tone: AppTone.warning);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, _l.blockFailed('$e'), tone: AppTone.danger);
    }
  }

  Future<void> _saveToWishlist(Book book) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAppSnack(context, _l.signInToSave);
      return;
    }
    try {
      await getIt<FirebaseService>().firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
            'wishlist': FieldValue.arrayUnion([book.id]),
          });
      if (!mounted) return;
      showAppSnack(context, _l.wishlistSaved, tone: AppTone.success);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, _l.wishlistFailed('$e'), tone: AppTone.danger);
    }
  }

  // ---------------------------------------------------------------------------
  // Seeker: request flow
  // ---------------------------------------------------------------------------

  void _handleRequestBook(Book book) {
    final currentUser = getIt<FirebaseService>().auth.currentUser;

    if (currentUser == null) {
      showAppSnack(context, _l.signInToRequest);
      return;
    }

    // Check if user is trying to request their own book
    if (currentUser.uid == book.ownerId) {
      showAppSnack(context, _l.cannotRequestOwn);
      return;
    }

    if (_myRequest != null) {
      showAppSnack(context, _l.alreadyRequested);
      return;
    }

    if (book.mode == BookMode.exchange) {
      // Pick one of the viewer's books to offer in return
      _showExchangeBookSelector(book, currentUser.uid);
    } else {
      // Donate mode - direct request
      _showDonateRequestSheet(book, currentUser.uid);
    }
  }

  Future<void> _showExchangeBookSelector(
    Book requestedBook,
    String userId,
  ) async {
    final result = await showAppSheet<Object>(
      context,
      builder: (_) =>
          _OfferPickerSheet(requestedBook: requestedBook, userId: userId),
    );
    if (!mounted) return;

    if (result is Book) {
      _createExchangeRequest(requestedBook, result, userId);
    } else if (result == _OfferPickerAction.addBook) {
      context.push(RoutePaths.addBook);
    }
  }

  Future<void> _showDonateRequestSheet(Book book, String userId) async {
    final confirmed = await showAppSheet<bool>(
      context,
      builder: (sheetContext) => SheetScaffold(
        title: BookL10n.of(sheetContext).requestSheetTitle,
        subtitle: BookL10n.of(sheetContext).requestSheetSubtitle,
        footer: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: _oneLine(sheetContext.core.commonCancel),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: _oneLine(BookL10n.of(sheetContext).sendRequest),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BookSummary(book: book),
            const SizedBox(height: AppSpacing.lg),
            AppBanner(
              tone: AppTone.donate,
              icon: LucideIcons.gift,
              title: BookL10n.of(sheetContext).giftBannerTitle,
              message: BookL10n.of(sheetContext).giftBannerMessage,
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    _createDonateRequest(book, userId);
  }

  void _createExchangeRequest(
    Book requestedBook,
    Book offeredBook,
    String userId,
  ) {
    final request = BookRequest(
      id: '', // Will be set by Firestore
      bookId: requestedBook.id,
      seekerId: userId,
      ownerId: requestedBook.ownerId,
      offeredBookId: offeredBook.id,
      status: RequestStatus.pending,
      chatRoomId: null, // Will be created after request
      acceptedAt: null,
      ownerConfirmed: false,
      seekerConfirmed: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sendRequest(
      request,
      progressLabel: _l.swapRequestProgress,
      successMessage: _l.swapRequestSuccess(
        offeredBook.title,
        requestedBook.title,
      ),
    );
  }

  void _createDonateRequest(Book requestedBook, String userId) {
    final request = BookRequest(
      id: '', // Will be set by Firestore
      bookId: requestedBook.id,
      seekerId: userId,
      ownerId: requestedBook.ownerId,
      offeredBookId: null, // No exchange for donations
      status: RequestStatus.pending,
      chatRoomId: null, // Will be created after request
      acceptedAt: null,
      ownerConfirmed: false,
      seekerConfirmed: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sendRequest(
      request,
      progressLabel: _l.requestProgress,
      successMessage: _l.requestSuccess(requestedBook.title),
    );
  }

  void _sendRequest(
    BookRequest request, {
    required String progressLabel,
    required String successMessage,
  }) {
    final requestBloc = _requestBloc;
    final l = _l;
    final viewLabel = context.core.commonView;
    requestBloc.add(CreateRequest(request));

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: requestBloc,
        child: BlocListener<RequestBloc, RequestState>(
          listener: (listenerContext, state) {
            if (state is RequestCreated) {
              Navigator.pop(dialogContext);
              showAppSnack(
                listenerContext,
                successMessage,
                tone: AppTone.success,
                action: SnackBarAction(
                  label: viewLabel,
                  onPressed: () {
                    // "My Requests" is the second tab of My Library.
                    if (mounted) context.push(RoutePaths.myLibrary, extra: 1);
                  },
                ),
              );
            } else if (state is RequestError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              showAppSnack(
                listenerContext,
                l.requestFailed(message),
                tone: AppTone.danger,
              );
            }
          },
          child: _ProgressDialog(label: progressLabel),
        ),
      ),
    );
  }

  Future<void> _handleMessageOwner(Book book) async {
    final currentUser = getIt<FirebaseService>().auth.currentUser;

    final l = _l;

    if (currentUser == null) {
      showAppSnack(context, l.signInToMessage);
      return;
    }

    // Check if user is trying to message themselves
    if (currentUser.uid == book.ownerId) {
      showAppSnack(context, l.ownBook);
      return;
    }

    // Fetch owner and requester names
    final ownerFuture = _getUserFuture(book.ownerId);
    final requesterFuture = _getUserFuture(currentUser.uid);

    final results = await Future.wait([ownerFuture, requesterFuture]);
    if (!mounted) return;
    final ownerUser = results[0];
    final requesterUser = results[1];

    final ownerName = ownerUser?.name ?? 'Owner';
    final requesterName =
        requesterUser?.name ?? currentUser.email?.split('@').first ?? 'User';

    final chatBloc = getIt<ChatBloc>();

    // Create or get existing chat room with the book owner and book context
    final participantIds = [currentUser.uid, book.ownerId]..sort();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: chatBloc
          ..add(
            CreateOrGetChatRoom(
              participantIds: participantIds,
              bookId: book.id,
              bookName: book.title,
              ownerName: ownerName,
              requesterName: requesterName,
            ),
          ),
        child: BlocListener<ChatBloc, ChatState>(
          listener: (listenerContext, state) {
            if (state is ChatRoomLoaded) {
              Navigator.pop(dialogContext);
              // Open the conversation itself; back returns to this book.
              if (mounted) {
                context.push('${RoutePaths.chat}/${state.chatRoom.id}');
              }
            } else if (state is ChatError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              showAppSnack(
                listenerContext,
                l.chatCreateFailed(message),
                tone: AppTone.danger,
              );
            }
          },
          child: _ProgressDialog(label: l.chatOpening),
        ),
      ),
    );
  }
}

// =============================================================================
// Private widgets
// =============================================================================

/// Button label that stays on one line; Bangla labels can run wider than the
/// English ones they replace.
Text _oneLine(String text) {
  return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
}

/// One labelled line inside the "About this copy" card.
class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    this.value,
    this.child,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 84,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child:
                child ??
                Text(
                  value ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Three numbered steps explaining what happens after tapping the main action.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.mode});

  final BookMode mode;

  @override
  Widget build(BuildContext context) {
    final l = BookL10n.of(context);
    final isDonate = mode == BookMode.donate;
    final steps = isDonate
        ? [
            (l.howDonateAskTitle, l.howDonateAskBody),
            (l.howOwnerAcceptsTitle, l.howOwnerAcceptsBody),
            (l.howDonateCollectTitle, l.howDonateCollectBody),
          ]
        : [
            (l.howSwapOfferTitle, l.howSwapOfferBody),
            (l.howOwnerAcceptsTitle, l.howOwnerAcceptsBody),
            (l.howSwapTradeTitle, l.howSwapTradeBody),
          ];
    final tone = context.tone(mode.tone);

    return AppCard(
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tone.background,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    context.number(i + 1),
                    style: context.text.labelLarge?.copyWith(
                      color: tone.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(steps[i].$1, style: context.text.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        steps[i].$2,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom bar holding the screen's primary action, with an optional status
/// line explaining the current state.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.children,
    this.status,
    this.statusIcon,
    this.statusTone = AppTone.neutral,
  });

  final List<Widget> children;
  final String? status;
  final IconData? statusIcon;
  final AppTone statusTone;

  @override
  Widget build(BuildContext context) {
    final status = this.status;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (status != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        statusIcon ?? LucideIcons.info,
                        size: 16,
                        color: context.tone(statusTone).solid,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        status,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              if (status != null && children.isNotEmpty)
                const SizedBox(height: AppSpacing.md),
              if (children.isNotEmpty) Row(children: children),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blocking "working on it" dialog shown while a request is in flight.
class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        // The Column keeps AppLoading's Center from stretching the dialog.
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            AppLoading(message: label),
          ],
        ),
      ),
    );
  }
}

/// Small cover + title + author row used inside sheets.
class _BookSummary extends StatelessWidget {
  const _BookSummary({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BookCover(imageUrl: book.coverUrl, title: book.title, width: 52),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// What the offer picker returns when it does not return a [Book].
enum _OfferPickerAction { addBook }

/// Sheet where a reader picks one of their own available books to offer in
/// exchange. Pops with the chosen [Book], or [_OfferPickerAction.addBook].
class _OfferPickerSheet extends StatefulWidget {
  const _OfferPickerSheet({required this.requestedBook, required this.userId});

  final Book requestedBook;
  final String userId;

  @override
  State<_OfferPickerSheet> createState() => _OfferPickerSheetState();
}

class _OfferPickerSheetState extends State<_OfferPickerSheet> {
  Book? _selected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookBloc>()..add(LoadMyBooks(widget.userId)),
      child: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          final l = BookL10n.of(context);
          Widget body;
          Widget? footer;

          if (state is BookLoaded) {
            // Only books that are free to give away can be offered.
            final availableBooks = state.books
                .where((book) => book.status == BookStatus.available)
                .toList();

            if (availableBooks.isEmpty) {
              body = AppEmptyState(
                compact: true,
                tone: AppTone.exchange,
                icon: LucideIcons.library,
                title: l.offerEmptyTitle,
                message: l.offerEmptyMessage,
                actionLabel: l.offerAddBook,
                actionIcon: LucideIcons.plus,
                onAction: () =>
                    Navigator.pop(context, _OfferPickerAction.addBook),
              );
            } else {
              final selected = _selected;
              body = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Eyebrow(l.offerAskingFor),
                  const SizedBox(height: AppSpacing.sm),
                  _BookSummary(book: widget.requestedBook),
                  const SizedBox(height: AppSpacing.xl),
                  Eyebrow(l.offerYourBooks),
                  const SizedBox(height: AppSpacing.sm),
                  for (final book in availableBooks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _OfferTile(
                        book: book,
                        selected: selected?.id == book.id,
                        onTap: () => setState(() => _selected = book),
                      ),
                    ),
                ],
              );
              footer = FilledButton.icon(
                onPressed: selected == null
                    ? null
                    : () => Navigator.pop(context, selected),
                icon: const Icon(LucideIcons.repeat, size: 18),
                label: _oneLine(
                  selected == null ? l.offerPickPrompt : l.offerSendSwap,
                ),
              );
            }
          } else if (state is BookError) {
            body = AppErrorState(
              title: l.offerLoadErrorTitle,
              message: state.message,
              onRetry: () =>
                  context.read<BookBloc>().add(LoadMyBooks(widget.userId)),
            );
          } else {
            body = Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
              child: AppLoading(message: l.offerLoading),
            );
          }

          return SheetScaffold(
            title: l.offerSheetTitle,
            subtitle: l.offerSheetSubtitle,
            trailing: IconButton(
              tooltip: context.core.commonClose,
              icon: const Icon(LucideIcons.x),
              onPressed: () => Navigator.pop(context),
            ),
            footer: footer,
            child: body,
          );
        },
      ),
    );
  }
}

/// Selectable row for one of the reader's own books.
class _OfferTile extends StatelessWidget {
  const _OfferTile({
    required this.book,
    required this.selected,
    required this.onTap,
  });

  final Book book;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: AppCard(
        onTap: onTap,
        radius: AppRadius.lg,
        padding: const EdgeInsets.all(AppSpacing.md),
        color: selected
            ? context.colors.primaryContainer.withValues(alpha: 0.45)
            : null,
        borderColor: selected ? context.colors.primary : null,
        child: Row(
          children: [
            BookCover(
              imageUrl: book.coverUrl,
              title: book.title,
              width: 44,
              elevated: false,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConditionMeter(condition: book.condition),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 22,
              color: selected ? context.colors.primary : context.colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder that mirrors the detail layout.
class _BookDetailSkeleton extends StatelessWidget {
  const _BookDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(height: 310, radius: AppRadius.xxl),
          SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Skeleton(width: 84, height: 26, radius: AppRadius.pill),
              SizedBox(width: AppSpacing.sm),
              Skeleton(width: 84, height: 26, radius: AppRadius.pill),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Skeleton(height: 28),
          SizedBox(height: AppSpacing.sm),
          Skeleton(width: 160, height: 16),
          SizedBox(height: AppSpacing.xxxl),
          Skeleton(height: 180, radius: AppRadius.xl),
          SizedBox(height: AppSpacing.xxl),
          Skeleton(height: 84, radius: AppRadius.xl),
        ],
      ),
    );
  }
}
