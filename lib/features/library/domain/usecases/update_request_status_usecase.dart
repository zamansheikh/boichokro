import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for updating request status
@injectable
class UpdateRequestStatusUseCase
    implements UseCase<BookRequest, UpdateRequestStatusParams> {
  final RequestRepository repository;

  UpdateRequestStatusUseCase(this.repository);

  @override
  Future<Either<Failure, BookRequest>> call(
    UpdateRequestStatusParams params,
  ) async {
    return await repository.updateRequestStatus(
      params.requestId,
      params.status,
    );
  }
}

class UpdateRequestStatusParams {
  final String requestId;
  final RequestStatus status;

  UpdateRequestStatusParams({required this.requestId, required this.status});
}
