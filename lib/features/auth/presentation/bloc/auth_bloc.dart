import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/is_authenticated_usecase.dart';
import '../../domain/usecases/get_current_auth_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final IsAuthenticatedUseCase isAuthenticatedUseCase;
  final GetCurrentAuthUserUseCase getCurrentAuthUserUseCase;

  AuthBloc({
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.isAuthenticatedUseCase,
    required this.getCurrentAuthUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOut>(_onSignOut);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await isAuthenticatedUseCase(const NoParams());

    await result.fold((failure) async => emit(const AuthUnauthenticated()), (
      isAuthenticated,
    ) async {
      if (isAuthenticated) {
        // Fetch the current user
        final userResult = await getCurrentAuthUserUseCase(const NoParams());
        userResult.fold(
          (failure) => emit(const AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user)),
        );
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithGoogleUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signOutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final result = await isAuthenticatedUseCase(const NoParams());

    result.fold((failure) => emit(const AuthUnauthenticated()), (
      isAuthenticated,
    ) {
      if (!isAuthenticated) {
        emit(const AuthUnauthenticated());
      }
    });
  }
}
