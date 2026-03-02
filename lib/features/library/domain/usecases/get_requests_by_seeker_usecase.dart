import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for getting requests by seeker
@injectable
class GetRequestsBySeekerUseCase
    implements UseCase<List<BookRequest>, GetRequestsBySeekerParams> {
  final RequestRepository repository;

  GetRequestsBySeekerUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookRequest>>> call(
    GetRequestsBySeekerParams params,
  ) async {
    return await repository.getRequestsBySeeker(params.seekerId);
  }
}

class GetRequestsBySeekerParams {
  final String seekerId;

  GetRequestsBySeekerParams(this.seekerId);
}
