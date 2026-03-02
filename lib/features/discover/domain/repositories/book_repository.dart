import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book.dart';

/// Repository interface for book operations
abstract class BookRepository {
  /// Add a new book
  Future<Either<Failure, Book>> addBook(Book book);

  /// Update an existing book
  Future<Either<Failure, Book>> updateBook(Book book);

  /// Delete a book
  Future<Either<Failure, void>> deleteBook(String bookId);

  /// Get a book by ID
  Future<Either<Failure, Book>> getBookById(String bookId);

  /// Get books by owner ID
  Future<Either<Failure, List<Book>>> getBooksByOwnerId(String ownerId);

  /// Search books nearby with filters
  Future<Either<Failure, List<Book>>> searchNearbyBooks({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchQuery,
    List<String>? genres,
    int? minCondition,
    BookMode? mode,
  });

  /// Get all books (for map view)
  Future<Either<Failure, List<Book>>> getAllBooks();
}
