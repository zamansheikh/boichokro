import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';
import '../models/book_model.dart';

@LazySingleton(as: BookRepository)
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Book>> addBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      final result = await remoteDataSource.addBook(bookModel);
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
  Future<Either<Failure, Book>> updateBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      final result = await remoteDataSource.updateBook(bookModel);
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
  Future<Either<Failure, void>> deleteBook(String bookId) async {
    try {
      await remoteDataSource.deleteBook(bookId);
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
  Future<Either<Failure, Book>> getBookById(String bookId) async {
    try {
      final result = await remoteDataSource.getBookById(bookId);
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
  Future<Either<Failure, List<Book>>> getBooksByOwnerId(String ownerId) async {
    try {
      final results = await remoteDataSource.getBooksByOwnerId(ownerId);
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
  Future<Either<Failure, List<Book>>> searchNearbyBooks({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchQuery,
    List<String>? genres,
    int? minCondition,
    BookMode? mode,
  }) async {
    try {
      final results = await remoteDataSource.searchNearbyBooks(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        searchQuery: searchQuery,
        genres: genres,
        minCondition: minCondition,
        mode: mode?.name,
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
  Future<Either<Failure, List<Book>>> getAllBooks() async {
    try {
      final results = await remoteDataSource.getAllBooks();
      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
