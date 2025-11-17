import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_in_as_guest_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GoogleSignInUseCase googleSignIn;
  final SignInAsGuestUseCase signInAsGuest;
  final ForgotPasswordUseCase forgotPassword;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.googleSignIn,
    required this.signInAsGuest,
    required this.forgotPassword,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<GuestSignInRequested>(_onGuestSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Check if user is already signed in
    // This would typically call a getCurrentUser use case
    // For now, emit Unauthenticated
    // TODO: wire a GetCurrentUserUseCase or authStateChanges stream
    await Future.delayed(const Duration(milliseconds: 500));
    emit(Unauthenticated());
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signIn(email: event.email, password: event.password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signUp(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      role: event.role,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await googleSignIn();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onGuestSignInRequested(
    GuestSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signInAsGuest();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Unauthenticated()),
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ForgotPasswordLoading());

    final result = await forgotPassword(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(
        const ForgotPasswordSuccess(
          'Password reset email sent! Please check your inbox.',
        ),
      ),
    );
  }
}
