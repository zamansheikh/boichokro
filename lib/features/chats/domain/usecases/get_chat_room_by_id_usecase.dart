import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

/// Use case for getting chat room by ID
@injectable
class GetChatRoomByIdUseCase
    implements UseCase<ChatRoom, GetChatRoomByIdParams> {
  final ChatRepository repository;

  GetChatRoomByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ChatRoom>> call(GetChatRoomByIdParams params) async {
    return await repository.getChatRoomById(params.chatRoomId);
  }
}

class GetChatRoomByIdParams {
  final String chatRoomId;

  GetChatRoomByIdParams(this.chatRoomId);
}
