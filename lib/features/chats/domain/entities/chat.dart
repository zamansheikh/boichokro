import 'package:equatable/equatable.dart';

/// ChatRoom entity for chat between users
class ChatRoom extends Equatable {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount; // userId -> count
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bookId;
  final String? bookName;
  final String? ownerName;
  final String? requesterName;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.bookId,
    this.bookName,
    this.ownerName,
    this.requesterName,
  });

  @override
  List<Object?> get props => [
    id,
    participantIds,
    lastMessage,
    lastMessageTime,
    unreadCount,
    createdAt,
    updatedAt,
    bookId,
    bookName,
    ownerName,
    requesterName,
  ];

  /// Generate formatted chat name: "BookName - Owner & Requester"
  String get chatName {
    if (bookName != null && ownerName != null && requesterName != null) {
      return '$bookName - $ownerName & $requesterName';
    }
    return 'Chat';
  }

  ChatRoom copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bookId,
    String? bookName,
    String? ownerName,
    String? requesterName,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      ownerName: ownerName ?? this.ownerName,
      requesterName: requesterName ?? this.requesterName,
    );
  }
}

/// Message entity for chat messages
class Message extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    chatRoomId,
    senderId,
    content,
    type,
    isRead,
    createdAt,
  ];

  Message copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? content,
    MessageType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Message type enum
enum MessageType {
  text,
  location,
  system;

  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.location:
        return 'Location';
      case MessageType.system:
        return 'System';
    }
  }
}
