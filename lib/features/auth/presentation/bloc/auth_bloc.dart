import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    // Check user state at startup
    on<AppStarted>((event, emit) async {
      final user = _authService.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });

    // Email / Password login
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCred = await _authService.signInWithEmail(
          email: event.email,
          password: event.password,
        );
        if (userCred?.user != null) {
          emit(Authenticated(userCred!.user!));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError('Failed to sign in: $e'));
        emit(Unauthenticated());
      }
    });

    // Google Sign-In
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCred = await _authService.signInWithGoogle();
        if (userCred?.user != null) {
          emit(Authenticated(userCred!.user!));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError('Google sign in failed: $e'));
        emit(Unauthenticated());
      }
    });

    // Facebook Sign-In
    // on<FacebookSignInRequested>((event, emit) async {
    //   emit(AuthLoading());
    //   try {
    //     final userCred = await _authService.signInWithFacebook();
    //     if (userCred?.user != null) {
    //       emit(Authenticated(userCred!.user!));
    //     } else {
    //       emit(Unauthenticated());
    //     }
    //   } catch (e) {
    //     emit(AuthError('Facebook sign in failed: $e'));
    //     emit(Unauthenticated());
    //   }
    // });

    // Sign out
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await _authService.signOut();
      emit(Unauthenticated());
    });
  }
}
