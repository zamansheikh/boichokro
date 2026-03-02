import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for getting requests for a book
@injectable
class GetRequestsForBookUseCase
    implements UseCase<List<BookRequest>, GetRequestsForBookParams> {
  final RequestRepository repository;

  GetRequestsForBookUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookRequest>>> call(
    GetRequestsForBookParams params,
  ) async {
    return await repository.getRequestsForBook(params.bookId);
  }
}

class GetRequestsForBookParams {
  final String bookId;

  GetRequestsForBookParams(this.bookId);
}
