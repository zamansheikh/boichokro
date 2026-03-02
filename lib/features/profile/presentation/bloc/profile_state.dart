import 'package:equatable/equatable.dart';
import '../../../discover/domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfilePhotoUpdated extends ProfileState {
  final String photoUrl;

  const ProfilePhotoUpdated(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class ProfileUpdated extends ProfileState {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
