import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

/// Use case for getting user's chat rooms
@injectable
class GetUserChatRoomsUseCase
    implements UseCase<List<ChatRoom>, GetUserChatRoomsParams> {
  final ChatRepository repository;

  GetUserChatRoomsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChatRoom>>> call(
    GetUserChatRoomsParams params,
  ) async {
    return await repository.getUserChatRooms(params.userId);
  }
}

class GetUserChatRoomsParams {
  final String userId;

  GetUserChatRoomsParams(this.userId);
}
