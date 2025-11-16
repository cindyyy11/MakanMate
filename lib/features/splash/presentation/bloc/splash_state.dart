import 'package:equatable/equatable.dart';

/// Base class for splash states
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial splash state
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Splash is loading/animating
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// Splash animation complete, navigate to onboarding
class NavigateToOnboarding extends SplashState {
  const NavigateToOnboarding();
}

/// Splash animation complete, navigate to auth/home
class NavigateToAuth extends SplashState {
  const NavigateToAuth();
}

/// Error state
class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}

