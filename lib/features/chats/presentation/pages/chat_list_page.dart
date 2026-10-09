import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../discover/presentation/pages/home_page.dart';
import '../../domain/entities/chat.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

/// Chat List Page - All conversations
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ChatBloc? _chatBloc;

  @override
  void initState() {
    super.initState();
    final currentUser = getIt<FirebaseService>().auth.currentUser;
    if (currentUser != null) {
      _chatBloc = getIt<ChatBloc>()..add(LoadChatRooms(currentUser.uid));
    }
  }

  @override
  void dispose() {
    _chatBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final currentUser = getIt<FirebaseService>().auth.currentUser;
    final chatBloc = _chatBloc;

    if (currentUser == null || chatBloc == null) {
      return const Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChatsHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.navClearance),
                  child: AppEmptyState(
                    icon: LucideIcons.messagesSquare,
                    title: 'Sign in to view chats',
                    message:
                        'Your conversations with other readers will appear '
                        'here once you are signed in.',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final uid = currentUser.uid;
    void reload() => chatBloc.add(LoadChatRooms(uid));

    return BlocProvider.value(
      value: chatBloc,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final unreadRooms = state is ChatRoomsLoaded
                  ? state.chatRooms
                        .where((room) => (room.unreadCount[uid] ?? 0) > 0)
                        .length
                  : 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ChatsHeader(unreadRooms: unreadRooms, onRefresh: reload),
                  Expanded(
                    child: _buildBody(
                      context,
                      state,
                      uid: uid,
                      myName: currentUser.displayName,
                      reload: reload,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatState state, {
    required String uid,
    required String? myName,
    required VoidCallback reload,
  }) {
    if (state is ChatInitial || state is ChatLoading) {
      return const _ChatListSkeleton();
    }

    if (state is ChatError) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
        child: AppErrorState(message: state.message, onRetry: reload),
      );
    }

    if (state is ChatRoomsLoaded) {
      final chatRooms = state.chatRooms;

      if (chatRooms.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
          child: AppEmptyState(
            icon: LucideIcons.messagesSquare,
            title: 'No conversations yet',
            message:
                'A chat opens when you request a book, or when someone '
                'requests one of yours. Find a book you like to get started.',
            actionLabel: 'Discover books',
            actionIcon: LucideIcons.compass,
            onAction: () => HomePage.goToTab(context, 0),
            secondaryLabel: 'Refresh',
            onSecondary: reload,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => reload(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.navClearance,
          ),
          itemCount: chatRooms.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.page + 52 + AppSpacing.md,
            endIndent: AppSpacing.page,
            color: context.colors.outlineVariant.withValues(alpha: 0.6),
          ),
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            return _ChatRoomTile(
              chatRoom: chatRoom,
              unread: chatRoom.unreadCount[uid] ?? 0,
              myName: myName,
              onTap: () => context.push('${RoutePaths.chat}/${chatRoom.id}'),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Large serif page title with an unread summary and a refresh action.
class _ChatsHeader extends StatelessWidget {
  const _ChatsHeader({this.unreadRooms = 0, this.onRefresh});

  final int unreadRooms;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final subtitle = unreadRooms == 0
        ? 'Arrange hand-overs with other readers'
        : unreadRooms == 1
        ? '1 conversation has new messages'
        : '$unreadRooms conversations have new messages';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chats', style: context.text.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: unreadRooms > 0
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                    fontWeight: unreadRooms > 0 ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(width: AppSpacing.md),
            CircleIconButton(
              icon: LucideIcons.refreshCw,
              tooltip: 'Refresh',
              onPressed: onRefresh,
            ),
          ],
        ],
      ),
    );
  }
}

/// One conversation: the other reader, the book it is about, the latest
/// message and how many messages are waiting.
class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({
    required this.chatRoom,
    required this.unread,
    required this.myName,
    required this.onTap,
  });

  final ChatRoom chatRoom;
  final int unread;
  final String? myName;
  final VoidCallback onTap;

  /// The room stores both display names but not which participant is which,
  /// so the other reader is whichever name is not the signed-in user's.
  String get _otherName {
    final owner = chatRoom.ownerName?.trim() ?? '';
    final requester = chatRoom.requesterName?.trim() ?? '';
    final me = myName?.trim().toLowerCase() ?? '';

    if (owner.isEmpty && requester.isEmpty) return 'Reader';
    if (owner.isEmpty) return requester;
    if (requester.isEmpty) return owner;
    if (me.isNotEmpty && owner.toLowerCase() == me) return requester;
    if (me.isNotEmpty && requester.toLowerCase() == me) return owner;
    return '$owner & $requester';
  }

  String get _preview {
    final last = chatRoom.lastMessage?.trim() ?? '';
    if (last.isEmpty) return 'Say hello to get things started';
    if (last.startsWith('https://www.google.com/maps/')) {
      return 'Shared a location';
    }
    return last.replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return DateFormat(
        dateTime.year == now.year ? 'd MMM' : 'd MMM y',
      ).format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final hasUnread = unread > 0;
    final name = _otherName;
    final bookName = chatRoom.bookName?.trim() ?? '';
    final time = chatRoom.lastMessageTime;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(name: name, radius: 26),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium?.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (time != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatTime(time),
                          style: text.labelSmall?.copyWith(
                            color: hasUnread
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (bookName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.bookOpen,
                          size: 13,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs + 2),
                        Expanded(
                          child: Text(
                            bookName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            color: hasUnread
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                            fontWeight: hasUnread ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _UnreadBadge(count: unread),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count unread',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

/// Loading placeholder that mirrors the conversation rows.
class _ChatListSkeleton extends StatelessWidget {
  const _ChatListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.navClearance,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 52, height: 52, radius: AppRadius.pill),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xs),
                  Skeleton(width: 140, height: 16),
                  SizedBox(height: AppSpacing.sm),
                  Skeleton(width: 100, height: 12),
                  SizedBox(height: AppSpacing.sm),
                  Skeleton(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
