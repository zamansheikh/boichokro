import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google
@injectable
class SignInWithGoogleUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}

/// Use case for signing out
@injectable
class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}

/// Use case to check if user is authenticated
@injectable
class IsAuthenticatedUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}

/// Use case to get current user ID
@injectable
class GetCurrentUserIdUseCase implements UseCase<String, NoParams> {
  final AuthRepository repository;

  GetCurrentUserIdUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getCurrentUserId();
  }
}

/// Use case to get current authenticated user
@injectable
class GetCurrentAuthUserUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GetCurrentAuthUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
