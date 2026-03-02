import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../discover/domain/repositories/user_repository.dart';

/// Use case for updating user profile photo
@injectable
class UpdateProfilePhotoUseCase
    implements UseCase<String, UpdateProfilePhotoParams> {
  final UserRepository repository;

  UpdateProfilePhotoUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateProfilePhotoParams params) async {
    return await repository.updateUserPhoto(params.userId, params.filePath);
  }
}

class UpdateProfilePhotoParams {
  final String userId;
  final String filePath;

  UpdateProfilePhotoParams({required this.userId, required this.filePath});
}
