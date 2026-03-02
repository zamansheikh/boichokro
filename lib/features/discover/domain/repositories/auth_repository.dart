import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Get current session user ID
  Future<Either<Failure, String>> getCurrentUserId();
  
  /// Get current user
  Future<Either<Failure, User>> getCurrentUser();
}
