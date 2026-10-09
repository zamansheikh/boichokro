import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../discover/presentation/bloc/user/user_bloc.dart';
import '../../../discover/presentation/bloc/user/user_event.dart';
import '../../../discover/presentation/bloc/user/user_state.dart';
import '../../domain/entities/chat.dart';
import '../../domain/usecases/mark_messages_as_read_usecase.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

/// Chat Room Page - Individual chat conversation with book context
class ChatRoomPage extends StatefulWidget {
  final String roomId;

  const ChatRoomPage({super.key, required this.roomId});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  static const String _mapsPrefix =
      'https://www.google.com/maps/search/?api=1&query=';

  late ChatBloc _chatBloc;
  late UserBloc _userBloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _composerFocus = FocusNode();

  ChatRoom? _chatRoom;

  /// Every message received so far, keyed by id. The bloc re-emits the list
  /// when other events finish and the live subscription replays history, so
  /// the page keeps its own de-duplicated copy to render from.
  final Map<String, Message> _messagesById = {};

  /// Newest first, matching the reversed list view.
  List<Message> _messages = const [];
  bool _messagesLoaded = false;
  String? _loadError;
  bool _safetyTipDismissed = false;
  bool _sharingLocation = false;
  String? _lastMarkedRead;

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<ChatBloc>()
      ..add(LoadChatRoom(widget.roomId))
      ..add(SubscribeToMessages(widget.roomId));
    _userBloc = getIt<UserBloc>();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _composerFocus.dispose();
    _chatBloc.close();
    super.dispose();
  }

  // ── Chat state ────────────────────────────────────────────────────────────

  void _onChatState(BuildContext context, ChatState state) {
    if (state is ChatRoomLoaded) {
      setState(() {
        _chatRoom = state.chatRoom;
        _loadError = null;
      });
    } else if (state is MessagesLoaded) {
      setState(() {
        for (final message in state.messages) {
          final key = message.id.isNotEmpty
              ? message.id
              : '${message.senderId}-'
                    '${message.createdAt.microsecondsSinceEpoch}';
          _messagesById[key] = message;
        }
        _messages = _messagesById.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _messagesLoaded = true;
        _loadError = null;
      });
      _markRead();
    } else if (state is ChatError) {
      if (_chatRoom != null && _messagesLoaded) {
        // The conversation is already on screen, so this is a failed action
        // (usually a message that could not be sent).
        showAppSnack(context, state.message, tone: AppTone.danger);
      } else {
        setState(() => _loadError = state.message);
      }
    }
  }

  /// Clears this reader's unread count once per new incoming message. Called
  /// through the use case rather than the bloc, whose `MarkedAsRead` state
  /// would replace the conversation on screen.
  void _markRead() {
    final userId = getIt<FirebaseService>().auth.currentUser?.uid;
    if (userId == null) return;

    final latest = _messages.isEmpty ? null : _messages.first;
    final marker = latest?.id ?? '';
    if (_lastMarkedRead == marker) return;
    if (latest != null &&
        latest.senderId == userId &&
        _lastMarkedRead != null) {
      return;
    }
    _lastMarkedRead = marker;

    getIt<MarkMessagesAsReadUseCase>()(
      MarkMessagesAsReadParams(chatRoomId: widget.roomId, userId: userId),
    );
  }

  void _retryLoad() {
    setState(() => _loadError = null);
    if (_chatRoom == null) _chatBloc.add(LoadChatRoom(widget.roomId));
    if (!_messagesLoaded) _chatBloc.add(SubscribeToMessages(widget.roomId));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: AppMotion.medium,
        curve: Curves.easeOut,
      );
    }
  }

  // ── Sending ───────────────────────────────────────────────────────────────

  void _send(String content, MessageType type) {
    final chatRoom = _chatRoom;
    final sender = getIt<FirebaseService>().currentUser;
    if (chatRoom == null || sender == null) return;

    final message = Message(
      id: '', // Will be set by backend
      chatRoomId: chatRoom.id,
      senderId: sender.uid,
      content: content,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
    );
    _chatBloc.add(SendMessage(message));
    _scrollToBottom();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatRoom == null) return;

    _send(text, MessageType.text);
    _messageController.clear();
  }

  void _useStarter(String text) {
    _messageController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _composerFocus.requestFocus();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _confirmShareLocation() async {
    FocusScope.of(context).unfocus();
    final confirmed = await showAppSheet<bool>(
      context,
      builder: (sheetContext) => SheetScaffold(
        title: 'Share your location',
        subtitle: 'Sends a map pin of where you are right now.',
        footer: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('Share pin'),
              ),
            ),
          ],
        ),
        child: const AppBanner(
          tone: AppTone.warning,
          icon: LucideIcons.shieldCheck,
          title: 'Share with care',
          message:
              'Only share your location when you are ready to meet, and '
              'pick a busy public place rather than your home.',
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    await _shareLocation();
  }

  Future<void> _shareLocation() async {
    setState(() => _sharingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack('Turn on location services to share a pin.', AppTone.warning);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _snack(
          'Location permission is needed to share a pin.',
          AppTone.warning,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;

      _send(
        '$_mapsPrefix${position.latitude.toStringAsFixed(6)},'
        '${position.longitude.toStringAsFixed(6)}',
        MessageType.location,
      );
    } catch (_) {
      _snack('Could not get your location. Please try again.', AppTone.danger);
    } finally {
      if (mounted) setState(() => _sharingLocation = false);
    }
  }

  Future<void> _openLocation(({double lat, double lng}) point) async {
    final uri = Uri.parse('$_mapsPrefix${point.lat},${point.lng}');
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) _snack('Could not open a maps app.', AppTone.danger);
  }

  void _snack(String message, AppTone tone) {
    if (!mounted) return;
    showAppSnack(context, message, tone: tone);
  }

  // ── Report / block ────────────────────────────────────────────────────────

  Future<void> _showReportSheet(String targetUserId, String name) async {
    final reason = await showAppSheet<String>(
      context,
      builder: (_) => _ReportSheet(name: name),
    );
    if (reason == null || !mounted) return;
    _userBloc.add(ReportUser(userId: targetUserId, reason: reason));
  }

  Future<void> _showBlockSheet(String targetUserId, String name) async {
    final confirmed = await showAppSheet<bool>(
      context,
      builder: (sheetContext) => SheetScaffold(
        title: 'Block $name?',
        footer: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: sheetContext.colors.error,
                  foregroundColor: sheetContext.colors.onError,
                ),
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('Block'),
              ),
            ),
          ],
        ),
        child: Text(
          'You will no longer receive messages from them, and they will not '
          'be able to interact with your books.',
          style: sheetContext.text.bodyLarge?.copyWith(
            color: sheetContext.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    _userBloc.add(BlockUser(targetUserId));
  }

  // ── Derived data ──────────────────────────────────────────────────────────

  /// The room stores both display names but not which participant is which,
  /// so the other reader is whichever name is not the signed-in user's.
  String _otherName(ChatRoom? chatRoom) {
    if (chatRoom == null) return 'Chat';
    final owner = chatRoom.ownerName?.trim() ?? '';
    final requester = chatRoom.requesterName?.trim() ?? '';
    final me =
        getIt<FirebaseService>().currentUser?.displayName
            ?.trim()
            .toLowerCase() ??
        '';

    if (owner.isEmpty && requester.isEmpty) return 'Reader';
    if (owner.isEmpty) return requester;
    if (requester.isEmpty) return owner;
    if (me.isNotEmpty && owner.toLowerCase() == me) return requester;
    if (me.isNotEmpty && requester.toLowerCase() == me) return owner;
    return '$owner & $requester';
  }

  void _openBook() {
    final bookId = _chatRoom?.bookId;
    if (bookId != null) context.push('/book/$bookId');
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<FirebaseService>().currentUser?.uid;
    final chatRoom = _chatRoom;
    final otherUserId = chatRoom?.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final otherName = _otherName(chatRoom);

    return BlocProvider.value(
      value: _userBloc,
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            showAppSnack(context, state.message, tone: AppTone.success);
            if (state.message.contains('blocked')) {
              context.pop(); // Exit chat room after blocking
            }
          } else if (state is UserError) {
            showAppSnack(context, state.message, tone: AppTone.danger);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: _RoomTitle(
              name: otherName,
              bookName: chatRoom?.bookName,
              showAvatar: chatRoom != null,
            ),
            actions: [
              if (chatRoom != null &&
                  (chatRoom.bookId != null ||
                      (otherUserId != null && otherUserId.isNotEmpty)))
                PopupMenuButton<String>(
                  tooltip: 'More options',
                  icon: const Icon(LucideIcons.ellipsisVertical),
                  onSelected: (value) {
                    if (value == 'book') {
                      _openBook();
                    } else if (value == 'report') {
                      _showReportSheet(otherUserId!, otherName);
                    } else if (value == 'block') {
                      _showBlockSheet(otherUserId!, otherName);
                    }
                  },
                  itemBuilder: (context) => [
                    if (chatRoom.bookId != null)
                      const PopupMenuItem(
                        value: 'book',
                        child: _MenuRow(
                          icon: LucideIcons.bookOpen,
                          label: 'View book details',
                        ),
                      ),
                    if (otherUserId != null && otherUserId.isNotEmpty) ...[
                      const PopupMenuItem(
                        value: 'report',
                        child: _MenuRow(
                          icon: LucideIcons.flag,
                          label: 'Report user',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'block',
                        child: _MenuRow(
                          icon: LucideIcons.ban,
                          label: 'Block user',
                          color: context.colors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: BlocListener<ChatBloc, ChatState>(
            bloc: _chatBloc,
            listener: _onChatState,
            child: _buildBody(currentUserId, otherName),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(String? currentUserId, String otherName) {
    final chatRoom = _chatRoom;
    final loadError = _loadError;

    if (chatRoom == null) {
      if (loadError != null) {
        return AppErrorState(
          title: 'Could not open this chat',
          message: loadError,
          onRetry: _retryLoad,
        );
      }
      return const AppLoading(message: 'Opening conversation');
    }

    final Widget conversation;
    if (!_messagesLoaded) {
      conversation = loadError != null
          ? AppErrorState(
              title: 'Could not load messages',
              message: loadError,
              onRetry: _retryLoad,
            )
          : const AppLoading();
    } else if (_messages.isEmpty) {
      conversation = _buildEmptyConversation(chatRoom, otherName);
    } else {
      conversation = _buildMessageList(currentUserId, otherName);
    }

    return Column(
      children: [
        _BookContextStrip(
          chatRoom: chatRoom,
          onTap: chatRoom.bookId != null ? _openBook : null,
        ),
        Expanded(child: conversation),
        _Composer(
          controller: _messageController,
          focusNode: _composerFocus,
          sharingLocation: _sharingLocation,
          onSend: _sendMessage,
          onShareLocation: _confirmShareLocation,
        ),
      ],
    );
  }

  Widget _buildSafetyTip() {
    return AppBanner(
      tone: AppTone.exchange,
      icon: LucideIcons.shieldCheck,
      title: 'Meet safely',
      message:
          'Hand books over in a busy public place during the day, and never '
          'send money or personal details in chat.',
      actionLabel: 'Got it',
      onAction: () => setState(() => _safetyTipDismissed = true),
    );
  }

  Widget _buildEmptyConversation(ChatRoom chatRoom, String otherName) {
    final bookName = chatRoom.bookName?.trim() ?? '';
    final starters = [
      bookName.isEmpty
          ? 'Hi! Is the book still available?'
          : 'Hi! Is "$bookName" still available?',
      'When and where would be good to meet?',
      'Thank you for sharing this book!',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.messageCircle,
                size: 30,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Start the conversation',
              style: context.text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Say hello to $otherName and agree on how to hand the book '
              'over. Tap a suggestion to use it.',
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final starter in starters) ...[
              _StarterChip(label: starter, onTap: () => _useStarter(starter)),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (!_safetyTipDismissed) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildSafetyTip(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(String? currentUserId, String otherName) {
    final messages = _messages;
    final showTip = !_safetyTipDismissed;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      itemCount: messages.length + (showTip ? 1 : 0),
      itemBuilder: (context, index) {
        // The list is reversed, so the last index is the top of the thread.
        if (index == messages.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildSafetyTip(),
          );
        }

        final message = messages[index];
        final older = index + 1 < messages.length ? messages[index + 1] : null;
        final newer = index > 0 ? messages[index - 1] : null;

        final showDate =
            older == null || !_isSameDay(message.createdAt, older.createdAt);
        final firstInGroup = showDate || !_sameGroup(message, older);
        final lastInGroup =
            newer == null ||
            !_isSameDay(message.createdAt, newer.createdAt) ||
            !_sameGroup(message, newer);

        final Widget child;
        if (message.type == MessageType.system) {
          child = _SystemMessage(text: message.content);
        } else {
          child = _MessageBubble(
            message: message,
            isMe: message.senderId == currentUserId,
            otherName: otherName,
            firstInGroup: firstInGroup,
            lastInGroup: lastInGroup,
            location: message.type == MessageType.location
                ? _parseLocation(message.content)
                : null,
            onOpenLocation: _openLocation,
          );
        }

        if (!showDate) return child;
        return Column(
          children: [
            _DaySeparator(date: message.createdAt),
            child,
          ],
        );
      },
    );
  }

  static bool _sameGroup(Message a, Message b) {
    return a.senderId == b.senderId &&
        a.type != MessageType.system &&
        b.type != MessageType.system &&
        a.createdAt.difference(b.createdAt).inMinutes.abs() < 10;
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static ({double lat, double lng})? _parseLocation(String content) {
    final match = RegExp(
      r'(-?\d{1,3}\.\d+)\s*,\s*(-?\d{1,3}\.\d+)',
    ).firstMatch(content);
    if (match == null) return null;
    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return (lat: lat, lng: lng);
  }
}

// ── App bar ─────────────────────────────────────────────────────────────────

class _RoomTitle extends StatelessWidget {
  const _RoomTitle({
    required this.name,
    required this.bookName,
    required this.showAvatar,
  });

  final String name;
  final String? bookName;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final book = bookName?.trim() ?? '';

    return Row(
      children: [
        if (showAvatar) ...[
          UserAvatar(name: name, radius: 18),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium,
              ),
              if (book.isNotEmpty)
                Text(
                  book,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? context.colors.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: resolved),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: context.text.bodyLarge?.copyWith(color: resolved)),
      ],
    );
  }
}

// ── Book context ────────────────────────────────────────────────────────────

/// Slim strip pinned under the app bar that says which book the chat is
/// about and opens it.
class _BookContextStrip extends StatelessWidget {
  const _BookContextStrip({required this.chatRoom, required this.onTap});

  final ChatRoom chatRoom;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bookName = chatRoom.bookName?.trim() ?? '';
    final owner = chatRoom.ownerName?.trim() ?? '';
    final requester = chatRoom.requesterName?.trim() ?? '';

    if (bookName.isEmpty && onTap == null) {
      return Divider(height: 1, thickness: 1, color: colors.outlineVariant);
    }

    final people = [
      if (owner.isNotEmpty) 'Shared by $owner',
      if (requester.isNotEmpty) 'requested by $requester',
    ].join(' · ');

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.page,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              BookCover(
                imageUrl: null,
                title: bookName,
                width: 28,
                elevated: false,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookName.isEmpty ? 'Book in this chat' : bookName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall,
                    ),
                    if (people.isNotEmpty)
                      Text(
                        people,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'View',
                  style: context.text.labelLarge?.copyWith(
                    color: colors.primary,
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 18, color: colors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Messages ────────────────────────────────────────────────────────────────

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    final String label;
    if (messageDate == today) {
      label = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      label = 'Yesterday';
    } else if (date.year == now.year) {
      label = DateFormat('MMMM d').format(date);
    } else {
      label = DateFormat('MMMM d, y').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Center(
        child: Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.otherName,
    required this.firstInGroup,
    required this.lastInGroup,
    required this.location,
    required this.onOpenLocation,
  });

  static const double _avatarRadius = 14;
  static const double _avatarSlot = _avatarRadius * 2 + AppSpacing.sm;

  final Message message;
  final bool isMe;
  final String otherName;

  /// Top-most and bottom-most bubble of a run from the same sender.
  final bool firstInGroup;
  final bool lastInGroup;

  /// Parsed coordinates when this is a location message that carries them.
  final ({double lat, double lng})? location;
  final ValueChanged<({double lat, double lng})> onOpenLocation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isMe ? colors.onPrimary : colors.onSurface;

    const round = Radius.circular(AppRadius.xl);
    const joined = Radius.circular(AppRadius.sm);
    const tail = Radius.circular(AppRadius.sm / 2);
    final radius = BorderRadius.only(
      topLeft: isMe || firstInGroup ? round : joined,
      topRight: !isMe || firstInGroup ? round : joined,
      bottomLeft: isMe ? round : (lastInGroup ? tail : joined),
      bottomRight: !isMe ? round : (lastInGroup ? tail : joined),
    );

    final point = location;
    final isLocation = message.type == MessageType.location;

    final bubble = Material(
      color: isMe ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: isMe ? BorderSide.none : BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: point != null ? () => onOpenLocation(point) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg - 2,
            vertical: AppSpacing.sm + 2,
          ),
          child: isLocation
              ? _LocationContent(
                  content: message.content,
                  location: point,
                  isMe: isMe,
                  foreground: foreground,
                )
              : Text(
                  message.content,
                  style: context.text.bodyLarge?.copyWith(
                    color: foreground,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: firstInGroup ? AppSpacing.md : 3),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                if (lastInGroup)
                  UserAvatar(name: otherName, radius: _avatarRadius)
                else
                  const SizedBox(width: _avatarRadius * 2),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.76,
                  ),
                  child: bubble,
                ),
              ),
            ],
          ),
          if (lastInGroup)
            Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.xs,
                left: isMe ? 0 : _avatarSlot + AppSpacing.xs,
                right: isMe ? AppSpacing.xs : 0,
              ),
              child: Text(
                DateFormat('h:mm a').format(message.createdAt),
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationContent extends StatelessWidget {
  const _LocationContent({
    required this.content,
    required this.location,
    required this.isMe,
    required this.foreground,
  });

  final String content;
  final ({double lat, double lng})? location;
  final bool isMe;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final point = location;
    final muted = foreground.withValues(alpha: 0.78);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isMe
                ? colors.onPrimary.withValues(alpha: 0.16)
                : colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.mapPin,
            size: 20,
            color: isMe ? colors.onPrimary : colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMe ? 'You shared a location' : 'Shared location',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleSmall?.copyWith(color: foreground),
              ),
              const SizedBox(height: 2),
              Text(
                point != null
                    ? '${point.lat.toStringAsFixed(4)}, '
                          '${point.lng.toStringAsFixed(4)}'
                    : content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(color: muted),
              ),
              if (point != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap to open in maps',
                  style: context.text.labelMedium?.copyWith(color: foreground),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  LucideIcons.cornerDownLeft,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Composer ────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.sharingLocation,
    required this.onSend,
    required this.onShareLocation,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sharingLocation;
  final VoidCallback onSend;
  final VoidCallback onShareLocation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: sharingLocation
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Share your location',
                        icon: const Icon(LucideIcons.mapPin),
                        color: colors.onSurfaceVariant,
                        onPressed: onShareLocation,
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      AppConstants.maxMessageLength,
                    ),
                  ],
                  style: context.text.bodyLarge?.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Write a message',
                    isDense: true,
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md + 1,
                    ),
                    border: border(colors.outlineVariant),
                    enabledBorder: border(colors.outlineVariant),
                    focusedBorder: border(colors.primary, 1.5),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty;
                  return Tooltip(
                    message: 'Send',
                    child: Material(
                      color: canSend
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: canSend ? onSend : null,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            LucideIcons.sendHorizontal,
                            size: 20,
                            color: canSend
                                ? colors.onPrimary
                                : colors.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Report sheet ────────────────────────────────────────────────────────────

/// Lets the reader pick why they are reporting someone. Pops with the chosen
/// reason, or null when dismissed.
class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.name});

  final String name;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const List<String> _reasons = [
    'Spam',
    'Harassment',
    'Inappropriate Content',
    'Other',
  ];

  String _selected = _reasons.first;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SheetScaffold(
      title: 'Report user',
      subtitle: 'Tell us what is wrong with ${widget.name}.',
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      footer: FilledButton(
        onPressed: () => Navigator.pop(context, _selected),
        child: const Text('Submit report'),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final reason in _reasons)
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => setState(() => _selected = reason),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        reason == _selected
                            ? LucideIcons.circleCheck
                            : LucideIcons.circle,
                        size: 22,
                        color: reason == _selected
                            ? colors.primary
                            : colors.outline,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          reason == 'Inappropriate Content'
                              ? 'Inappropriate content'
                              : reason,
                          style: context.text.bodyLarge?.copyWith(
                            fontWeight: reason == _selected
                                ? FontWeight.w600
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
