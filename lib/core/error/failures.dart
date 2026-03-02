import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server-related failures (Appwrite)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache-related failures (Local storage)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network-related failures (No internet)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Location-related failures (GPS, permissions)
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failures (Form inputs, etc.)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Permission failures (Camera, location, etc.)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// General/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
