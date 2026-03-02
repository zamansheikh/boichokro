import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
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

  late ChatBloc _chatBloc;

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
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final currentUser = getIt<FirebaseService>().auth.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_outlined,
                size: 80,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text('Sign in to view chats', style: textTheme.titleLarge),
            ],
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                _chatBloc.add(LoadChatRooms(currentUser.uid));
              },
            ),
          ],
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatInitial) {
              return const Center(child: Text('Initializing...'));
            } else if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatRoomsLoaded) {
              final chatRooms = state.chatRooms;
              if (chatRooms.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 80,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No conversations yet',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Start a conversation by messaging a book owner',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.read<ChatBloc>().add(
                              LoadChatRooms(currentUser.uid),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _chatBloc.add(LoadChatRooms(currentUser.uid));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 120),
                  itemCount: chatRooms.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 76,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    // Get the other user's ID (not the current user)
                    final otherUserId = chatRoom.participantIds.firstWhere(
                      (id) => id != currentUser.uid,
                      orElse: () => '',
                    );

                    final hasUnread =
                        (chatRoom.unreadCount[currentUser.uid] ?? 0) > 0;

                    // Use formatted chat name if available, otherwise use last message
                    final chatTitle = chatRoom.chatName;
                    final chatSubtitle =
                        chatRoom.lastMessage ?? 'Start conversation';

                    return Container(
                      color: hasUnread
                          ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: chatRoom.bookId != null
                                ? const Icon(
                                    Icons.menu_book,
                                    color: Colors.white,
                                  )
                                : Text(
                                    otherUserId.substring(0, 2).toUpperCase(),
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          chatTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        subtitle: chatRoom.lastMessageTime != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatSubtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatTime(chatRoom.lastMessageTime!),
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                chatSubtitle,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                        trailing: hasUnread
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${chatRoom.unreadCount[currentUser.uid]}',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.chevron_right_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                        onTap: () {
                          context.push('${RoutePaths.chat}/${chatRoom.id}');
                        },
                      ),
                    );
                  },
                ),
              );
            } else if (state is ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _chatBloc.add(LoadChatRooms(currentUser.uid));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
