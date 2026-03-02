import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

/// Use case for creating or getting existing chat room
@injectable
class CreateOrGetChatRoomUseCase
    implements UseCase<ChatRoom, CreateOrGetChatRoomParams> {
  final ChatRepository repository;

  CreateOrGetChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, ChatRoom>> call(
    CreateOrGetChatRoomParams params,
  ) async {
    return await repository.createOrGetChatRoom(
      params.participantIds,
      bookId: params.bookId,
      bookName: params.bookName,
      ownerName: params.ownerName,
      requesterName: params.requesterName,
    );
  }
}

class CreateOrGetChatRoomParams {
  final List<String> participantIds;
  final String? bookId;
  final String? bookName;
  final String? ownerName;
  final String? requesterName;

  CreateOrGetChatRoomParams({
    required this.participantIds,
    this.bookId,
    this.bookName,
    this.ownerName,
    this.requesterName,
  });
}
