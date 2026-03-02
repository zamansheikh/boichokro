import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class SignInWithGoogle extends AuthEvent {
  const SignInWithGoogle();
}

class SignOut extends AuthEvent {
  const SignOut();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
