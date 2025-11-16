import 'package:equatable/equatable.dart';

/// Base class for splash events
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the splash screen
class StartSplash extends SplashEvent {
  const StartSplash();
}

/// Event to check onboarding status
class CheckOnboardingStatus extends SplashEvent {
  const CheckOnboardingStatus();
}

