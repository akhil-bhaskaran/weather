part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email, password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String email, password;

  AuthSignUpRequested({required this.email, required this.password});
}

class AuthToggleToLogin extends AuthEvent {}

class AuthToggleToSingUp extends AuthEvent {}
