import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../domain/entities/chat.dart';
import '../../../library/domain/entities/request.dart';
import '../../../library/presentation/widgets/request_timeline_widget.dart';
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
  late ChatBloc _chatBloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatRoom? _chatRoom;
  BookRequest? _bookRequest;

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<ChatBloc>()
      ..add(LoadChatRoom(widget.roomId))
      ..add(SubscribeToMessages(widget.roomId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_chatRoom != null) {
      final message = Message(
        id: '', // Will be set by backend
        chatRoomId: _chatRoom!.id,
        senderId: getIt<FirebaseService>().currentUser!.uid,
        content: text,
        type: MessageType.text,
        isRead: false,
        createdAt: DateTime.now(),
      );
      _chatBloc.add(SendMessage(message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _showTimelineDialog() {
    if (_bookRequest == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Timeline',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              RequestTimelineWidget(
                request: _bookRequest!,
                isSeeker:
                    getIt<FirebaseService>().currentUser!.uid ==
                    _bookRequest!.seekerId,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<FirebaseService>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(_chatRoom?.chatName ?? 'Chat'),
        actions: [
          if (_chatRoom?.bookId != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => context.push('/book/${_chatRoom!.bookId}'),
              tooltip: 'View Book Details',
            ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: _chatBloc,
        listener: (context, state) {
          // Update chatRoom when loaded
          if (state is ChatRoomLoaded) {
            setState(() {
              _chatRoom = state.chatRoom;
            });
          }
        },
        builder: (context, state) {
          // Show loading only if we don't have chat room data yet
          if (state is ChatLoading && _chatRoom == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatError && _chatRoom == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _chatBloc.add(LoadChatRoom(widget.roomId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_chatRoom == null) {
            return const Center(child: Text('Chat room not found'));
          }

          final messages = state is MessagesLoaded
              ? state.messages
              : <Message>[];

          return Column(
            children: [
              // Book Info Section
              _buildBookInfoSection(),

              // Current Status Section
              if (_bookRequest != null) _buildStatusSection(),

              // Exchange Arrangement Section
              if (_bookRequest != null &&
                  _bookRequest!.status == RequestStatus.accepted &&
                  _bookRequest!.exchangeMethod != null)
                _buildExchangeArrangement(),

              const Divider(height: 1),

              // Messages List
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == currentUserId;
                          final showDate =
                              index == messages.length - 1 ||
                              !_isSameDay(
                                message.createdAt,
                                messages[index + 1].createdAt,
                              );

                          return Column(
                            children: [
                              if (showDate)
                                _buildDateSeparator(message.createdAt),
                              _buildMessageBubble(message, isMe),
                            ],
                          );
                        },
                      ),
              ),

              // Message Input
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookInfoSection() {
    if (_chatRoom == null || _chatRoom!.bookId == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.menu_book, color: Colors.grey[400], size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Book information not available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => context.push('/book/${_chatRoom!.bookId}'),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book Cover Icon
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, color: Colors.grey, size: 32),
            ),
            const SizedBox(width: 16),

            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chatRoom!.bookName ?? 'Unknown Book',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (_chatRoom!.ownerName != null) ...[
                    Text(
                      'Owner: ${_chatRoom!.ownerName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (_chatRoom!.requesterName != null)
                    Text(
                      'Requester: ${_chatRoom!.requesterName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(Icons.arrow_forward, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    if (_bookRequest == null) return const SizedBox.shrink();

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_bookRequest!.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending Approval';
        statusIcon = Icons.schedule;
        break;
      case RequestStatus.accepted:
        statusColor = Colors.green;
        statusText = 'Accepted';
        statusIcon = Icons.check_circle;
        break;
      case RequestStatus.declined:
        statusColor = Colors.red;
        statusText = 'Declined';
        statusIcon = Icons.cancel;
        break;
      case RequestStatus.completed:
        statusColor = Colors.blue;
        statusText = 'Completed';
        statusIcon = Icons.done_all;
        break;
      case RequestStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        statusIcon = Icons.close;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Chip(
                label: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: statusColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          if (_bookRequest!.status == RequestStatus.accepted ||
              _bookRequest!.status == RequestStatus.completed) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _showTimelineDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timeline, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      'View Request Timeline',
                      style: TextStyle(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: statusColor),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExchangeArrangement() {
    if (_bookRequest == null) return const SizedBox.shrink();

    final exchangeMethod = _bookRequest!.exchangeMethod;
    if (exchangeMethod == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                exchangeMethod == ExchangeMethod.meetup
                    ? Icons.location_on
                    : Icons.local_shipping,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Exchange Arrangement',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (exchangeMethod == ExchangeMethod.meetup) ...[
            if (_bookRequest!.meetingTime != null) ...[
              _buildInfoRow(
                Icons.schedule,
                'Meeting Time',
                DateFormat(
                  'MMM dd, yyyy • hh:mm a',
                ).format(_bookRequest!.meetingTime!),
              ),
              const SizedBox(height: 8),
            ],
            if (_bookRequest!.meetingLocation != null)
              _buildInfoRow(
                Icons.place,
                'Location',
                _bookRequest!.meetingLocation!,
              ),
          ] else if (exchangeMethod == ExchangeMethod.courier) ...[
            if (_bookRequest!.courierMethod != null) ...[
              _buildInfoRow(
                Icons.local_shipping,
                'Courier Service',
                _bookRequest!.courierMethod!,
              ),
              const SizedBox(height: 8),
            ],
            if (_bookRequest!.trackingId != null)
              _buildInfoRow(
                Icons.qr_code,
                'Tracking ID',
                _bookRequest!.trackingId!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Yesterday';
    } else if (date.year == now.year) {
      dateText = DateFormat('MMMM d').format(date);
    } else {
      dateText = DateFormat('MMMM d, y').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
