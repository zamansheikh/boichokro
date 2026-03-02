import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../discover/domain/entities/user.dart';
import '../../../discover/domain/repositories/auth_repository.dart';

/// Use case for getting current authenticated user
@injectable
class GetCurrentAuthUserUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GetCurrentAuthUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
