import 'package:injectable/injectable.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

/// Stream-based use case for subscribing to chat room updates
@injectable
class SubscribeToChatRoomUseCase {
  final ChatRepository repository;

  SubscribeToChatRoomUseCase(this.repository);

  Stream<ChatRoom> call(String chatRoomId) {
    return repository.subscribeToChatRoom(chatRoomId);
  }
}
