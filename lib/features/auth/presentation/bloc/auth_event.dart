import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when app starts to check if user is already signed in.
class AuthCheckRequested extends AuthEvent {}

/// Triggered when user submits email and password for login.
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;
  final String role;

  const SignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
    this.role = 'user',
  });

  @override
  List<Object?> get props => [email, password, displayName, role];
}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}

class AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
