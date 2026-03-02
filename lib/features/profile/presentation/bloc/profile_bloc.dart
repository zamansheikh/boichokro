import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_current_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserProfileUseCase getCurrentUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateProfilePhotoUseCase updateProfilePhotoUseCase;

  ProfileBloc({
    required this.getCurrentUserProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateProfilePhotoUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileInfo>(_onUpdateProfileInfo);
    on<UpdateProfilePhoto>(_onUpdateProfilePhoto);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getCurrentUserProfileUseCase(const NoParams());

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfileInfo(
    UpdateProfileInfo event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await updateProfileUseCase(UpdateProfileParams(event.user));

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileUpdated(user)),
    );
  }

  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await updateProfilePhotoUseCase(
      UpdateProfilePhotoParams(userId: event.userId, filePath: event.filePath),
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (photoUrl) => emit(ProfilePhotoUpdated(photoUrl)),
    );
  }
}
