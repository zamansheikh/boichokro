/// Base exception class for all exceptions in the application
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Server-related exceptions (Appwrite errors)
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Cache-related exceptions (Local storage errors)
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Network-related exceptions (No internet connection)
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Location-related exceptions (GPS, permissions)
class LocationException extends AppException {
  const LocationException(super.message);
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(super.message);
}
