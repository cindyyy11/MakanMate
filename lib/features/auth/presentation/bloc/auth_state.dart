import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Represents the initial auth state before any check or action.
class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  
  const Authenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

/// Represents an error during authentication.
class Unauthenticated extends AuthState {}

class ForgotPasswordSuccess extends AuthState {
  final String message;
  
  const ForgotPasswordSuccess(this.message);
  
  @override
  List<Object> get props => [message];
}

class ForgotPasswordLoading extends AuthState {}

/// Represents an error during authentication.
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

class AuthBlocked extends AuthState {
  final String message;
  AuthBlocked(this.message);

  @override
  List<Object?> get props => [message];
}