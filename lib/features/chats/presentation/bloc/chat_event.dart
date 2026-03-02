import 'package:equatable/equatable.dart';
import '../../domain/entities/chat.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRooms extends ChatEvent {
  final String userId;

  const LoadChatRooms(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadChatRoom extends ChatEvent {
  final String chatRoomId;

  const LoadChatRoom(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

class CreateOrGetChatRoom extends ChatEvent {
  final List<String> participantIds;
  final String? bookId;
  final String? bookName;
  final String? ownerName;
  final String? requesterName;

  const CreateOrGetChatRoom({
    required this.participantIds,
    this.bookId,
    this.bookName,
    this.ownerName,
    this.requesterName,
  });

  @override
  List<Object?> get props => [
    participantIds,
    bookId,
    bookName,
    ownerName,
    requesterName,
  ];
}

class LoadMessages extends ChatEvent {
  final String chatRoomId;
  final int? limit;
  final String? lastMessageId;

  const LoadMessages({
    required this.chatRoomId,
    this.limit,
    this.lastMessageId,
  });

  @override
  List<Object?> get props => [chatRoomId, limit, lastMessageId];
}

class SendMessage extends ChatEvent {
  final Message message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkAsRead extends ChatEvent {
  final String chatRoomId;
  final String userId;

  const MarkAsRead({required this.chatRoomId, required this.userId});

  @override
  List<Object?> get props => [chatRoomId, userId];
}

class SubscribeToMessages extends ChatEvent {
  final String chatRoomId;

  const SubscribeToMessages(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

class NewMessageReceived extends ChatEvent {
  final Message message;

  const NewMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
