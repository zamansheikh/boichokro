import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  Timer? _searchDebounce;
  late BookBloc _bookBloc;
  String? _currentUserId;
  late final GetUserByIdUseCase _getUserByIdUseCase;
  final Map<String, Future<User?>> _userCache = {};
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  _DiscoverFilters _filters = const _DiscoverFilters();

  static const double _nearbyRadiusKm = AppConstants.defaultSearchRadius;

  @override
  void initState() {
    super.initState();
    _bookBloc = getIt<BookBloc>()..add(const LoadAllBooks());
    _currentUserId = getIt<FirebaseService>().auth.currentUser?.uid;
    _getUserByIdUseCase = getIt<GetUserByIdUseCase>();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _bookBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return BlocProvider.value(
      value: _bookBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover Books'),
          actions: [
            IconButton(
              icon: Icon(_isMapView ? LucideIcons.list : LucideIcons.map),
              onPressed: () {
                setState(() {
                  _isMapView = !_isMapView;
                });
              },
              tooltip: _isMapView ? 'List View' : 'Map View',
            ),
            IconButton(
              icon: const Icon(LucideIcons.filter),
              onPressed: _showFilterSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title, author, or genre...',
                  prefixIcon: const Icon(LucideIcons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Filter Chips
            _buildFilterRow(),

            const SizedBox(height: 16),

            // Content Area
            Expanded(child: _isMapView ? _buildMapView() : _buildListView()),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookAdded) {
          context.read<BookBloc>().add(const LoadAllBooks());
        }
      },
      builder: (context, state) {
        if (state is BookInitial) {
          return const SizedBox.shrink();
        } else if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookLoaded) {
          final books = state.books;
          if (books.isEmpty) {
            return _buildEmptyState();
          }

          final filteredBooks = _applyAllFilters(books);

          if (filteredBooks.isEmpty) {
            return _buildNoResults();
          }

          // Calculate center position
          LatLng center;
          if (_currentPosition != null) {
            center = LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );
          } else if (filteredBooks.isNotEmpty) {
            center = LatLng(
              filteredBooks.first.location.latitude,
              filteredBooks.first.location.longitude,
            );
          } else {
            center = const LatLng(23.8103, 90.4125); // Dhaka
          }

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.boichokro',
                  ),
                  // Current location marker
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Book markers
                  MarkerLayer(
                    markers: filteredBooks.map((book) {
                      return Marker(
                        point: LatLng(
                          book.location.latitude,
                          book.location.longitude,
                        ),
                        width: 120,
                        height: 70,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _showBookPreview(book),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  book.mode == BookMode.donate
                                      ? LucideIcons.heartHandshake
                                      : LucideIcons.repeat,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 120,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              // Control buttons
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(28),
                      child: IconButton(
                        onPressed: () async {
                          if (_currentPosition == null) {
                            await _ensureLocationReady();
                          }
                          if (_currentPosition != null && mounted) {
                            // Trigger rebuild to center map on current location
                            setState(() {});
                          }
                        },
                        icon: const Icon(LucideIcons.navigation),
                        tooltip: 'My Location',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(28),
                      child: IconButton(
                        onPressed: () {
                          context.read<BookBloc>().add(const LoadAllBooks());
                        },
                        icon: const Icon(LucideIcons.refreshCcw),
                        tooltip: 'Refresh',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else if (state is BookDetailLoaded) {
          return const SizedBox.shrink();
        } else if (state is BookAdded) {
          return const SizedBox.shrink();
        } else if (state is BookUpdated) {
          return const SizedBox.shrink();
        } else if (state is BookDeleted) {
          return const SizedBox.shrink();
        } else if (state is BookError) {
          final message = state.message;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<BookBloc>().add(const LoadAllBooks());
                  },
                  icon: const Icon(LucideIcons.refreshCcw),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showBookPreview(Book book) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(LucideIcons.book, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${book.author}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(book.mode.displayName),
                            avatar: Icon(
                              book.mode == BookMode.donate
                                  ? LucideIcons.heartHandshake
                                  : LucideIcons.repeat,
                              size: 16,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            label: Text(
                              AppConstants.bookConditions[book.condition],
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/book/${book.id}');
                },
                icon: const Icon(LucideIcons.eye),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (!mounted) return;

    setState(() {}); // Update suffix icon immediately.
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget _buildFilterRow() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            avatar: const Icon(LucideIcons.tags, size: 18),
            label: Text(_filters.genre ?? 'All Genres'),
            selected: _filters.genre != null,
            onSelected: (_) => _selectGenre(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: _isFetchingLocation && !_filters.nearbyOnly
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : const Icon(LucideIcons.mapPin, size: 18),
            label: const Text('Within 5 km'),
            selected: _filters.nearbyOnly,
            onSelected: _isFetchingLocation
                ? null
                : (selected) async => _toggleNearby(selected),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(LucideIcons.heartHandshake, size: 18),
            label: Text(
              _filters.minCondition != null
                  ? '${AppConstants.bookConditions[_filters.minCondition!]}+'
                  : 'All Conditions',
            ),
            selected: _filters.minCondition != null,
            onSelected: (_) => _selectCondition(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(LucideIcons.heartHandshake, size: 18),
            label: const Text('Donate'),
            selected: _filters.mode == BookMode.donate,
            onSelected: (selected) => _toggleDonateOnly(selected),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(LucideIcons.checkCircle, size: 18),
            label: const Text('Available Now'),
            selected: _filters.onlyAvailable,
            onSelected: (selected) => _toggleAvailableOnly(selected),
          ),
        ],
      ),
    );
  }

  Future<void> _selectGenre() async {
    final options = <_Option<String>>[
      const _Option('All Genres', null),
      ...AppConstants.bookGenres.map((genre) => _Option(genre, genre)),
    ];

    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => _SelectionSheet<String>(
        title: 'Select Genre',
        options: options,
        currentValue: _filters.genre,
      ),
    );

    if (!mounted || identical(selected, _filters.genre)) return;
    setState(() {
      _filters = _filters.copyWith(genre: selected);
    });
  }

  Future<void> _selectCondition() async {
    final options = <_Option<int>>[
      const _Option('All Conditions', null),
      for (int index = 0; index < AppConstants.bookConditions.length; index++)
        _Option('${AppConstants.bookConditions[index]} or better', index),
    ];

    final selected = await showModalBottomSheet<int?>(
      context: context,
      builder: (context) => _SelectionSheet<int>(
        title: 'Minimum Condition',
        options: options,
        currentValue: _filters.minCondition,
      ),
    );

    if (!mounted) return;
    setState(() {
      _filters = _filters.copyWith(minCondition: selected);
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
    setState(() {
      _filters = _filters.copyWith(nearbyOnly: selected);
    });
  }

  void _toggleDonateOnly(bool selected) {
    setState(() {
      _filters = _filters.copyWith(mode: selected ? BookMode.donate : null);
    });
  }

  void _toggleAvailableOnly(bool selected) {
    setState(() {
      _filters = _filters.copyWith(onlyAvailable: selected);
    });
  }

  Future<void> _showFilterSheet() async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + MediaQuery.of(sheetContext).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filters',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        setState(() {
                          _filters = const _DiscoverFilters();
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFilterSummaryTile(
                  context: sheetContext,
                  label: 'Genre',
                  value: _filters.genre ?? 'All genres',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _selectGenre();
                  },
                ),
                _buildFilterSummaryTile(
                  context: sheetContext,
                  label: 'Minimum condition',
                  value: _filters.minCondition != null
                      ? '${AppConstants.bookConditions[_filters.minCondition!]} or better'
                      : 'All conditions',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _selectCondition();
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Donate only'),
                  value: _filters.mode == BookMode.donate,
                  onChanged: (value) {
                    Navigator.of(sheetContext).pop();
                    _toggleDonateOnly(value);
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available now'),
                  value: _filters.onlyAvailable,
                  onChanged: (value) {
                    Navigator.of(sheetContext).pop();
                    _toggleAvailableOnly(value);
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Within 5 km'),
                  subtitle: !_filters.nearbyOnly && _currentPosition == null
                      ? const Text(
                          'Location permission requested only when enabled.',
                        )
                      : null,
                  value: _filters.nearbyOnly,
                  onChanged: (value) async {
                    Navigator.of(sheetContext).pop();
                    await _toggleNearby(value);
                  },
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSummaryTile({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: theme.textTheme.titleSmall),
      subtitle: Text(value, style: theme.textTheme.bodyMedium),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: onTap,
    );
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enable location services to see nearby books.'),
            ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission is required to filter within 5 km.',
              ),
            ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not determine your location: $error')),
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

  List<Book> _applyAllFilters(List<Book> books) {
    final withoutOwn = books
        .where(
          (book) => _currentUserId == null || book.ownerId != _currentUserId,
        )
        .toList();
    final searchFiltered = _applySearchFilter(withoutOwn);
    final refined = _applyAdvancedFilters(searchFiltered);

    if (_filters.nearbyOnly && _currentPosition != null) {
      refined.sort((a, b) {
        final aDistance = _computeDistanceMeters(a) ?? double.infinity;
        final bDistance = _computeDistanceMeters(b) ?? double.infinity;
        return aDistance.compareTo(bDistance);
      });
    }

    return refined;
  }

  List<Book> _applySearchFilter(List<Book> books) {
    final query = _searchController.text.trim().toLowerCase();
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

  List<Book> _applyAdvancedFilters(List<Book> books) {
    return books.where((book) {
      if (_filters.genre != null &&
          !book.genres.any(
            (g) => g.toLowerCase() == _filters.genre!.toLowerCase(),
          )) {
        return false;
      }

      if (_filters.minCondition != null &&
          book.condition < _filters.minCondition!) {
        return false;
      }

      if (_filters.mode != null && book.mode != _filters.mode) {
        return false;
      }

      if (_filters.onlyAvailable && book.status != BookStatus.available) {
        return false;
      }

      if (_filters.nearbyOnly) {
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

  String _distanceLabel(Book book) {
    final distance = _computeDistanceMeters(book);
    if (distance == null) {
      return 'Distance';
    }

    if (distance < 1000) {
      return '${distance.round()} m';
    }

    final km = distance / 1000;
    return km >= 10 ? '${km.round()} km' : '${km.toStringAsFixed(1)} km';
  }

  Widget _buildListView() {
    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        // Auto-reload when a book is added (especially important when list was empty)
        if (state is BookAdded) {
          context.read<BookBloc>().add(const LoadAllBooks());
        }
      },
      builder: (context, state) {
        if (state is BookInitial) {
          return const SizedBox.shrink();
        } else if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookLoaded) {
          final books = state.books;
          if (books.isEmpty) {
            return _buildEmptyState();
          }

          final filteredBooks = _applyAllFilters(books);

          if (filteredBooks.isEmpty) {
            return _buildNoResults();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BookBloc>().add(const LoadAllBooks());
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
              itemCount: filteredBooks.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildBookCard(filteredBooks[index]);
              },
            ),
          );
        } else if (state is BookDetailLoaded) {
          return const SizedBox.shrink();
        } else if (state is BookAdded) {
          return const SizedBox.shrink();
        } else if (state is BookUpdated) {
          return const SizedBox.shrink();
        } else if (state is BookDeleted) {
          return const SizedBox.shrink();
        } else if (state is BookError) {
          final message = state.message;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<BookBloc>().add(const LoadAllBooks());
                  },
                  icon: const Icon(LucideIcons.refreshCcw),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.library,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Books Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to add a book!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              _bookBloc.add(const LoadAllBooks());
            },
            icon: const Icon(LucideIcons.refreshCcw),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.searchX,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () {
              // Refresh handled by pull-to-refresh
            },
            icon: const Icon(LucideIcons.filterX),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    final theme = Theme.of(context);
    final isOwner = _currentUserId != null && _currentUserId == book.ownerId;
    final statusBanner = _buildStatusBanner(context, book, isOwner);
    final distanceText = _distanceLabel(book);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/book/${book.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'discover_book_${book.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        width: 90,
                        height: 130,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 90,
                          height: 130,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 90,
                          height: 130,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            LucideIcons.bookOpen,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildSimpleChip(LucideIcons.mapPin, distanceText),
                            _buildSimpleChip(
                              LucideIcons.bookOpen,
                              AppConstants.bookConditions[book.condition],
                            ),
                            _buildSimpleChip(
                              book.mode == BookMode.donate
                                  ? LucideIcons.heartHandshake
                                  : LucideIcons.repeat,
                              book.mode.displayName,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildOwnerSummary(book.ownerId),
                      ],
                    ),
                  ),
                ],
              ),
              if (statusBanner != null) ...[
                const SizedBox(height: 12),
                statusBanner,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleChip(IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(BookStatus status) {
    switch (status) {
      case BookStatus.available:
        return LucideIcons.checkCircle2;
      case BookStatus.pending:
        return LucideIcons.hourglass;
      case BookStatus.requested:
        return LucideIcons.mail;
      case BookStatus.completed:
        return LucideIcons.checkCheck;
    }
  }

  Widget? _buildStatusBanner(BuildContext context, Book book, bool isOwner) {
    if (book.status == BookStatus.available) {
      return null;
    }

    final theme = Theme.of(context);
    late final String message;
    late final Color baseColor;

    switch (book.status) {
      case BookStatus.pending:
        baseColor = isOwner ? theme.colorScheme.primary : Colors.orange;
        message = isOwner
            ? 'Exchange in progress. Tap to review messages and confirm handoff.'
            : 'Currently in exchange. Check back soon to see if it becomes available again.';
        break;
      case BookStatus.requested:
        baseColor = Colors.amber;
        message = isOwner
            ? 'You have incoming requests waiting for review.'
            : 'Owner is reviewing requests for this book.';
        break;
      case BookStatus.completed:
        baseColor = Colors.blueGrey;
        message = isOwner
            ? 'Exchange completed. Consider relisting when the book returns.'
            : 'Exchange completed. See similar books for your next read.';
        break;
      case BookStatus.available:
        return null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_statusIcon(book.status), color: baseColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: baseColor),
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
        final theme = Theme.of(context);
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final user = snapshot.data;
        final displayName =
            user?.name ?? (isLoading ? 'Loading owner...' : 'Unknown owner');
        final rating = user?.ratingAvg ?? 0;
        final showRating = !isLoading && rating > 0;
        final swaps = user?.totalSwaps ?? 0;
        final photoUrl = user?.photoUrl;
        final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

        return Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: hasPhoto
                  ? CachedNetworkImageProvider(photoUrl)
                  : null,
              child: hasPhoto ? null : const Icon(LucideIcons.user, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user?.verifiedBadge == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            LucideIcons.badgeCheck,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  if (showRating) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall,
                        ),
                        if (swaps > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '$swaps swaps',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
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

class _Option<T> {
  const _Option(this.label, this.value);

  final String label;
  final T? value;
}

class _SelectionSheet<T> extends StatelessWidget {
  const _SelectionSheet({
    required this.title,
    required this.options,
    required this.currentValue,
  });

  final String title;
  final List<_Option<T>> options;
  final T? currentValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected =
                    option.value == currentValue ||
                    (option.value == null && currentValue == null);
                return ListTile(
                  title: Text(option.label),
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(option.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
