import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for adding a new book
@injectable
class AddBookUseCase implements UseCase<Book, AddBookParams> {
  final BookRepository repository;

  AddBookUseCase(this.repository);

  @override
  Future<Either<Failure, Book>> call(AddBookParams params) async {
    return await repository.addBook(params.book);
  }
}

class AddBookParams {
  final Book book;

  AddBookParams(this.book);
}

/// Use case for updating a book
@injectable
class UpdateBookUseCase implements UseCase<Book, UpdateBookParams> {
  final BookRepository repository;

  UpdateBookUseCase(this.repository);

  @override
  Future<Either<Failure, Book>> call(UpdateBookParams params) async {
    return await repository.updateBook(params.book);
  }
}

class UpdateBookParams {
  final Book book;

  UpdateBookParams(this.book);
}

/// Use case for deleting a book
@injectable
class DeleteBookUseCase implements UseCase<void, DeleteBookParams> {
  final BookRepository repository;

  DeleteBookUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBookParams params) async {
    return await repository.deleteBook(params.bookId);
  }
}

class DeleteBookParams {
  final String bookId;

  DeleteBookParams(this.bookId);
}

/// Use case for getting a book by ID
@injectable
class GetBookByIdUseCase implements UseCase<Book, GetBookByIdParams> {
  final BookRepository repository;

  GetBookByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Book>> call(GetBookByIdParams params) async {
    return await repository.getBookById(params.bookId);
  }
}

class GetBookByIdParams {
  final String bookId;

  GetBookByIdParams(this.bookId);
}

/// Use case for getting books by owner ID
@injectable
class GetBooksByOwnerUseCase implements UseCase<List<Book>, GetBooksByOwnerParams> {
  final BookRepository repository;

  GetBooksByOwnerUseCase(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(GetBooksByOwnerParams params) async {
    return await repository.getBooksByOwnerId(params.ownerId);
  }
}

class GetBooksByOwnerParams {
  final String ownerId;

  GetBooksByOwnerParams(this.ownerId);
}

/// Use case for searching nearby books with filters
@injectable
class SearchNearbyBooksUseCase implements UseCase<List<Book>, SearchNearbyBooksParams> {
  final BookRepository repository;

  SearchNearbyBooksUseCase(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(SearchNearbyBooksParams params) async {
    return await repository.searchNearbyBooks(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
      searchQuery: params.searchQuery,
      genres: params.genres,
      minCondition: params.minCondition,
      mode: params.mode,
    );
  }
}

class SearchNearbyBooksParams {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? searchQuery;
  final List<String>? genres;
  final int? minCondition;
  final BookMode? mode;

  SearchNearbyBooksParams({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.searchQuery,
    this.genres,
    this.minCondition,
    this.mode,
  });
}

/// Use case for getting all books
@injectable
class GetAllBooksUseCase implements UseCase<List<Book>, NoParams> {
  final BookRepository repository;

  GetAllBooksUseCase(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(NoParams params) async {
    return await repository.getAllBooks();
  }
}
