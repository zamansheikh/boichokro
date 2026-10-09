import '../../../profile/presentation/pages/user_profile_page.dart';
import '../../../discover/presentation/pages/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../discover/domain/entities/book.dart';
import '../../../discover/domain/entities/user.dart';
import '../../../discover/domain/usecases/book_usecases.dart';
import '../../../discover/domain/usecases/user_usecases.dart';
import '../../../discover/presentation/bloc/book/book_bloc.dart';
import '../../../discover/presentation/bloc/book/book_event.dart';
import '../../../discover/presentation/bloc/book/book_state.dart';
import '../../../discover/presentation/bloc/request/request_bloc.dart';
import '../../../discover/presentation/bloc/request/request_event.dart';
import '../../../discover/presentation/bloc/request/request_state.dart';
import '../../domain/entities/request.dart';
import '../widgets/request_timeline_widget.dart';

/// The Library tab: my books, requests I sent, requests sent to me and the
/// history of finished requests.
///
/// Tab order (used by [initialTabIndex]): 0 my books, 1 my requests,
/// 2 requests to me, 3 history.
class MyLibraryPage extends StatefulWidget {
  final int initialTabIndex;
  const MyLibraryPage({super.key, this.initialTabIndex = 0});

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

enum _BookAction { view, edit, delete }

typedef _ReviewDraft = ({double rating, String text});

class _MyLibraryPageState extends State<MyLibraryPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const int _requestsToMeTab = 2;

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  late BookBloc _bookBloc;
  late RequestBloc _requestBloc;
  String? _currentUserId;

  /// Last successfully loaded data. Kept so the lists stay on screen while
  /// the blocs pass through loading / updated states.
  List<Book>? _books;
  List<BookRequest>? _requests;

  /// Shown once the request the user just acted on has been saved.
  String? _pendingRequestMessage;

