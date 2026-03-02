import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for creating a book request
@injectable
class CreateRequestUseCase
    implements UseCase<BookRequest, CreateRequestParams> {
  final RequestRepository repository;

  CreateRequestUseCase(this.repository);

  @override
  Future<Either<Failure, BookRequest>> call(CreateRequestParams params) async {
    return await repository.createRequest(params.request);
  }
}

class CreateRequestParams {
  final BookRequest request;

  CreateRequestParams(this.request);
}
