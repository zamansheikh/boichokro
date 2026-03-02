import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/user_usecases.dart';
import 'user_event.dart';
import 'user_state.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UpdateUserPhotoUseCase updateUserPhotoUseCase;
  final BlockUserUseCase blockUserUseCase;
  final ReportUserUseCase reportUserUseCase;
  final RateUserUseCase rateUserUseCase;

  UserBloc({
    required this.getCurrentUserUseCase,
    required this.getUserByIdUseCase,
    required this.updateUserProfileUseCase,
    required this.updateUserPhotoUseCase,
    required this.blockUserUseCase,
    required this.reportUserUseCase,
    required this.rateUserUseCase,
  }) : super(const UserInitial()) {
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<LoadUserById>(_onLoadUserById);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdatePhoto>(_onUpdatePhoto);
    on<BlockUser>(_onBlockUser);
    on<ReportUser>(_onReportUser);
    on<RateUser>(_onRateUser);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await getCurrentUserUseCase(const NoParams());
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> _onLoadUserById(
    LoadUserById event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await getUserByIdUseCase(GetUserByIdParams(event.userId));
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await updateUserProfileUseCase(
      UpdateUserProfileParams(event.user),
    );
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserProfileUpdated(user)),
    );
  }

  Future<void> _onUpdatePhoto(
    UpdatePhoto event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    final result = await updateUserPhotoUseCase(
      UpdateUserPhotoParams(
        userId: event.userId,
        filePath: event.filePath,
      ),
    );
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (photoUrl) => emit(UserPhotoUpdated(photoUrl)),
    );
  }

  Future<void> _onBlockUser(BlockUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final result = await blockUserUseCase(BlockUserParams(event.userId));
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) => emit(const UserActionSuccess('User blocked successfully')),
    );
  }

  Future<void> _onReportUser(ReportUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final result = await reportUserUseCase(
      ReportUserParams(userId: event.userId, reason: event.reason),
    );
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) => emit(const UserActionSuccess('User reported successfully')),
    );
  }

  Future<void> _onRateUser(RateUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final result = await rateUserUseCase(
      RateUserParams(
        userId: event.userId,
        rating: event.rating,
        comment: event.comment,
      ),
    );
    
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) => emit(const UserActionSuccess('Rating submitted successfully')),
    );
  }
}
