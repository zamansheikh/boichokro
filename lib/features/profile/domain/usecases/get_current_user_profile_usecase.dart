import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../discover/domain/entities/user.dart';
import '../../../discover/domain/repositories/user_repository.dart';

/// Use case for getting current user profile
@injectable
class GetCurrentUserProfileUseCase implements UseCase<User, NoParams> {
  final UserRepository repository;

  GetCurrentUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
