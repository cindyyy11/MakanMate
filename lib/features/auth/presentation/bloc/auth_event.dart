import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// When the app starts and checks for a logged-in user
class AppStarted extends AuthEvent {}

// When a user manually logs in
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});
}

// When a user signs in with Google
class GoogleSignInRequested extends AuthEvent {}

// When a user signs in with Facebook
class FacebookSignInRequested extends AuthEvent {}

// When a user logs out
class SignOutRequested extends AuthEvent {}

class AuthResetRequested extends AuthEvent {}