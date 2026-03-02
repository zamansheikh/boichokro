import 'package:injectable/injectable.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

/// Stream-based use case for subscribing to messages
@injectable
class SubscribeToMessagesUseCase {
  final ChatRepository repository;

  SubscribeToMessagesUseCase(this.repository);

  Stream<Message> call(String chatRoomId) {
    return repository.subscribeToMessages(chatRoomId);
  }
}
