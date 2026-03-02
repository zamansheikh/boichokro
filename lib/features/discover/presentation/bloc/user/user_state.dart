import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserPhotoUpdated extends UserState {
  final String photoUrl;

  const UserPhotoUpdated(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class UserProfileUpdated extends UserState {
  final User user;

  const UserProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserActionSuccess extends UserState {
  final String message;

  const UserActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
