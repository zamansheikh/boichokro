import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for getting requests by owner
@injectable
class GetRequestsByOwnerUseCase
    implements UseCase<List<BookRequest>, GetRequestsByOwnerParams> {
  final RequestRepository repository;

  GetRequestsByOwnerUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookRequest>>> call(
    GetRequestsByOwnerParams params,
  ) async {
    return await repository.getRequestsByOwner(params.ownerId);
  }
}

class GetRequestsByOwnerParams {
  final String ownerId;

  GetRequestsByOwnerParams(this.ownerId);
}