  // Caches
  final Map<String, Future<Book?>> _bookCache = {};
  final Map<String, Future<User?>> _userCache = {};
  final Map<String, Future<(Book?, User?)>> _partyCache = {};

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
      // Loads both the requests I sent and the requests sent to me in a
      // single call, which avoids a race between the two lists.
      _requestBloc.add(LoadMyIncomingRequests(currentUser.uid));
    } else {
      _bookBloc = getIt<BookBloc>();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Requests and books change from other screens, so reload whenever the
    // Library tab comes back into view.
    if (_homeTab == null) {
      _homeTab = HomePage.tabOf(context);
      _homeTab?.addListener(_onHomeTabChanged);
    }
  }

  void _onHomeTabChanged() {
    if (_homeTab?.value == 1) {
      _reloadBooks();
      _reloadRequests();
    }
  }

  ValueListenable<int>? _homeTab;

  @override
  void dispose() {
    _homeTab?.removeListener(_onHomeTabChanged);
    _tabController.dispose();
    _bookBloc.close();
    _requestBloc.close();
    super.dispose();
  }

  // ========== DERIVED DATA ==========

  bool _isActive(BookRequest r) =>
      r.status == RequestStatus.pending || r.status == RequestStatus.accepted;

  List<BookRequest> _newestFirst(Iterable<BookRequest> requests) =>
      requests.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<BookRequest> get _sentRequests => _newestFirst(
    (_requests ?? const <BookRequest>[]).where(
      (r) => r.seekerId == _currentUserId && _isActive(r),
    ),
  );

  List<BookRequest> get _receivedRequests => _newestFirst(
    (_requests ?? const <BookRequest>[]).where(
      (r) => r.ownerId == _currentUserId && _isActive(r),
    ),
  );

  List<BookRequest> get _history => _newestFirst(
    (_requests ?? const <BookRequest>[]).where((r) => !_isActive(r)),
  );

  int _waitingCountFor(String bookId) => _receivedRequests
      .where((r) => r.bookId == bookId && r.status == RequestStatus.pending)
      .length;

  bool get _booksBusy => _bookBloc.state is BookLoading;
  bool get _requestsBusy => _requestBloc.state is RequestLoading;

  /// True when this page was pushed as its own route rather than shown as a
  /// tab of the home shell.
  bool get _isStandalone {
    final name = ModalRoute.of(context)?.settings.name;
    return name == 'myLibrary' || name == RoutePaths.myLibrary;
  }

  double get _bottomPadding => _isStandalone
      ? AppSpacing.xxxl + MediaQuery.viewPaddingOf(context).bottom
      : AppSpacing.navClearance;

  EdgeInsets get _listPadding => EdgeInsets.fromLTRB(
    AppSpacing.page,
    AppSpacing.lg,
    AppSpacing.page,
    _bottomPadding,
  );

  // ========== BLOC LISTENERS ==========

  void _onBookState(BuildContext context, BookState state) {
    if (state is BookLoaded) {
      _books = state.books.where((b) => b.ownerId == _currentUserId).toList();
    } else if (state is BookDeleted) {
      showAppSnack(
        context,
        'Book removed from your library',
        tone: AppTone.success,
      );
      _reloadBooks();
    } else if (state is BookUpdated || state is BookAdded) {
      _reloadBooks();
    } else if (state is BookError && _books != null) {
      showAppSnack(context, state.message, tone: AppTone.danger);
    }
    setState(() {});
  }

  void _onRequestState(BuildContext context, RequestState state) {
    if (state is RequestLoaded) {
      _requests = state.requests;
    } else if (state is RequestUpdated || state is RequestDeleted) {
      final message = _pendingRequestMessage;
      _pendingRequestMessage = null;
      if (message != null) {
        showAppSnack(context, message, tone: AppTone.success);
      }
      // A request change also moves the book between statuses.
      _reloadRequests();
      _reloadBooks();
    } else if (state is RequestError) {
      _pendingRequestMessage = null;
      if (_requests != null) {
        showAppSnack(context, state.message, tone: AppTone.danger);
      }
    }
    setState(() {});
  }

  void _reloadBooks() {
    final userId = _currentUserId;
    if (userId != null) _bookBloc.add(LoadMyBooks(userId));
  }

  void _reloadRequests() {
    final userId = _currentUserId;
    if (userId != null) _requestBloc.add(LoadMyIncomingRequests(userId));
  }

  Future<void> _refreshAll() async {
    if (_currentUserId == null) return;

    // Keep the pull-to-refresh indicator up until both lists have settled.
    final settled = Future.wait<void>([
      _bookBloc.stream.firstWhere((s) => s is! BookLoading).then((_) {}),
      _requestBloc.stream.firstWhere((s) => s is! RequestLoading).then((_) {}),
    ]);
    _reloadBooks();
    _reloadRequests();

    try {
      await settled.timeout(const Duration(seconds: 12));
    } catch (_) {
      // Timed out or the page was closed: just let the indicator go away.
    }
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                _buildTabBar(),
                SizedBox(
                  height: 2,
                  child:
                      (_booksBusy && _books != null) ||
                          (_requestsBusy && _requests != null)
                      ? const LinearProgressIndicator(minHeight: 2)
                      : null,
                ),
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
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final standalone = _isStandalone;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        standalone ? AppSpacing.sm : AppSpacing.page,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (standalone)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                tooltip: 'Back',
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.home);
                  }
                },
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My library',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.headlineMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  _summaryLine(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCcw),
            tooltip: 'Refresh',
            onPressed: _currentUserId == null ? null : _refreshAll,
          ),
        ],
      ),
    );
  }

  String _summaryLine() {
    if (_currentUserId == null) return 'Sign in to share and request books';

    final books = _books;
    if (books == null && _requests == null) return 'Opening your shelf…';

    final parts = <String>[];
    if (books != null) {
      parts.add(
        books.isEmpty
            ? 'No books shared yet'
            : '${books.length} ${books.length == 1 ? 'book' : 'books'} shared',
      );
    }
    if (_requests != null) {
      final received = _receivedRequests;
      final waiting = received
          .where((r) => r.status == RequestStatus.pending)
          .length;
      final handOffs = [
        ...received,
        ..._sentRequests,
      ].where((r) => r.status == RequestStatus.accepted).length;

      if (waiting > 0) {
        parts.add('$waiting ${waiting == 1 ? 'request' : 'requests'} waiting');
      } else if (handOffs > 0) {
        parts.add(
          '$handOffs ${handOffs == 1 ? 'hand-off' : 'hand-offs'} in progress',
        );
      }
    }
    return parts.join(' · ');
  }

  Widget _buildTabBar() {
    final hasRequests = _requests != null;
    final sent = _sentRequests;
    final received = _receivedRequests;

    bool needsMe(BookRequest r, {required bool isSeeker}) {
      if (r.status == RequestStatus.pending) return !isSeeker;
      return isSeeker ? !r.seekerConfirmed : !r.ownerConfirmed;
    }

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      tabs: [
        _LibraryTab(label: 'My books', count: _books?.length),
        _LibraryTab(
          label: 'My requests',
          count: hasRequests ? sent.length : null,
          highlight: sent.any((r) => needsMe(r, isSeeker: true)),
        ),
        _LibraryTab(
          label: 'Requests to me',
          count: hasRequests ? received.length : null,
          highlight: received.any((r) => needsMe(r, isSeeker: false)),
        ),
        const _LibraryTab(label: 'History'),
      ],
    );
  }

  Widget _buildSignedOut() {
    return Padding(
      padding: EdgeInsets.only(bottom: _bottomPadding),
      child: AppEmptyState(
        icon: LucideIcons.library,
        title: 'Your library lives here',
        message:
            'Sign in to share your books, ask for others and follow every '
            'hand-off.',
        actionLabel: 'Sign in',
        actionIcon: LucideIcons.logIn,
        onAction: () => context.go(RoutePaths.auth),
      ),
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: _bottomPadding),
      child: AppEmptyState(
        icon: icon,
        title: title,
        message: message,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        onAction: onAction,
      ),
    );
  }

  // ========== TAB 1: MY BOOKS ==========
  Widget _buildMyBooksTab() {
    if (_currentUserId == null) return _buildSignedOut();

    final books = _books;
    if (books == null) {
      final state = _bookBloc.state;
      if (state is BookError) {
        return Padding(
          padding: EdgeInsets.only(bottom: _bottomPadding),
          child: AppErrorState(
            title: 'Could not load your books',
            message: state.message,
            onRetry: _refreshAll,
          ),
        );
      }
      return BookListSkeleton(itemCount: 4, padding: _listPadding);
    }

    if (books.isEmpty) {
      return _buildEmpty(
        icon: LucideIcons.library,
        title: 'Your shelf is empty',
        message:
            'Share a book you have finished. A reader nearby may be looking '
            'for exactly that one.',
        actionLabel: 'Add a book',
        actionIcon: LucideIcons.plus,
        onAction: _addBook,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: _listPadding,
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final book = books[index];
          return _MyBookCard(
            book: book,
            waitingCount: _waitingCountFor(book.id),
            onOpen: () => _openBook(book.id),
            onMore: () => _showBookActions(book),
            onSeeRequests: () => _tabController.animateTo(_requestsToMeTab),
          );
        },
      ),
    );
  }

  Future<void> _addBook() async {
    await context.push(RoutePaths.addBook);
    if (!mounted) return;
    _reloadBooks();
  }

  void _openBook(String bookId) => context.push('/book/$bookId');

  void _openChat(String chatRoomId) =>
      context.push('${RoutePaths.chat}/$chatRoomId');

  Future<void> _showBookActions(Book book) async {
    final editable = book.status == BookStatus.available;

    final action = await showAppSheet<_BookAction>(
      context,
      builder: (sheetContext) => SheetScaffold(
        title: 'Book options',
        subtitle: book.title,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!editable)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: AppBanner(
                  tone: AppTone.warning,
                  icon: LucideIcons.lock,
                  message: book.status == BookStatus.completed
                      ? 'This book has already found its reader, so it can '
                            'no longer be edited or removed.'
                      : 'This book is part of a request right now. You can '
                            'edit or remove it once that is settled.',
                ),
              ),
            ListTile(
              leading: const Icon(LucideIcons.eye),
              title: const Text('View book'),
              onTap: () => Navigator.pop(sheetContext, _BookAction.view),
            ),
            ListTile(
              enabled: editable,
              leading: const Icon(LucideIcons.pencil),
              title: const Text('Edit details'),
              onTap: () => Navigator.pop(sheetContext, _BookAction.edit),
            ),
            ListTile(
              enabled: editable,
              leading: Icon(
                LucideIcons.trash2,
                color: editable ? sheetContext.colors.error : null,
              ),
              title: Text(
                'Remove from library',
                style: editable
                    ? TextStyle(color: sheetContext.colors.error)
                    : null,
              ),
              onTap: () => Navigator.pop(sheetContext, _BookAction.delete),
            ),
          ],
        ),
      ),
    );

    if (action == null || !mounted) return;
    switch (action) {
      case _BookAction.view:
        _openBook(book.id);
      case _BookAction.edit:
        await context.push('/book/${book.id}/edit', extra: book);
        if (!mounted) return;
        _forgetBook(book.id);
        _reloadBooks();
      case _BookAction.delete:
        await _confirmDeleteBook(book);
    }
  }

  /// Drops cached copies of a book so request cards fetch it again.
  void _forgetBook(String bookId) {
    _bookCache.remove(bookId);
    _partyCache.removeWhere((key, _) => key.startsWith('$bookId|'));
  }

  Future<void> _confirmDeleteBook(Book book) async {
    final confirmed = await _confirm(
      title: 'Remove this book?',
      message:
          '"${book.title}" will be taken off Boichokro and readers will no '
          'longer be able to ask for it. This cannot be undone.',
      confirmLabel: 'Remove',
      cancelLabel: 'Keep it',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _bookBloc.add(DeleteBook(book.id));
  }

  // ========== TAB 2: MY REQUESTS ==========
  Widget _buildMyRequestsTab() {
    return _buildRequestList(
      requests: _sentRequests,
      empty: () => _buildEmpty(
        icon: LucideIcons.send,
        title: 'No requests on the way',
        message:
            'When you ask for a book, you can follow its journey here, from '
            'request to hand-off.',
        actionLabel: 'Discover books',
        actionIcon: LucideIcons.compass,
        onAction: () => HomePage.goToTab(context, 0),
      ),
      itemBuilder: (request) => _buildRequestCard(request, isSeeker: true),
    );
  }

  // ========== TAB 3: REQUESTS TO ME ==========
  Widget _buildRequestsToMeTab() {
    return _buildRequestList(
      requests: _receivedRequests,
      empty: () => _buildEmpty(
        icon: LucideIcons.inbox,
        title: 'No one has asked yet',
        message:
            'When a reader asks for one of your books, their request shows '
            'up here for you to accept or decline.',
        actionLabel: 'Add a book',
        actionIcon: LucideIcons.plus,
        onAction: _addBook,
      ),
      itemBuilder: (request) => _buildRequestCard(request, isSeeker: false),
    );
  }

  // ========== TAB 4: HISTORY ==========
  Widget _buildHistoryTab() {
    return _buildRequestList(
      requests: _history,
      empty: () => _buildEmpty(
        icon: LucideIcons.history,
        title: 'No history yet',
        message:
            'Completed, declined and cancelled requests are kept here, along '
            'with the reviews you exchange.',
      ),
      itemBuilder: _buildHistoryCard,
    );
  }

  Widget _buildRequestList({
    required List<BookRequest> requests,
    required Widget Function() empty,
    required Widget Function(BookRequest request) itemBuilder,
  }) {
    if (_currentUserId == null) return _buildSignedOut();

    if (_requests == null) {
      final state = _requestBloc.state;
      if (state is RequestError) {
        return Padding(
          padding: EdgeInsets.only(bottom: _bottomPadding),
          child: AppErrorState(
            title: 'Could not load your requests',
            message: state.message,
            onRetry: _refreshAll,
          ),
        );
      }
      return BookListSkeleton(itemCount: 3, padding: _listPadding);
    }

    if (requests.isEmpty) return empty();

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: _listPadding,
        itemCount: requests.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => itemBuilder(requests[index]),
      ),
    );
  }

  Widget _buildRequestCard(BookRequest request, {required bool isSeeker}) {
    final otherId = isSeeker ? request.ownerId : request.seekerId;

    return FutureBuilder<(Book?, User?)>(
      key: ValueKey('request_${request.id}'),
      future: _loadParty(request.bookId, otherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _RequestCardSkeleton();
        }
        final (book, other) = snapshot.data ?? (null, null);
        final chatRoomId = request.chatRoomId;
        final offeredId = request.offeredBookId;
        // A reader can back out until the exchange completes, including after
        // a confirmation tapped by mistake; cancelling releases both books.
        final canCancel =
            isSeeker &&
            (request.status == RequestStatus.pending ||
                request.status == RequestStatus.accepted);

        return _RequestCard(
          request: request,
          isSeeker: isSeeker,
          book: book,
          other: other,
          offeredBook: offeredId == null
              ? null
              : _bookCache[offeredId] ??= _fetchBook(offeredId),
          onOpenOffered: offeredId == null ? null : () => _openBook(offeredId),
          busy: _requestsBusy,
          onOpenBook: () => _openBook(request.bookId),
          onOpenChat: chatRoomId == null ? null : () => _openChat(chatRoomId),
          onAccept: () => _acceptRequest(request),
          onDecline: () => _declineRequest(request, other),
          onConfirm: () => _confirmExchange(request, isSeeker),
          onCancel: canCancel ? () => _cancelRequest(request) : null,
        );
      },
    );
  }

  Widget _buildHistoryCard(BookRequest request) {
    final isSeeker = request.seekerId == _currentUserId;
    final otherId = isSeeker ? request.ownerId : request.seekerId;

    return FutureBuilder<(Book?, User?)>(
      key: ValueKey('history_${request.id}'),
      future: _loadParty(request.bookId, otherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _RequestCardSkeleton(compact: true);
        }
        final (book, other) = snapshot.data ?? (null, null);

        return _HistoryCard(
          request: request,
          isSeeker: isSeeker,
          book: book,
          other: other,
          busy: _requestsBusy,
          onOpenBook: book == null ? null : () => _openBook(book.id),
          onReview: () => _leaveReview(request, other),
        );
      },
    );
  }

  // ========== REQUEST ACTIONS ==========

  void _acceptRequest(BookRequest request) {
    _pendingRequestMessage =
        'Request accepted. Use the chat to arrange the hand-off.';
    _requestBloc.add(
      UpdateRequestStatus(
        requestId: request.id,
        status: RequestStatus.accepted,
      ),
    );
  }

  Future<void> _declineRequest(BookRequest request, User? seeker) async {
    final name = seeker?.name ?? 'The reader';
    final confirmed = await _confirm(
      title: 'Decline this request?',
      message:
          '$name will see that you declined. Your book stays available for '
          'other readers.',
      confirmLabel: 'Decline',
      cancelLabel: 'Not now',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    _pendingRequestMessage = 'Request declined';
    _requestBloc.add(
      UpdateRequestStatus(
        requestId: request.id,
        status: RequestStatus.declined,
      ),
    );
  }

  Future<void> _cancelRequest(BookRequest request) async {
    final confirmed = await _confirm(
      title: 'Cancel your request?',
      message:
          'The owner will see that you no longer need this book. You can '
          'ask for it again later if it is still available.',
      confirmLabel: 'Cancel request',
      cancelLabel: 'Keep it',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    _pendingRequestMessage = 'Request cancelled';
    _requestBloc.add(
      UpdateRequestStatus(
        requestId: request.id,
        status: RequestStatus.cancelled,
      ),
    );
  }

  Future<void> _confirmExchange(BookRequest request, bool isSeeker) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final otherConfirmed = isSeeker
        ? request.ownerConfirmed
        : request.seekerConfirmed;

    final confirmed = await _confirm(
      title: isSeeker ? 'Did you receive the book?' : 'Did you hand it over?',
      message: isSeeker
          ? 'Confirm only once the book is in your hands. '
          : 'Confirm only once the reader has the book. ',
      detail: otherConfirmed
          ? 'This completes the exchange, and you can then review each other.'
          : 'The exchange completes when the other person confirms too.',
      confirmLabel: isSeeker ? 'Yes, I have it' : 'Yes, handed over',
      cancelLabel: 'Not yet',
    );
    if (!confirmed || !mounted) return;

    _pendingRequestMessage = otherConfirmed
        ? 'Exchange complete. You can now leave a review.'
        : 'Confirmed. Waiting for the other person to confirm too.';
    _requestBloc.add(ConfirmExchange(requestId: request.id, userId: userId));
  }

  Future<void> _leaveReview(BookRequest request, User? other) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final draft = await showAppSheet<_ReviewDraft>(
      context,
      builder: (_) => _ReviewSheet(name: other?.name),
    );
    if (draft == null || !mounted) return;

    _pendingRequestMessage = 'Review submitted. Thank you!';
    _requestBloc.add(
      SubmitReview(
        requestId: request.id,
        reviewerId: userId,
        rating: draft.rating,
        reviewText: draft.text,
      ),
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    String? detail,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(detail == null ? message : '$message$detail'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: dialogContext.colors.error,
                    foregroundColor: dialogContext.colors.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ========== DATA HELPERS ==========

  Future<(Book?, User?)> _loadParty(String bookId, String userId) {
    return _partyCache['$bookId|$userId'] ??= () async {
      final bookFuture = _bookCache[bookId] ??= _fetchBook(bookId);
      final userFuture = _userCache[userId] ??= _fetchUser(userId);
      return (await bookFuture, await userFuture);
    }();
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

// ============================================================================
// Shared helpers
// ============================================================================

String _relativeDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays == 0) {
    if (diff.inHours == 0) {
      if (diff.inMinutes <= 0) return 'just now';
      return '${diff.inMinutes}m ago';
    }
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('d MMM y').format(date);
}

const String _missingBookTitle = 'A book that is no longer listed';

/// Tab label with an optional count bubble.
class _LibraryTab extends StatelessWidget {
  const _LibraryTab({required this.label, this.count, this.highlight = false});

  final String label;
  final int? count;

  /// Draws the count in the primary colour when something needs the reader.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    final colors = context.colors;

    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null && count > 0) ...[
            const SizedBox(width: 6),
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: highlight
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: context.text.labelSmall?.copyWith(
                  color: highlight ? colors.onPrimary : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// My books
// ============================================================================

class _MyBookCard extends StatelessWidget {
  const _MyBookCard({
    required this.book,
    required this.waitingCount,
    required this.onOpen,
    required this.onMore,
    required this.onSeeRequests,
  });

  final Book book;
  final int waitingCount;
  final VoidCallback onOpen;
  final VoidCallback onMore;
  final VoidCallback onSeeRequests;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            imageUrl: book.coverUrl,
            title: book.title,
            width: 68,
            heroTag: 'library_book_${book.id}',
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
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
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      StatusPill.mode(book.mode, dense: true),
                      StatusPill.book(book.status, dense: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConditionMeter(condition: book.condition),
                  _buildNextStep(context),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.ellipsisVertical),
            tooltip: 'Book options',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            color: context.colors.onSurfaceVariant,
            onPressed: onMore,
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(BuildContext context) {
    final String label;
    final IconData icon;
    final AppTone tone;
    var actionable = true;

    if (waitingCount > 0) {
      label = waitingCount == 1
          ? '1 person asked for this'
          : '$waitingCount people asked for this';
      icon = LucideIcons.mail;
      tone = AppTone.warning;
    } else {
      switch (book.status) {
        case BookStatus.requested:
          label = 'Someone asked for this';
          icon = LucideIcons.mail;
          tone = AppTone.warning;
        case BookStatus.pending:
          label = 'Hand-off in progress';
          icon = LucideIcons.handshake;
          tone = AppTone.exchange;
        case BookStatus.completed:
          label = 'Found a new reader';
          icon = LucideIcons.checkCheck;
          tone = AppTone.neutral;
          actionable = false;
        case BookStatus.available:
          return const SizedBox.shrink();
      }
    }

    final colors = context.tone(tone);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Material(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: actionable ? onSeeRequests : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: colors.foreground),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  if (actionable)
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: colors.foreground,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Requests
// ============================================================================

/// Avatar, name and reputation of the other person in a request.
class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.caption,
    required this.user,
    required this.fallbackName,
    this.trailing,
  });

  final String caption;
  final User? user;
  final String fallbackName;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final user = this.user;

    return InkWell(
      onTap: user == null ? null : () => context.push(userProfilePath(user.id)),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: _buildRow(context, user),
    );
  }

  Widget _buildRow(BuildContext context, User? user) {
    return Row(
      children: [
        UserAvatar(
          photoUrl: user?.photoUrl,
          name: user?.name,
          radius: 22,
          verified: user?.verifiedBadge ?? false,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(caption),
              const SizedBox(height: 2),
              Text(
                user?.name ?? fallbackName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleSmall,
              ),
              if (user != null) ...[
                const SizedBox(height: 2),
                RatingBadge(rating: user.ratingAvg, swaps: user.totalSwaps),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

/// Cover, title and author of the requested book. Opens the book when tapped.
class _BookRow extends StatelessWidget {
  const _BookRow({required this.book, required this.meta, this.onTap});

  final Book? book;
  final List<Widget> meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final book = this.book;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(imageUrl: book?.coverUrl, title: book?.title, width: 52),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book?.title ?? _missingBookTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium,
                  ),
                  if (book != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: meta,
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  top: AppSpacing.xs,
                ),
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// An active request told as a story: who, which book, where it stands and
/// the one thing to do next.
class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.isSeeker,
    required this.book,
    required this.other,
    required this.offeredBook,
    required this.onOpenOffered,
    required this.busy,
    required this.onOpenBook,
    required this.onOpenChat,
    required this.onAccept,
    required this.onDecline,
    required this.onConfirm,
    required this.onCancel,
  });

  final BookRequest request;
  final bool isSeeker;
  final Book? book;
  final User? other;

  /// The book offered in return, for swap requests; null for gifts.
  final Future<Book?>? offeredBook;
  final VoidCallback? onOpenOffered;

  /// A request change is being saved; actions are disabled meanwhile.
  final bool busy;
  final VoidCallback onOpenBook;
  final VoidCallback? onOpenChat;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  bool get _pending => request.status == RequestStatus.pending;
  bool get _accepted => request.status == RequestStatus.accepted;
  bool get _mineConfirmed =>
      isSeeker ? request.seekerConfirmed : request.ownerConfirmed;
  bool get _theirsConfirmed =>
      isSeeker ? request.ownerConfirmed : request.seekerConfirmed;

  /// Nothing has been agreed yet, so chatting comes before confirming.
  bool get _arrangeFirst =>
      _accepted &&
      !_mineConfirmed &&
      !_theirsConfirmed &&
      request.exchangeMethod == null &&
      onOpenChat != null;

  String get _name => other?.name ?? (isSeeker ? 'The owner' : 'The reader');
  String get _nameInline =>
      other?.name ?? (isSeeker ? 'the owner' : 'the reader');

  @override
  Widget build(BuildContext context) {
    final book = this.book;
    final arrangement = _buildArrangement(context);
    final actions = _buildActions(context);
    final secondary = _buildSecondaryActions(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PersonRow(
            caption: isSeeker ? 'You asked' : 'Asked by',
            user: other,
            fallbackName: _name,
            trailing: StatusPill.request(request.status, dense: true),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: context.colors.outlineVariant),
          const SizedBox(height: AppSpacing.md),
          _BookRow(
            book: book,
            onTap: book == null ? null : onOpenBook,
            meta: [
              if (book != null) StatusPill.mode(book.mode, dense: true),
              MetaItem(
                icon: LucideIcons.clock,
                label: 'Asked ${_relativeDate(request.createdAt)}',
              ),
            ],
          ),
          if (offeredBook != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.tone(AppTone.exchange).background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.repeat,
                        size: 14,
                        color: context.tone(AppTone.exchange).foreground,
                      ),
                      const SizedBox(width: 6),
                      Eyebrow(
                        isSeeker
                            ? 'You offered in return'
                            : 'Offered in return',
                        color: context.tone(AppTone.exchange).foreground,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FutureBuilder<Book?>(
                    future: offeredBook,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Skeleton(height: 56);
                      }
                      final offered = snapshot.data;
                      return _BookRow(
                        book: offered,
                        onTap: offered == null ? null : onOpenOffered,
                        meta: [
                          if (offered != null)
                            ConditionMeter(condition: offered.condition),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _buildNextStep(context),
          if (arrangement != null) ...[
            const SizedBox(height: AppSpacing.md),
            arrangement,
          ],
          if (_accepted) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: 6,
              children: [
                _confirmationPill('You', _mineConfirmed),
                _confirmationPill(
                  isSeeker ? 'Owner' : 'Reader',
                  _theirsConfirmed,
                ),
              ],
            ),
          ],
          if (actions != null) ...[
            const SizedBox(height: AppSpacing.lg),
            actions,
          ],
          if (secondary != null) ...[
            const SizedBox(height: AppSpacing.xs),
            secondary,
          ],
          const SizedBox(height: AppSpacing.md),
          RequestTimelineWidget(
            request: request,
            isSeeker: isSeeker,
            collapsible: true,
          ),
        ],
      ),
    );
  }

  Widget _confirmationPill(String who, bool confirmed) {
    return StatusPill(
      label: confirmed ? '$who: confirmed' : '$who: not yet',
      icon: confirmed ? LucideIcons.circleCheck : LucideIcons.circle,
      tone: confirmed ? AppTone.success : AppTone.neutral,
      dense: true,
    );
  }

  Widget _buildNextStep(BuildContext context) {
    final String title;
    final String message;
    final IconData icon;
    final AppTone tone;

    if (_pending) {
      if (isSeeker) {
        title = 'Waiting for $_nameInline';
        message =
            'They will accept or decline your request. You can cancel it any '
            'time before then.';
        icon = LucideIcons.hourglass;
        tone = AppTone.neutral;
      } else {
        title = request.offeredBookId != null
            ? '$_name is offering a swap'
            : '$_name would like this book';
        message =
            'Accepting opens a chat to arrange the hand-off and declines any '
            'other requests for this book.';
        icon = LucideIcons.mail;
        tone = AppTone.warning;
      }
    } else if (_mineConfirmed) {
      title = 'You have confirmed';
      message = 'Waiting for $_nameInline to confirm the hand-off too.';
      icon = LucideIcons.hourglass;
      tone = AppTone.neutral;
    } else if (_theirsConfirmed) {
      title = 'Your turn to confirm';
      message = isSeeker
          ? '$_name confirmed handing the book over. Confirm once it is in '
                'your hands to complete the exchange.'
          : '$_name confirmed receiving the book. Confirm on your side to '
                'complete the exchange.';
      icon = LucideIcons.packageCheck;
      tone = AppTone.warning;
    } else {
      title = isSeeker ? '$_name said yes' : 'Time to hand it over';
      message = isSeeker
          ? 'Agree on a time and place in chat. Once the book is in your '
                'hands, confirm it here.'
          : 'Agree on a time and place in chat. Once you have handed the '
                'book over, confirm it here.';
      icon = LucideIcons.handshake;
      tone = AppTone.primary;
    }

    return AppBanner(title: title, message: message, icon: icon, tone: tone);
  }

  /// Details of the agreed hand-off, when one has been recorded.
  Widget? _buildArrangement(BuildContext context) {
    final method = request.exchangeMethod;
    if (method == null) return null;

    final rows = <Widget>[];
    void add(IconData icon, String? value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  icon,
                  size: 14,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (method == ExchangeMethod.meetup) {
      final time = request.meetingTime;
      add(
        LucideIcons.calendarClock,
        time == null ? null : DateFormat('EEE d MMM, h:mm a').format(time),
      );
      add(LucideIcons.mapPin, request.meetingLocation);
    } else {
      add(LucideIcons.truck, request.courierMethod);
      final tracking = request.trackingId?.trim() ?? '';
      add(LucideIcons.hash, tracking.isEmpty ? null : 'Tracking $tracking');
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Hand-off'),
          const SizedBox(height: 2),
          Text(method.displayName, style: context.text.titleSmall),
          ...rows,
        ],
      ),
    );
  }

  /// The single most important thing to do next, if there is one.
  Widget? _buildActions(BuildContext context) {
    if (_pending && !isSeeker) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: busy ? null : onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.error,
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton.icon(
              onPressed: busy ? null : onAccept,
              icon: const Icon(LucideIcons.check, size: 18),
              label: const Text('Accept'),
            ),
          ),
        ],
      );
    }

    if (_accepted && !_mineConfirmed) {
      final confirmIcon = Icon(
        isSeeker ? LucideIcons.packageCheck : LucideIcons.handshake,
        size: 18,
      );
      final confirmLabel = Text(
        isSeeker ? 'I received the book' : 'I handed it over',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

      if (_arrangeFirst) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: onOpenChat,
              icon: const Icon(LucideIcons.messageCircle, size: 18),
              label: const Text(
                'Arrange hand-off in chat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: busy ? null : onConfirm,
              icon: confirmIcon,
              label: confirmLabel,
            ),
          ],
        );
      }

      return FilledButton.icon(
        onPressed: busy ? null : onConfirm,
        icon: confirmIcon,
        label: confirmLabel,
      );
    }

    return null;
  }

  /// Quieter actions: chat (unless it is already the main action) and cancel.
  Widget? _buildSecondaryActions(BuildContext context) {
    final showChat = onOpenChat != null && !_arrangeFirst;
    if (!showChat && onCancel == null) return null;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (showChat)
          TextButton.icon(
            onPressed: onOpenChat,
            icon: const Icon(LucideIcons.messageCircle, size: 18),
            label: const Text('Open chat'),
          ),
        if (onCancel != null)
          TextButton(
            onPressed: busy ? null : onCancel,
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: const Text('Cancel request'),
          ),
      ],
    );
  }
}

