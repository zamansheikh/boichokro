import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../discover/domain/entities/book.dart';
import '../../../discover/domain/entities/user.dart';
import '../../domain/entities/request.dart';
import '../../../discover/domain/usecases/book_usecases.dart';
import '../../../discover/domain/usecases/user_usecases.dart';
import '../../../discover/presentation/bloc/book/book_bloc.dart';
import '../../../discover/presentation/bloc/book/book_event.dart';
import '../../../discover/presentation/bloc/book/book_state.dart';
import '../../../discover/presentation/bloc/request/request_bloc.dart';
import '../../../discover/presentation/bloc/request/request_event.dart';
import '../../../discover/presentation/bloc/request/request_state.dart';
import '../widgets/request_timeline_widget.dart';

/// My Library Page with 4 tabs: My Books, My Requests, Requests to Me, History
class MyLibraryPage extends StatefulWidget {
  final int initialTabIndex;
  const MyLibraryPage({super.key, this.initialTabIndex = 0});

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late BookBloc _bookBloc;
  late RequestBloc _requestBloc;
  String? _currentUserId;

  // Caches
  final Map<String, Future<Book?>> _bookCache = {};
  final Map<String, Future<User?>> _userCache = {};

  late final GetBookByIdUseCase _getBookByIdUseCase;
  late final GetUserByIdUseCase _getUserByIdUseCase;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    _requestBloc = getIt<RequestBloc>();
    _getBookByIdUseCase = getIt<GetBookByIdUseCase>();
    _getUserByIdUseCase = getIt<GetUserByIdUseCase>();

    final currentUser = getIt<FirebaseService>().auth.currentUser;
    _currentUserId = currentUser?.uid;

