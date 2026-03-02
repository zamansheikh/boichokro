import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/request.dart';
import '../repositories/request_repository.dart';

/// Use case for confirming an exchange by owner or seeker
@injectable
class ConfirmExchangeUseCase
    implements UseCase<BookRequest, ConfirmExchangeParams> {
  final RequestRepository repository;

  ConfirmExchangeUseCase(this.repository);

  @override
  Future<Either<Failure, BookRequest>> call(
    ConfirmExchangeParams params,
  ) async {
    return await repository.confirmExchange(params.requestId, params.userId);
  }
}

class ConfirmExchangeParams {
  final String requestId;
  final String userId;

  ConfirmExchangeParams({required this.requestId, required this.userId});
}
