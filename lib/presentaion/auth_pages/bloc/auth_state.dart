part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess({required this.user});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}

class AuthLoading extends AuthState {}

class ToggleToLoginState extends AuthState {}

class ToggleToSignUpState extends AuthState {}
