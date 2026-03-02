import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/request_repository.dart';

/// Use case for deleting a request
@injectable
class DeleteRequestUseCase implements UseCase<void, DeleteRequestParams> {
  final RequestRepository repository;

  DeleteRequestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRequestParams params) async {
    return await repository.deleteRequest(params.requestId);
  }
}

class DeleteRequestParams {
  final String requestId;

  DeleteRequestParams(this.requestId);
}
