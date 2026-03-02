import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository interface for user operations
abstract class UserRepository {
  /// Get current user
  Future<Either<Failure, User>> getCurrentUser();

  /// Get user by ID
  Future<Either<Failure, User>> getUserById(String userId);

  /// Update user profile
  Future<Either<Failure, User>> updateUserProfile(User user);

  /// Update user photo
  Future<Either<Failure, String>> updateUserPhoto(String userId, String filePath);

  /// Block a user
  Future<Either<Failure, void>> blockUser(String userId);

  /// Report a user
  Future<Either<Failure, void>> reportUser(String userId, String reason);

  /// Rate a user after exchange
  Future<Either<Failure, void>> rateUser({
    required String userId,
    required int rating,
    String? comment,
  });
}
