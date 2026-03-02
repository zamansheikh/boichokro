import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.participantIds,
    super.lastMessage,
    super.lastMessageTime,
    required super.unreadCount,
    required super.createdAt,
    required super.updatedAt,
    super.bookId,
    super.bookName,
    super.ownerName,
    super.requesterName,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: _convertTimestamp(json['lastMessageTime']),
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
      createdAt: _convertTimestampRequired(json['createdAt']),
      updatedAt: _convertTimestampRequired(json['updatedAt']),
      bookId: json['bookId'] as String?,
      bookName: json['bookName'] as String?,
      ownerName: json['ownerName'] as String?,
      requesterName: json['requesterName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'bookId': bookId,
      'bookName': bookName,
      'ownerName': ownerName,
      'requesterName': requesterName,
    };
  }

  factory ChatRoomModel.fromEntity(ChatRoom chatRoom) {
    return ChatRoomModel(
      id: chatRoom.id,
      participantIds: chatRoom.participantIds,
      lastMessage: chatRoom.lastMessage,
      lastMessageTime: chatRoom.lastMessageTime,
      unreadCount: chatRoom.unreadCount,
      createdAt: chatRoom.createdAt,
      updatedAt: chatRoom.updatedAt,
      bookId: chatRoom.bookId,
      bookName: chatRoom.bookName,
      ownerName: chatRoom.ownerName,
      requesterName: chatRoom.requesterName,
    );
  }

  ChatRoom toEntity() => this;
}

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.chatRoomId,
    required super.senderId,
    required super.content,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatRoomId: json['chatRoomId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] as bool,
      createdAt: _convertTimestampRequired(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      chatRoomId: message.chatRoomId,
      senderId: message.senderId,
      content: message.content,
      type: message.type,
      isRead: message.isRead,
      createdAt: message.createdAt,
    );
  }

  Message toEntity() => this;
}

// Helper functions to convert Firestore Timestamp to DateTime
DateTime? _convertTimestamp(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
  return null;
}

DateTime _convertTimestampRequired(dynamic timestamp) {
  if (timestamp == null) return DateTime.now();
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateTime.now();
}
