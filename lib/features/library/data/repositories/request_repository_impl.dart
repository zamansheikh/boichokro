import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_remote_datasource.dart';
import '../models/request_model.dart';

@LazySingleton(as: RequestRepository)
class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;

  RequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, BookRequest>> createRequest(
    BookRequest request,
  ) async {
    try {
      final requestModel = BookRequestModel.fromEntity(request);
      final result = await remoteDataSource.createRequest(requestModel);
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
  Future<Either<Failure, BookRequest>> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    try {
      final result = await remoteDataSource.updateRequestStatus(
        requestId,
        status.name,
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
  Future<Either<Failure, BookRequest>> confirmExchange(
    String requestId,
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.confirmExchange(requestId, userId);
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
  Future<Either<Failure, BookRequest>> getRequestById(String requestId) async {
    try {
      final result = await remoteDataSource.getRequestById(requestId);
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
  Future<Either<Failure, List<BookRequest>>> getRequestsForBook(
    String bookId,
  ) async {
    try {
      final results = await remoteDataSource.getRequestsForBook(bookId);
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
  Future<Either<Failure, List<BookRequest>>> getRequestsBySeeker(
    String seekerId,
  ) async {
    try {
      final results = await remoteDataSource.getRequestsBySeeker(seekerId);
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
  Future<Either<Failure, List<BookRequest>>> getRequestsByOwner(
    String ownerId,
  ) async {
    try {
      final results = await remoteDataSource.getRequestsByOwner(ownerId);
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
  Future<Either<Failure, void>> deleteRequest(String requestId) async {
    try {
      await remoteDataSource.deleteRequest(requestId);
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
  Future<Either<Failure, BookRequest>> submitReview({
    required String requestId,
    required String reviewerId,
    required double rating,
    required String reviewText,
  }) async {
    try {
      final result = await remoteDataSource.submitReview(
        requestId: requestId,
        reviewerId: reviewerId,
        rating: rating,
        reviewText: reviewText,
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
}
