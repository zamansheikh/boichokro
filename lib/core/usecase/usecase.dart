import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// [T] - Return type
/// [Params] - Parameters passed to the use case
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use case with no parameters
class NoParams {
  const NoParams();
}
