import 'package:equatable/equatable.dart';
import '../../domain/entities/chat.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object?> get props => [chatRooms];
}

class ChatRoomLoaded extends ChatState {
  final ChatRoom chatRoom;

  const ChatRoomLoaded(this.chatRoom);

  @override
  List<Object?> get props => [chatRoom];
}

class MessagesLoaded extends ChatState {
  final List<Message> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageSent extends ChatState {
  final Message message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class NewMessage extends ChatState {
  final Message message;

  const NewMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkedAsRead extends ChatState {
  const MarkedAsRead();
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
