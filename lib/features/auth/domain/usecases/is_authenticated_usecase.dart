import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../discover/domain/repositories/auth_repository.dart';

/// Use case for checking if user is authenticated
@injectable
class IsAuthenticatedUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}
