import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for getting current user
@injectable
class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}

/// Use case for getting user by ID
@injectable
class GetUserByIdUseCase implements UseCase<User, GetUserByIdParams> {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(GetUserByIdParams params) async {
    return await repository.getUserById(params.userId);
  }
}

class GetUserByIdParams {
  final String userId;

  GetUserByIdParams(this.userId);
}

/// Use case for updating user profile
@injectable
class UpdateUserProfileUseCase implements UseCase<User, UpdateUserProfileParams> {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(params.user);
  }
}

class UpdateUserProfileParams {
  final User user;

  UpdateUserProfileParams(this.user);
}

/// Use case for updating user photo
@injectable
class UpdateUserPhotoUseCase implements UseCase<String, UpdateUserPhotoParams> {
  final UserRepository repository;

  UpdateUserPhotoUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateUserPhotoParams params) async {
    return await repository.updateUserPhoto(params.userId, params.filePath);
  }
}

class UpdateUserPhotoParams {
  final String userId;
  final String filePath;

  UpdateUserPhotoParams({
    required this.userId,
    required this.filePath,
  });
}

/// Use case for blocking a user
@injectable
class BlockUserUseCase implements UseCase<void, BlockUserParams> {
  final UserRepository repository;

  BlockUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(BlockUserParams params) async {
    return await repository.blockUser(params.userId);
  }
}

class BlockUserParams {
  final String userId;

  BlockUserParams(this.userId);
}

/// Use case for reporting a user
@injectable
class ReportUserUseCase implements UseCase<void, ReportUserParams> {
  final UserRepository repository;

  ReportUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ReportUserParams params) async {
    return await repository.reportUser(params.userId, params.reason);
  }
}

class ReportUserParams {
  final String userId;
  final String reason;

  ReportUserParams({
    required this.userId,
    required this.reason,
  });
}

/// Use case for rating a user
@injectable
class RateUserUseCase implements UseCase<void, RateUserParams> {
  final UserRepository repository;

  RateUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RateUserParams params) async {
    return await repository.rateUser(
      userId: params.userId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}

class RateUserParams {
  final String userId;
  final int rating;
  final String? comment;

  RateUserParams({
    required this.userId,
    required this.rating,
    this.comment,
  });
}
