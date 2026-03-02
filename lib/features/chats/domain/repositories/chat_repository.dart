import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  /// Create or get existing chat room between users
  Future<Either<Failure, ChatRoom>> createOrGetChatRoom(
    List<String> participantIds, {
    String? bookId,
    String? bookName,
    String? ownerName,
    String? requesterName,
  });

  /// Get chat room by ID
  Future<Either<Failure, ChatRoom>> getChatRoomById(String chatRoomId);

  /// Get all chat rooms for current user
  Future<Either<Failure, List<ChatRoom>>> getUserChatRooms(String userId);

  /// Send message
  Future<Either<Failure, Message>> sendMessage(Message message);

  /// Get messages for a chat room
  Future<Either<Failure, List<Message>>> getMessages(
    String chatRoomId, {
    int? limit,
    String? lastMessageId,
  });

  /// Mark messages as read
  Future<Either<Failure, void>> markMessagesAsRead(
    String chatRoomId,
    String userId,
  );

  /// Subscribe to realtime messages
  Stream<Message> subscribeToMessages(String chatRoomId);

  /// Subscribe to chat room updates
  Stream<ChatRoom> subscribeToChatRoom(String chatRoomId);
}
