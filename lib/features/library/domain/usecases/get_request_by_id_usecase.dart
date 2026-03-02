import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for getting request by ID
@injectable
class GetRequestByIdUseCase
    implements UseCase<BookRequest, GetRequestByIdParams> {
  final RequestRepository repository;

  GetRequestByIdUseCase(this.repository);

  @override
  Future<Either<Failure, BookRequest>> call(GetRequestByIdParams params) async {
    return await repository.getRequestById(params.requestId);
  }
}

class GetRequestByIdParams {
  final String requestId;

  GetRequestByIdParams(this.requestId);
}
