import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

/// Use case for getting messages
@injectable
class GetMessagesUseCase implements UseCase<List<Message>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      params.chatRoomId,
      limit: params.limit,
      lastMessageId: params.lastMessageId,
    );
  }
}

class GetMessagesParams {
  final String chatRoomId;
  final int? limit;
  final String? lastMessageId;

  GetMessagesParams({required this.chatRoomId, this.limit, this.lastMessageId});
}
