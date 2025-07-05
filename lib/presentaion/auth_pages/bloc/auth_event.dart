part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email, password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String username, email, password, cpassword;

  AuthSignUpRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.cpassword,
  });
}

class AuthToggleToLogin extends AuthEvent {}

class AuthToggleToSingUp extends AuthEvent {}
