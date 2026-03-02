import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ChatRoom>> createOrGetChatRoom(
    List<String> participantIds, {
    String? bookId,
    String? bookName,
    String? ownerName,
    String? requesterName,
  }) async {
    try {
      final result = await remoteDataSource.createOrGetChatRoom(
        participantIds,
        bookId: bookId,
        bookName: bookName,
        ownerName: ownerName,
        requesterName: requesterName,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatRoom>> getChatRoomById(String chatRoomId) async {
    try {
      final result = await remoteDataSource.getChatRoomById(chatRoomId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatRoom>>> getUserChatRooms(
    String userId,
  ) async {
    try {
      final results = await remoteDataSource.getUserChatRooms(userId);
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      final result = await remoteDataSource.sendMessage(messageModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
    String chatRoomId, {
    int? limit,
    String? lastMessageId,
  }) async {
    try {
      final results = await remoteDataSource.getMessages(
        chatRoomId,
        limit: limit,
        lastMessageId: lastMessageId,
      );
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
    String chatRoomId,
    String userId,
  ) async {
    try {
      await remoteDataSource.markMessagesAsRead(chatRoomId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Message> subscribeToMessages(String chatRoomId) {
    return remoteDataSource.subscribeToMessages(chatRoomId);
  }

  @override
  Stream<ChatRoom> subscribeToChatRoom(String chatRoomId) {
    return remoteDataSource.subscribeToChatRoom(chatRoomId);
  }
}
