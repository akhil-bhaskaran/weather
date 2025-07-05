import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
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
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
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
          emit(
            AuthFailure(
              message:
                  'Account created! Please check your email to verify before logging in.',
            ),
          );
        } else {
          emit(AuthFailure(message: 'Signup failed'));
        }
      } on AuthException catch (e) {
        emit(AuthFailure(message: e.message));
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
