import 'package:equatable/equatable.dart';
import '../../../discover/domain/entities/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfileInfo extends ProfileEvent {
  final User user;

  const UpdateProfileInfo(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateProfilePhoto extends ProfileEvent {
  final String userId;
  final String filePath;

  const UpdateProfilePhoto({required this.userId, required this.filePath});

  @override
  List<Object?> get props => [userId, filePath];
}
