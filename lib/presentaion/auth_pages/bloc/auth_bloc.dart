import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    bool tapOnSignUp = false;
    on<AuthToggleToLogin>((event, emit) => emit(ToggleToLoginState()));
    on<AuthToggleToSingUp>((event, emit) => emit(ToggleToSignUpState()));
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final AuthResponse response = await _supabase.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );

        final user = response.user;

        if (user != null) {
          if (user.emailConfirmedAt == null) {
            emit(
              AuthFailure(
                message: 'Please verify your email before logging in.',
              ),
            );
            await _supabase.auth.signOut(); // prevent session usage
            return;
          }
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthFailure(message: 'Invalid credentials'));
        }
      } on SocketException {
        emit(AuthFailure(message: "No Internet connection."));
      } on AuthException catch (e) {
        emit(AuthFailure(message: e.message));
      } catch (c) {
        emit(AuthFailure(message: "Unexpected Error."));
      }
    });

    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final AuthResponse response = await _supabase.auth.signUp(
          email: event.email,
          password: event.password,
        );

        if (response.user != null) {
          if (tapOnSignUp) {
            final res = await _supabase.auth.signInWithPassword(
              password: event.password,
              email: event.email,
            );
            final user = res.user;
            if (user != null) {
              if (user.emailConfirmedAt == null) {
                emit(
                  AuthFailure(
                    message: 'Please verify your email before logging in.',
                  ),
                );
                await _supabase.auth.signOut(); // prevent session usage
                return;
              }
              emit(AuthSuccess(user: user));
            }
          } else {
            tapOnSignUp = true;
            emit(
              AuthFailure(
                message:
                    'Account created! Please check your email to verify before logging in.',
              ),
            );
          }
        } else {
          emit(AuthFailure(message: 'Signup failed'));
        }
      } on SocketException {
        emit(AuthFailure(message: "No Internet connection."));
      } on AuthException catch (e) {
        emit(AuthFailure(message: e.message));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
  }
  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    Logger().e(
      "Transition from ${transition.currentState} to ${transition.nextState}",
    );
  }
}
