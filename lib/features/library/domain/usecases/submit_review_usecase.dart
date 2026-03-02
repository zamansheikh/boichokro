import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for submitting a review after a completed exchange
@injectable
class SubmitReviewUseCase implements UseCase<BookRequest, SubmitReviewParams> {
  final RequestRepository repository;

  SubmitReviewUseCase(this.repository);

  @override
  Future<Either<Failure, BookRequest>> call(SubmitReviewParams params) async {
    return await repository.submitReview(
      requestId: params.requestId,
      reviewerId: params.reviewerId,
      rating: params.rating,
      reviewText: params.reviewText,
    );
  }
}

class SubmitReviewParams {
  final String requestId;
  final String reviewerId;
  final double rating;
  final String reviewText;

  SubmitReviewParams({
    required this.requestId,
    required this.reviewerId,
    required this.rating,
    required this.reviewText,
  });
}
