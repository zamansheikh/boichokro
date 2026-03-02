import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/book.dart';
import '../../../library/domain/entities/request.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../../library/domain/usecases/get_request_by_id_usecase.dart';

import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';
import '../../../chats/presentation/bloc/chat_bloc.dart';
import '../../../chats/presentation/bloc/chat_event.dart';
import '../../../chats/presentation/bloc/chat_state.dart';
import '../bloc/request/request_bloc.dart';
import '../bloc/request/request_event.dart';
import '../bloc/request/request_state.dart';
import '../../../library/presentation/widgets/request_timeline_widget.dart';

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
  Future<BookRequest?>? _activeRequestFuture;
  Book? _currentBook;
  List<BookRequest> _requestsForBook = [];
  bool _requestListLoading = false;
  String? _requestListError;
  late final GetUserByIdUseCase _getUserByIdUseCase;
  final Map<String, Future<User?>> _userCache = {};
  Position? _cachedPosition; // for distance calculation;

  @override
  void initState() {
    super.initState();
    _bookBloc = getIt<BookBloc>()..add(LoadBookById(widget.bookId));
    _requestBloc = getIt<RequestBloc>();
    _getUserByIdUseCase = getIt<GetUserByIdUseCase>();
  }

  @override
  void dispose() {
    _bookBloc.close();
    _requestBloc.close();
    super.dispose();
  }

  /// Returns a human-readable distance label between the user and a book.
  /// Falls back to a coordinate-based label if location permission is unavailable.
  String _getDistanceLabel(Book book) {
    final pos = _cachedPosition;
    if (pos == null) {
      _fetchLocation();
      return '— km away';
    }
    final distanceMeters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      book.location.latitude,
      book.location.longitude,
    );
    final km = distanceMeters / 1000;
    if (km < 1) return '${distanceMeters.round()} m away';
    return '${km.toStringAsFixed(1)} km away';
  }

  void _fetchLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      if (mounted) setState(() => _cachedPosition = pos);
    } catch (_) {}
  }

  String? get _currentUserId => getIt<FirebaseService>().auth.currentUser?.uid;

  bool _isOwnerOf(Book book) {
    final currentUserId = _currentUserId;
    return currentUserId != null && currentUserId == book.ownerId;
  }

  bool _isOwnerViewingCurrentBook() {
    final book = _currentBook;
    if (book == null) return false;
    return _isOwnerOf(book);
  }

  void _onBookLoaded(Book book) {
    if (!mounted) return;
    final currentUserId = _currentUserId;
    final bool isOwner = currentUserId != null && currentUserId == book.ownerId;
    final bool bookChanged = _currentBook?.id != book.id;
    final String? activeId = book.activeRequestId;

    Future<BookRequest?>? nextActiveFuture;
    if (activeId != null && activeId.isNotEmpty) {
      nextActiveFuture = _loadActiveRequest(activeId);
    } else {
      nextActiveFuture = null;
    }

    setState(() {
      _currentBook = book;
      _activeRequestFuture = nextActiveFuture;

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
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bookBloc),
        BlocProvider.value(value: _requestBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<BookBloc, BookState>(
            listener: (context, state) {
              if (state is BookDetailLoaded) {
                _onBookLoaded(state.book);
              } else if (state is BookUpdated) {
                _onBookLoaded(state.book);
              } else if (state is BookAdded) {
                _onBookLoaded(state.book);
              }
            },
          ),
          BlocListener<RequestBloc, RequestState>(
            listener: (context, state) {
              if (!mounted || !_isOwnerViewingCurrentBook()) return;

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
            },
          ),
        ],
        child: Scaffold(
          body: BlocBuilder<BookBloc, BookState>(
            builder: (context, state) {
              if (state is BookInitial) {
                return const SizedBox.shrink();
              } else if (state is BookLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BookLoaded) {
                return const Center(child: Text('Book not found'));
              } else if (state is BookDetailLoaded) {
                final book = state.book;
                return _buildBookDetail(context, book);
              } else if (state is BookAdded) {
                final book = state.book;
                return _buildBookDetail(context, book);
              } else if (state is BookUpdated) {
                final book = state.book;
                return _buildBookDetail(context, book);
              } else if (state is BookDeleted) {
                return const Center(child: Text('Book deleted'));
              } else if (state is BookError) {
                final message = state.message;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookDetail(BuildContext context, Book book) {
    final bool isOwner = _isOwnerOf(book);
    return CustomScrollView(
      slivers: [
        // App Bar with Book Cover
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.book, size: 100),
                  ),
                ),
                // Overlay gradient for better visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  final shareText =
                      '📚 ${book.title} by ${book.author}\n'
                      'Mode: ${book.mode.displayName}\n'
                      'Condition: ${AppConstants.bookConditions[book.condition]}\n'
                      '\nFind it on Boichokro!';
                  SharePlus.instance.share(ShareParams(text: shareText));
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showMoreOptions(context, book),
              ),
            ),
          ],
        ),

        // Book Information
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Author
                Text(
                  'by ${book.author}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Metadata Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      context,
                      Icons.auto_stories,
                      AppConstants.bookConditions[book.condition],
                      _getConditionColor(book.condition),
                    ),
                    _buildInfoChip(
                      context,
                      book.mode == BookMode.donate
                          ? Icons.card_giftcard
                          : Icons.swap_horiz,
                      book.mode.displayName,
                      book.mode == BookMode.donate
                          ? Colors.orange
                          : Colors.blue,
                    ),
                    _buildInfoChip(
                      context,
                      Icons.location_on,
                      _getDistanceLabel(book),
                      Colors.blueGrey,
                    ),
                    _buildInfoChip(
                      context,
                      Icons.circle,
                      book.status.displayName,
                      book.status == BookStatus.available
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ISBN (if available)
                if (book.isbn != null) ...[
                  _buildSection(
                    context,
                    'ISBN',
                    Text(
                      book.isbn!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Genres
                if (book.genres.isNotEmpty) ...[
                  _buildSection(
                    context,
                    'Genres',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: book.genres
                          .map((genre) => Chip(label: Text(genre)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                if (book.description != null &&
                    book.description!.isNotEmpty) ...[
                  _buildSection(
                    context,
                    'Description',
                    Text(
                      book.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const Divider(),
                const SizedBox(height: 16),

                // Owner Section
                Text(
                  'Owner',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildOwnerTile(context, book),

                const SizedBox(height: 24),

                if (isOwner) ...[
                  _buildOwnerRequestsSection(context, book),
                  const SizedBox(height: 24),
                ],

                // Don't show Exchange Status separately - it's included in Incoming Requests section with timeline
                // if (_activeRequestFuture != null) ...[
                //   _buildActiveRequestCard(context, book),
                //   const SizedBox(height: 24),
                // ],

                // Action Buttons
                if (!isOwner && book.status == BookStatus.available) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _handleRequestBook(context, book),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: Icon(
                        book.mode == BookMode.donate
                            ? Icons.card_giftcard
                            : Icons.swap_horiz,
                      ),
                      label: Text(
                        book.mode == BookMode.donate
                            ? 'Request Book'
                            : 'Exchange Book',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleMessageOwner(context, book),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'Message Owner',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isOwner
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.08)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isOwner
                              ? Theme.of(context).colorScheme.primary
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isOwner
                                ? 'This book is currently ${book.status.displayName.toLowerCase()}. Manage exchange progress below.'
                                : 'This book is currently ${book.status.displayName.toLowerCase()}',
                            style: TextStyle(
                              color: isOwner
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildOwnerRequestsSection(BuildContext context, Book book) {
    final theme = Theme.of(context);
    final requests = _requestsForBook;
    final isLoading = _requestListLoading;
    final errorMessage = _requestListError;

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Incoming Requests',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isLoading && requests.isNotEmpty)
          const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );

    Widget buildInfoCard({
      required IconData icon,
      required Color color,
      required String message,
      Widget? trailing,
    }) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
          ],
        ),
      );
    }

    final content = <Widget>[header, const SizedBox(height: 12)];

    if (isLoading && requests.isEmpty) {
      content.add(
        buildInfoCard(
          icon: Icons.sync,
          color: theme.colorScheme.primary,
          message: 'Loading latest requests...',
        ),
      );
    } else if (errorMessage != null && requests.isEmpty) {
      content.add(
        buildInfoCard(
          icon: Icons.error_outline,
          color: Colors.red,
          message: errorMessage,
          trailing: TextButton(
            onPressed: () => _requestBloc.add(LoadRequestsForBook(book.id)),
            child: const Text('Retry'),
          ),
        ),
      );
    } else if (requests.isEmpty) {
      content.add(
        buildInfoCard(
          icon: Icons.inbox_outlined,
          color: theme.colorScheme.primary,
          message: 'No requests yet. Readers can find your book in Discover.',
        ),
      );
    } else {
      if (errorMessage != null) {
        content.add(
          buildInfoCard(
            icon: Icons.error_outline,
            color: Colors.red,
            message: errorMessage,
            trailing: TextButton(
              onPressed: () => _requestBloc.add(LoadRequestsForBook(book.id)),
              child: const Text('Retry'),
            ),
          ),
        );
        content.add(const SizedBox(height: 12));
      }

      // Show pending requests and accepted requests in "Incoming Requests"
      // The active request will show here with timeline, then also in "Exchange Status" below
      final displayRequests = requests
          .where(
            (r) =>
                r.status == RequestStatus.pending ||
                r.status == RequestStatus.accepted,
          )
          .toList();

      for (final request in displayRequests) {
        content
          ..add(_buildOwnerRequestTile(context, request, book))
          ..add(const SizedBox(height: 12));
      }

      if (isLoading) {
        content.add(
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        );
      }
    }

    if (content.isNotEmpty && content.last is SizedBox) {
      // remove trailing spacing if present
      content.removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }

  Widget _buildOwnerRequestTile(
    BuildContext context,
    BookRequest request,
    Book book,
  ) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(request.status);
    final bool isPending = request.status == RequestStatus.pending;
    final bool isAccepted = request.status == RequestStatus.accepted;

    return FutureBuilder<User?>(
      future:
          _userCache[request.seekerId] ??
          (() {
            final result = _getUserByIdUseCase(
              GetUserByIdParams(request.seekerId),
            );
            _userCache[request.seekerId] = result.then(
              (r) => r.fold((_) => null, (user) => user),
            );
            return _userCache[request.seekerId]!;
          })(),
      builder: (context, userSnapshot) {
        final seeker = userSnapshot.data;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Requester Info + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor.withValues(alpha: 0.2),
                    child:
                        seeker?.photoUrl != null && seeker!.photoUrl!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: seeker.photoUrl!,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                          )
                        : Icon(Icons.person, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request from',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          seeker?.name ?? 'Unknown User',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPending
                              ? Icons.schedule
                              : isAccepted
                              ? Icons.check_circle
                              : Icons.done_all,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          request.status.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dates
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requested on ${_formatDate(request.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              if (request.acceptedAt != null) ...[const SizedBox(height: 8)],
              if (request.acceptedAt != null)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Accepted on ${_formatDate(request.acceptedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Timeline
              RequestTimelineWidget(request: request, isSeeker: false),
              const SizedBox(height: 16),
              // Action Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (isPending)
                    FilledButton.icon(
                      onPressed: () async {
                        final confirmed = await _showConfirmationDialog(
                          context,
                          title: 'Accept request?',
                          message:
                              'This will accept the request and open a chat so you can coordinate the exchange.',
                          confirmLabel: 'Accept request',
                        );
                        if (!confirmed || !context.mounted) return;
                        _handleOwnerRequestAction(
                          context,
                          request,
                          RequestStatus.accepted,
                          progressLabel: 'Accepting request...',
                          successMessage:
                              'Request accepted. A chat has been opened for coordination.',
                        );
                      },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (isPending)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await _showConfirmationDialog(
                          context,
                          title: 'Decline request?',
                          message:
                              'Declined requests will notify the reader and free up your book.',
                          confirmLabel: 'Decline',
                          confirmColor: Colors.red,
                        );
                        if (!confirmed || !context.mounted) return;
                        _handleOwnerRequestAction(
                          context,
                          request,
                          RequestStatus.declined,
                          progressLabel: 'Declining request...',
                          successMessage: 'Request declined.',
                          successColor: Colors.orange,
                        );
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (!isPending && request.chatRoomId != null)
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '${RoutePaths.chat}/${request.chatRoomId}',
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Continue Chat'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (isAccepted && !request.ownerConfirmed)
                    FilledButton.icon(
                      onPressed: () => _handleConfirmExchange(context, request),
                      icon: const Icon(Icons.verified, size: 18),
                      label: const Text('Confirm Exchange'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.completed:
        return Colors.green;
      case RequestStatus.declined:
        return Colors.red.shade400;
      case RequestStatus.cancelled:
        return Colors.grey;
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: confirmColor != null
                ? FilledButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
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
    BuildContext context,
    BookRequest request,
    RequestStatus status, {
    required String progressLabel,
    required String successMessage,
    Color successColor = Colors.green,
  }) {
    _requestBloc.add(
      UpdateRequestStatus(requestId: request.id, status: status),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: _requestBloc,
        child: BlocConsumer<RequestBloc, RequestState>(
          listener: (context, state) {
            if (state is RequestUpdated) {
              final updatedRequest = state.request;
              if (updatedRequest.id != request.id) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: successColor,
                ),
              );
            } else if (state is RequestError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update request: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    progressLabel,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleConfirmExchange(BuildContext context, BookRequest request) {
    final currentUser = getIt<FirebaseService>().auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to confirm the exchange.'),
        ),
      );
      return;
    }

    _requestBloc.add(
      ConfirmExchange(requestId: request.id, userId: currentUser.uid),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: _requestBloc,
        child: BlocConsumer<RequestBloc, RequestState>(
          listener: (context, state) {
            if (state is RequestUpdated) {
              final updatedRequest = state.request;
              Navigator.pop(dialogContext);
              if (!mounted) return;
              setState(() {
                _activeRequestFuture = Future.value(updatedRequest);
              });
              _bookBloc.add(LoadBookById(widget.bookId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exchange confirmation recorded.'),
                ),
              );
            } else if (state is RequestError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to confirm exchange: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Confirming exchange...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<BookRequest?> _loadActiveRequest(String requestId) async {
    final useCase = getIt<GetRequestByIdUseCase>();
    final result = await useCase(GetRequestByIdParams(requestId));
    return result.fold((_) => null, (request) => request);
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute';
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerTile(BuildContext context, Book book) {
    final future = _getUserFuture(book.ownerId);
    return FutureBuilder<User?>(
      future: future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final user = snapshot.data;
        final displayName =
            user?.name ?? (isLoading ? 'Loading owner...' : 'Unknown owner');
        final rating = user?.ratingAvg ?? 0;
        final swaps = user?.totalSwaps ?? 0;
        final subtitleWidget = isLoading
            ? const Text('Fetching owner details...')
            : user != null
            ? Row(
                children: [
                  if (rating > 0) ...[
                    Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    swaps > 0 ? '$swaps swaps' : 'New to swaps',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              )
            : const Text('Owner details unavailable');

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _buildUserAvatar(user, radius: 28),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user?.verifiedBadge == true)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.verified,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
          subtitle: subtitleWidget,
          onTap: user != null
              ? () {
                  // Show a small info sheet about the owner
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          _buildUserAvatar(
                            user,
                            radius: 32,
                            fallback: Icons.person,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '⭐ ${user.ratingAvg.toStringAsFixed(1)}   '
                            '${user.totalSwaps} swaps',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }

  Widget _buildUserAvatar(
    User? user, {
    required double radius,
    IconData fallback = Icons.person,
  }) {
    final photoUrl = user?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundImage: hasPhoto ? CachedNetworkImageProvider(photoUrl) : null,
      child: hasPhoto ? null : Icon(fallback, size: radius),
    );
  }

  Future<User?> _getUserFuture(String userId) {
    return _userCache[userId] ??= _fetchUser(userId);
  }

  Future<User?> _fetchUser(String userId) async {
    final result = await _getUserByIdUseCase(GetUserByIdParams(userId));
    return result.fold((_) => null, (user) => user);
  }

  Color _getConditionColor(int condition) {
    switch (condition) {
      case 0: // Like New
        return Colors.green;
      case 1: // Very Good
        return Colors.lightGreen;
      case 2: // Good
        return Colors.amber;
      case 3: // Fair
        return Colors.orange;
      case 4: // Worn
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showMoreOptions(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Book'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final userId = _currentUserId;
                if (userId == null) return;
                try {
                  await getIt<FirebaseService>().firestore
                      .collection('reports')
                      .add({
                        'reporterId': userId,
                        'bookId': book.id,
                        'ownerId': book.ownerId,
                        'createdAt': FieldValue.serverTimestamp(),
                        'type': 'book',
                      });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Book reported. Thank you!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to report: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block Owner'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final userId = _currentUserId;
                if (userId == null) return;
                try {
                  await getIt<FirebaseService>().firestore
                      .collection(FirebaseConstants.usersCollection)
                      .doc(userId)
                      .update({
                        'blockedUsers': FieldValue.arrayUnion([book.ownerId]),
                      });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User blocked.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to block: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save to Wishlist'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final userId = _currentUserId;
                if (userId == null) return;
                try {
                  await getIt<FirebaseService>().firestore
                      .collection(FirebaseConstants.usersCollection)
                      .doc(userId)
                      .update({
                        'wishlist': FieldValue.arrayUnion([book.id]),
                      });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved to wishlist! ❤️'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleRequestBook(BuildContext context, Book book) {
    final currentUser = getIt<FirebaseService>().auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to request books')),
      );
      return;
    }

    // Check if user is trying to request their own book
    if (currentUser.uid == book.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot request your own book')),
      );
      return;
    }

    if (book.mode == BookMode.exchange) {
      // Show dialog to select a book to exchange
      _showExchangeBookSelector(context, book, currentUser.uid);
    } else {
      // Donate mode - direct request
      _showDonateRequestDialog(context, book, currentUser.uid);
    }
  }

  void _showExchangeBookSelector(
    BuildContext context,
    Book requestedBook,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: BlocProvider(
          create: (context) => getIt<BookBloc>()..add(LoadMyBooks(userId)),
          child: BlocBuilder<BookBloc, BookState>(
            builder: (context, state) {
              if (state is BookInitial) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('Initializing...')),
                );
              } else if (state is BookLoading) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is BookLoaded) {
                final books = state.books;
                // Filter available books only
                final availableBooks = books
                    .where((book) => book.status == BookStatus.available)
                    .toList();

                if (availableBooks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.library_books,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Available Books',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You need to add at least one available book to exchange.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                context.push(RoutePaths.addBook);
                              },
                              child: const Text('Add Book'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Select Book to Exchange',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(dialogContext),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose one of your books to offer in exchange for "${requestedBook.title}"',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableBooks.length,
                        itemBuilder: (context, index) {
                          final book = availableBooks[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: book.coverUrl,
                                width: 40,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book, size: 20),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book, size: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              _createExchangeRequest(
                                context,
                                requestedBook,
                                book,
                                userId,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is BookError) {
                final message = state.message;
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showDonateRequestDialog(
    BuildContext context,
    Book book,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Would you like to request "${book.title}" from the owner?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is a donation. No exchange required!',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _createDonateRequest(context, book, userId);
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _createExchangeRequest(
    BuildContext context,
    Book requestedBook,
    Book offeredBook,
    String userId,
  ) {
    final requestBloc = _requestBloc;

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

    requestBloc.add(CreateRequest(request));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: requestBloc,
        child: BlocConsumer<RequestBloc, RequestState>(
          listener: (context, state) {
            if (state is RequestCreated) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Exchange request sent! Offering "${offeredBook.title}" for "${requestedBook.title}"',
                  ),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Navigate to requests page
                    },
                  ),
                ),
              );
            } else if (state is RequestError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to send request: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Sending exchange request...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _createDonateRequest(
    BuildContext context,
    Book requestedBook,
    String userId,
  ) {
    final requestBloc = _requestBloc;

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

    requestBloc.add(CreateRequest(request));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: requestBloc,
        child: BlocConsumer<RequestBloc, RequestState>(
          listener: (context, state) {
            if (state is RequestCreated) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request sent for "${requestedBook.title}"!'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Navigate to requests page
                    },
                  ),
                ),
              );
            } else if (state is RequestError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to send request: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Sending request...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleMessageOwner(BuildContext context, Book book) async {
    final currentUser = getIt<FirebaseService>().auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to message the owner')),
      );
      return;
    }

    // Check if user is trying to message themselves
    if (currentUser.uid == book.ownerId) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This is your own book')));
      return;
    }

    // Fetch owner and requester names
    final ownerFuture = _getUserFuture(book.ownerId);
    final requesterFuture = _getUserFuture(currentUser.uid);

    final results = await Future.wait([ownerFuture, requesterFuture]);
    final ownerUser = results[0];
    final requesterUser = results[1];

    final ownerName = ownerUser?.name ?? 'Owner';
    final requesterName =
        requesterUser?.name ?? currentUser.email?.split('@').first ?? 'User';

    final chatBloc = getIt<ChatBloc>();

    // Create or get existing chat room with the book owner and book context
    final participantIds = [currentUser.uid, book.ownerId]..sort();

    showDialog(
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
        child: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatInitial) {
              // Initial state
            } else if (state is ChatLoading) {
              // Loading state
            } else if (state is ChatRoomLoaded) {
              Navigator.pop(dialogContext);
              // Navigate to home page with chat tab (index 2)
              context.go(RoutePaths.home, extra: {'initialIndex': 2});

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat created for ${book.title}'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            } else if (state is ChatError) {
              final message = state.message;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create chat: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ChatRoomsLoaded) {
              // Chat rooms loaded
            } else if (state is MessagesLoaded) {
              // Messages loaded
            } else if (state is MessageSent) {
              // Message sent
            } else if (state is NewMessage) {
              // New message
            } else if (state is MarkedAsRead) {
              // Marked as read
            }
          },
          builder: (context, state) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Creating chat...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