    if (currentUser != null) {
      _bookBloc = getIt<BookBloc>()..add(LoadMyBooks(currentUser.uid));
      // Load both seeker and owner requests in a single call
      // This prevents race conditions between the two request types
      _requestBloc.add(LoadMyIncomingRequests(currentUser.uid));
    } else {
      _bookBloc = getIt<BookBloc>();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookBloc.close();
    _requestBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bookBloc),
        BlocProvider.value(value: _requestBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('My Library'),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCcw),
              onPressed: _refreshAll,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildModernTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyBooksTab(),
                  _buildMyRequestsTab(),
                  _buildRequestsToMeTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicator: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'My Books'),
          Tab(text: 'My Requests'),
          Tab(text: 'Requests to Me'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  // ========== TAB 1: MY BOOKS ==========
  Widget _buildMyBooksTab() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookLoaded) {
          final myBooks = state.books
              .where((b) => b.ownerId == _currentUserId)
              .toList();

          if (myBooks.isEmpty) {
            return _buildEmptyState(
              icon: LucideIcons.library,
              title: 'No Books Yet',
              subtitle: 'Add your first book to start exchanging',
              actionLabel: 'Add Book',
              onAction: () => context.push(RoutePaths.addBook),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: myBooks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) => _buildMyBookCard(myBooks[index]),
            ),
          );
        } else if (state is BookError) {
          return _buildErrorState(state.message, _refreshAll);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMyBookCard(Book book) {
    final theme = Theme.of(context);
    final isAvailable = book.status == BookStatus.available;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
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
                    tag: 'library_book_${book.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            LucideIcons.book,
                            size: 32,
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
                          'Author: ${book.author}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildChip(
                              LucideIcons.bookOpen,
                              'Condition: ${AppConstants.bookConditions[book.condition]}',
                            ),
                            _buildChip(
                              book.mode == BookMode.donate
                                  ? LucideIcons.heartHandshake
                                  : LucideIcons.repeat,
                              book.mode.displayName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(LucideIcons.moreVertical),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: isAvailable,
                        child: const Row(
                          children: [
                            Icon(LucideIcons.pencil),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            context.push('/book/${book.id}/edit', extra: book);
                          });
                        },
                      ),
                      PopupMenuItem(
                        enabled: isAvailable,
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.trash2,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                        onTap: () => _confirmDeleteBook(book),
                      ),
                    ],
                  ),
                ],
              ),
              if (book.status != BookStatus.available) ...[
                const SizedBox(height: 12),
                _buildBookStatusBanner(book),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookStatusBanner(Book book) {
    final theme = Theme.of(context);
    IconData icon;
    String message;
    Color color;

    switch (book.status) {
      case BookStatus.pending:
        icon = LucideIcons.hourglass;
        message = 'Exchange in progress';
        color = Colors.orange;
        break;
      case BookStatus.completed:
        icon = LucideIcons.checkCircle2;
        message = 'Exchange completed';
        color = Colors.green;
        break;
      case BookStatus.requested:
        icon = LucideIcons.mailOpen;
        message = 'Has pending requests';
        color = Colors.blue;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/book/${book.id}'),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBook(Book book) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Book'),
          content: Text('Are you sure you want to delete "${book.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _bookBloc.add(DeleteBook(book.id));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Book deleted')));
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    });
  }

  // ========== TAB 2: MY REQUESTS ==========
  Widget _buildMyRequestsTab() {
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RequestLoaded) {
          final myRequests = state.requests
              .where(
                (r) =>
                    r.seekerId == _currentUserId &&
                    r.status != RequestStatus.completed &&
                    r.status != RequestStatus.declined &&
                    r.status != RequestStatus.cancelled,
              )
              .toList();

          if (myRequests.isEmpty) {
            return _buildEmptyState(
              icon: LucideIcons.arrowUpRight,
              title: 'No Active Requests',
              subtitle: 'Books you request from others will appear here',
              actionLabel: 'Discover Books',
              onAction: () => context.go(RoutePaths.home),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: myRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) =>
                  _buildMyRequestCard(myRequests[index]),
            ),
          );
        } else if (state is RequestError) {
          return _buildErrorState(state.message, _refreshAll);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMyRequestCard(BookRequest request) {
    return FutureBuilder<Book?>(
      future: _bookCache[request.bookId] ??= _fetchBook(request.bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final book = snapshot.data;
        if (book == null) return const SizedBox.shrink();

        final theme = Theme.of(context);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book info row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            'Author: ${book.author}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<User?>(
                            future: _userCache[request.ownerId] ??= _fetchUser(
                              request.ownerId,
                            ),
                            builder: (ctx, userSnap) {
                              final owner = userSnap.data;
                              return Text(
                                'Owner: ${owner?.name ?? 'Loading...'}',
                                style: theme.textTheme.bodySmall,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildStatusChip(request.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RequestTimelineWidget(request: request, isSeeker: true),
                const SizedBox(height: 12),
                // Show Confirm Exchange button for accepted requests
                if (request.status == RequestStatus.accepted &&
                    !request.seekerConfirmed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.info,
                              size: 18,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Exchange approved! Confirm once you receive the book.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              request.ownerConfirmed
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.circle,
                              size: 16,
                              color: request.ownerConfirmed
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Owner: ${request.ownerConfirmed ? "Confirmed ✓" : "Pending"}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              request.seekerConfirmed
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.circle,
                              size: 16,
                              color: request.seekerConfirmed
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'You: ${request.seekerConfirmed ? "Confirmed ✓" : "Pending"}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _confirmExchange(request, true),
                            icon: const Icon(LucideIcons.badgeCheck, size: 18),
                            label: const Text('Confirm Exchange'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.push('/book/${book.id}'),
                        icon: const Icon(LucideIcons.eye, size: 18),
                        label: const Text('View\nDetails'),
                      ),
                    ),
                    if (request.chatRoomId != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '${RoutePaths.chat}/${request.chatRoomId}',
                          ),
                          icon: const Icon(LucideIcons.messageSquare, size: 18),
                          label: const Text('Open\nChat'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== TAB 3: REQUESTS TO ME ==========
  Widget _buildRequestsToMeTab() {
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RequestLoaded) {
          // Filter for requests where current user is the OWNER
          final requestsToMe = state.requests
              .where(
                (r) =>
                    r.ownerId == _currentUserId &&
                    r.status != RequestStatus.completed &&
                    r.status != RequestStatus.declined &&
                    r.status != RequestStatus.cancelled,
              )
              .toList();

          // If no requests in the seeker filter, that's OK - this tab shows incoming
          if (requestsToMe.isEmpty) {
            return _buildEmptyState(
              icon: LucideIcons.inbox,
              title: 'No Incoming Requests',
              subtitle: 'Requests from other users will appear here',
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: requestsToMe.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) =>
                  _buildRequestToMeCard(requestsToMe[index]),
            ),
          );
        } else if (state is RequestError) {
          return _buildErrorState(state.message, _refreshAll);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRequestToMeCard(BookRequest request) {
    return FutureBuilder2<Book?, User?>(
      future1: _bookCache[request.bookId] ??= _fetchBook(request.bookId),
      future2: _userCache[request.seekerId] ??= _fetchUser(request.seekerId),
      builder: (context, book, seeker) {
        if (book == null || seeker == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final theme = Theme.of(context);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Requester info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          (seeker.photoUrl != null &&
                              seeker.photoUrl!.isNotEmpty)
                          ? CachedNetworkImageProvider(seeker.photoUrl!)
                          : null,
                      child:
                          (seeker.photoUrl == null || seeker.photoUrl!.isEmpty)
                          ? const Icon(LucideIcons.user)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requested By:',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            seeker.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(request.status),
                  ],
                ),
                const Divider(height: 24),
                // Book info
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requested Book:',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
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
                            'Author: ${book.author}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RequestTimelineWidget(request: request, isSeeker: false),
                const SizedBox(height: 16),
                // Show Confirm Exchange button for accepted requests
                if (request.status == RequestStatus.accepted &&
                    !request.ownerConfirmed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Confirm once you have handed over the book.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              request.ownerConfirmed
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.circle,
                              size: 16,
                              color: request.ownerConfirmed
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'You: ${request.ownerConfirmed ? "Confirmed ✓" : "Pending"}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              request.seekerConfirmed
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.circle,
                              size: 16,
                              color: request.seekerConfirmed
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Requester: ${request.seekerConfirmed ? "Confirmed ✓" : "Pending"}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _confirmExchange(request, false),
                            icon: const Icon(LucideIcons.badgeCheck, size: 18),
                            label: const Text('Confirm Exchange'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (request.status == RequestStatus.pending)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            _requestBloc.add(
                              UpdateRequestStatus(
                                requestId: request.id,
                                status: RequestStatus.accepted,
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.check, size: 18),
                          label: const Text('Approve'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _requestBloc.add(
                              UpdateRequestStatus(
                                requestId: request.id,
                                status: RequestStatus.declined,
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.x, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (request.chatRoomId != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        '${RoutePaths.chat}/${request.chatRoomId}',
                      ),
                      icon: const Icon(LucideIcons.messageSquare, size: 18),
                      label: const Text('Open Chat'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== TAB 4: HISTORY ==========
  Widget _buildHistoryTab() {
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RequestLoaded) {
          final history = state.requests
              .where(
                (r) =>
                    r.status == RequestStatus.completed ||
                    r.status == RequestStatus.declined ||
                    r.status == RequestStatus.cancelled,
              )
              .toList();

          if (history.isEmpty) {
            return _buildEmptyState(
              icon: Icons.history_outlined,
              title: 'No History',
              subtitle:
                  'Your completed and cancelled exchanges will appear here',
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) => _buildHistoryCard(history[index]),
            ),
          );
        } else if (state is RequestError) {
          return _buildErrorState(state.message, _refreshAll);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHistoryCard(BookRequest request) {
    return FutureBuilder<Book?>(
      future: _bookCache[request.bookId] ??= _fetchBook(request.bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final book = snapshot.data;
        if (book == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final isSeeker = request.seekerId == _currentUserId;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            'Author: ${book.author}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          _buildStatusChip(request.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (request.status == RequestStatus.completed) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildReviewSection(request, isSeeker),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewSection(BookRequest request, bool isSeeker) {
    final theme = Theme.of(context);
    final myRating = isSeeker ? request.seekerRating : request.ownerRating;
    final myReview = isSeeker ? request.seekerReview : request.ownerReview;
    final theirRating = isSeeker ? request.ownerRating : request.seekerRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (myRating != null) ...[
          Text(
            'Your Review:',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBarIndicator(
                rating: myRating,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20,
              ),
              const SizedBox(width: 8),
              Text(
                myRating.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (myReview != null && myReview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(myReview, style: theme.textTheme.bodyMedium),
          ],
        ] else ...[
          FilledButton.tonalIcon(
            onPressed: () {
              _showReviewDialog(request, isSeeker);
            },
            icon: const Icon(Icons.star_outline, size: 18),
            label: const Text('Give Review'),
          ),
        ],
        if (theirRating != null) ...[
          const SizedBox(height: 12),
          Text(
            'Their Review:',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBarIndicator(
                rating: theirRating,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20,
              ),
              const SizedBox(width: 8),
              Text(
                theirRating.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showReviewDialog(BookRequest request, bool isSeeker) {
    var rating = 5.0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate your experience:'),
            const SizedBox(height: 12),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (r) => rating = r,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                labelText: 'Write your review (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final currentUserId = _currentUserId;
              if (currentUserId == null) return;
              _requestBloc.add(
                SubmitReview(
                  requestId: request.id,
                  reviewerId: currentUserId,
                  rating: rating,
                  reviewText: reviewController.text.trim(),
                ),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review submitted! Thank you.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // ========== HELPER WIDGETS ==========
  Widget _buildChip(IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildStatusChip(RequestStatus status) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;

    switch (status) {
      case RequestStatus.pending:
        color = Colors.orange;
        icon = LucideIcons.clock;
        break;
      case RequestStatus.accepted:
        color = Colors.blue;
        icon = LucideIcons.checkCircle2;
        break;
      case RequestStatus.declined:
        color = Colors.red;
        icon = LucideIcons.xCircle;
        break;
      case RequestStatus.cancelled:
        color = Colors.grey;
        icon = LucideIcons.ban;
        break;
      case RequestStatus.completed:
        color = Colors.green;
        icon = LucideIcons.badgeCheck;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCcw),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== HELPER METHODS ==========
  Future<void> _refreshAll() async {
    final userId = _currentUserId;
    if (userId != null) {
      _bookBloc.add(LoadMyBooks(userId));
      // Load both seeker requests and owner requests in a single call
      // LoadMyIncomingRequests now handles loading both types of requests
      _requestBloc.add(LoadMyIncomingRequests(userId));
    }
  }

  void _confirmExchange(BookRequest request, bool isSeeker) {
    final userId = _currentUserId;
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Exchange'),
        content: Text(
          isSeeker
              ? 'Have you received the book from the owner?'
              : 'Have you handed over the book to the requester?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _requestBloc.add(
                ConfirmExchange(requestId: request.id, userId: userId),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Exchange confirmed! Waiting for the other party.',
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<Book?> _fetchBook(String bookId) async {
    final result = await _getBookByIdUseCase(GetBookByIdParams(bookId));
    return result.fold((_) => null, (book) => book);
  }

  Future<User?> _fetchUser(String userId) async {
    final result = await _getUserByIdUseCase(GetUserByIdParams(userId));
    return result.fold((_) => null, (user) => user);
  }
}

// Helper class for multiple futures
class FutureBuilder2<T1, T2> extends StatelessWidget {
  final Future<T1> future1;
  final Future<T2> future2;
  final Widget Function(BuildContext context, T1? data1, T2? data2) builder;

  const FutureBuilder2({
    super.key,
    required this.future1,
    required this.future2,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T1>(
      future: future1,
      builder: (context, snapshot1) {
        return FutureBuilder<T2>(
          future: future2,
          builder: (context, snapshot2) {
            return builder(context, snapshot1.data, snapshot2.data);
          },
        );
      },
    );
  }
}
