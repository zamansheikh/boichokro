import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/request.dart';

/// Repository interface for book request operations
abstract class RequestRepository {
  /// Create a new request
  Future<Either<Failure, BookRequest>> createRequest(BookRequest request);

  /// Update request status
  Future<Either<Failure, BookRequest>> updateRequestStatus(
    String requestId,
    RequestStatus status,
  );

  /// Confirm exchange by one of the participants
  Future<Either<Failure, BookRequest>> confirmExchange(
    String requestId,
    String userId,
  );

  /// Get request by ID
  Future<Either<Failure, BookRequest>> getRequestById(String requestId);

  /// Get requests for a book
  Future<Either<Failure, List<BookRequest>>> getRequestsForBook(String bookId);

  /// Get requests by seeker
  Future<Either<Failure, List<BookRequest>>> getRequestsBySeeker(
    String seekerId,
  );

  /// Get requests by owner
  Future<Either<Failure, List<BookRequest>>> getRequestsByOwner(String ownerId);

  /// Delete request
  Future<Either<Failure, void>> deleteRequest(String requestId);

  /// Submit a review and rating for a completed exchange
  Future<Either<Failure, BookRequest>> submitReview({
    required String requestId,
    required String reviewerId,
    required double rating,
    required String reviewText,
  });
}
