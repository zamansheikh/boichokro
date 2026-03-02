import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

/// Use case for marking messages as read
@injectable
class MarkMessagesAsReadUseCase
    implements UseCase<void, MarkMessagesAsReadParams> {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkMessagesAsReadParams params) async {
    return await repository.markMessagesAsRead(
      params.chatRoomId,
      params.userId,
    );
  }
}

class MarkMessagesAsReadParams {
  final String chatRoomId;
  final String userId;

  MarkMessagesAsReadParams({required this.chatRoomId, required this.userId});
}
