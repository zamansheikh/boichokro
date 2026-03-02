import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../discover/domain/entities/user.dart';
import '../../../discover/domain/repositories/user_repository.dart';

/// Use case for updating user profile
@injectable
class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateUserProfile(params.user);
  }
}

class UpdateProfileParams {
  final User user;

  UpdateProfileParams(this.user);
}
