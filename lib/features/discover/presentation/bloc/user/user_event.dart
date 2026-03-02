import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentUser extends UserEvent {
  const LoadCurrentUser();
}

class LoadUserById extends UserEvent {
  final String userId;

  const LoadUserById(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends UserEvent {
  final User user;

  const UpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdatePhoto extends UserEvent {
  final String userId;
  final String filePath;

  const UpdatePhoto({required this.userId, required this.filePath});

  @override
  List<Object?> get props => [userId, filePath];
}

class BlockUser extends UserEvent {
  final String userId;

  const BlockUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ReportUser extends UserEvent {
  final String userId;
  final String reason;

  const ReportUser({required this.userId, required this.reason});

  @override
  List<Object?> get props => [userId, reason];
}

class RateUser extends UserEvent {
  final String userId;
  final int rating;
  final String? comment;

  const RateUser({required this.userId, required this.rating, this.comment});

  @override
  List<Object?> get props => [userId, rating, comment];
}