/// Placeholder shown while a request's book and person are being fetched.
class _RequestCardSkeleton extends StatelessWidget {
  const _RequestCardSkeleton({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            const Row(
              children: [
                Skeleton(width: 44, height: 44, radius: AppRadius.pill),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 70, height: 10),
                      SizedBox(height: AppSpacing.sm),
                      Skeleton(width: 140, height: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 52, height: 78),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.xs),
                    Skeleton(height: 16),
                    SizedBox(height: AppSpacing.sm),
                    Skeleton(width: 120, height: 12),
                    SizedBox(height: AppSpacing.md),
                    Skeleton(width: 90, height: 18, radius: AppRadius.pill),
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.lg),
            const Skeleton(height: 52, radius: AppRadius.lg),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// History
// ============================================================================

/// A finished request: quieter than an active one, with the reviews exchanged.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.request,
    required this.isSeeker,
    required this.book,
    required this.other,
    required this.busy,
    required this.onOpenBook,
    required this.onReview,
  });

  final BookRequest request;
  final bool isSeeker;
  final Book? book;
  final User? other;
  final bool busy;
  final VoidCallback? onOpenBook;
  final VoidCallback onReview;

  String get _nameInline =>
      other?.name ?? (isSeeker ? 'the owner' : 'the reader');
  String get _name => other?.name ?? (isSeeker ? 'The owner' : 'The reader');

  String get _story {
    switch (request.status) {
      case RequestStatus.completed:
        return isSeeker
            ? 'You received this from $_nameInline'
            : 'You gave this to $_nameInline';
      case RequestStatus.declined:
        return isSeeker
            ? '$_name declined your request'
            : 'You declined the request from $_nameInline';
      case RequestStatus.cancelled:
        return isSeeker
            ? 'You cancelled your request to $_nameInline'
            : '$_name cancelled their request';
      case RequestStatus.pending:
      case RequestStatus.accepted:
        return isSeeker
            ? 'You asked $_nameInline'
            : '$_name asked for this book';
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = this.book;
    final muted = context.colors.onSurfaceVariant;

    return AppCard(
      color: context.colors.surfaceContainerLow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onOpenBook,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  imageUrl: book?.coverUrl,
                  title: book?.title,
                  width: 44,
                  elevated: false,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book?.title ?? _missingBookTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _story,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(color: muted),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusPill.request(request.status, dense: true),
                          MetaItem(
                            icon: LucideIcons.calendar,
                            label: _relativeDate(request.updatedAt),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (request.status == RequestStatus.completed) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: context.colors.outlineVariant),
            const SizedBox(height: AppSpacing.md),
            ..._buildReviews(context),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildReviews(BuildContext context) {
    final myRating = isSeeker ? request.seekerRating : request.ownerRating;
    final myReview = isSeeker ? request.seekerReview : request.ownerReview;
    final theirRating = isSeeker ? request.ownerRating : request.seekerRating;
    final theirReview = isSeeker ? request.ownerReview : request.seekerReview;
    final muted = context.colors.onSurfaceVariant;

    return [
      if (myRating != null)
        _ReviewLine(label: 'You rated', rating: myRating, review: myReview)
      else ...[
        Text(
          'How was your exchange with $_nameInline? Your review helps other '
          'readers trust them.',
          style: context.text.bodySmall?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.tonalIcon(
          onPressed: busy ? null : onReview,
          icon: const Icon(LucideIcons.star, size: 18),
          label: const Text('Leave a review'),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      if (theirRating != null)
        _ReviewLine(
          label: 'They rated you',
          rating: theirRating,
          review: theirReview,
        )
      else
        Text(
          '$_name has not left a review yet.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(color: muted),
        ),
    ];
  }
}

/// A rating with its stars and, when written, the review text.
class _ReviewLine extends StatelessWidget {
  const _ReviewLine({required this.label, required this.rating, this.review});

  final String label;
  final double rating;
  final String? review;

  @override
  Widget build(BuildContext context) {
    final text = review?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Eyebrow(label)),
            RatingBarIndicator(
              rating: rating,
              itemCount: 5,
              itemSize: 16,
              unratedColor: context.colors.outlineVariant,
              itemBuilder: (context, _) =>
                  Icon(Icons.star_rounded, color: context.palette.star),
            ),
            const SizedBox(width: 6),
            Text(
              rating.toStringAsFixed(1),
              style: context.text.labelMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '"$text"',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// Review sheet
// ============================================================================

/// Collects a star rating and an optional note, then pops a [_ReviewDraft].
class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({this.name});

  final String? name;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  static const List<String> _labels = [
    'Not good',
    'Could be better',
    'Okay',
    'Good',
    'Excellent',
  ];

  final TextEditingController _controller = TextEditingController();
  double _rating = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final labelIndex = (_rating.round() - 1).clamp(0, _labels.length - 1);

    return SheetScaffold(
      title: 'Leave a review',
      subtitle: name == null
          ? 'How did the exchange go?'
          : 'How was your exchange with $name?',
      footer: FilledButton(
        onPressed: () => Navigator.pop<_ReviewDraft>(context, (
          rating: _rating,
          text: _controller.text.trim(),
        )),
        child: const Text('Submit review'),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                itemCount: 5,
                itemSize: 44,
                glow: false,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                unratedColor: context.colors.outlineVariant,
                itemBuilder: (context, _) =>
                    Icon(Icons.star_rounded, color: context.palette.star),
                onRatingUpdate: (value) => setState(() => _rating = value),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _labels[labelIndex],
            textAlign: TextAlign.center,
            style: context.text.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Your review (optional)',
              hintText: 'Was the book as described? Were they easy to meet?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your rating is shared with them and counts towards their '
            'profile.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
