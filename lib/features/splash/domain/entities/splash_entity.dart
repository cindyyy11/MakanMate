import 'package:equatable/equatable.dart';

/// Entity representing splash screen configuration
class SplashEntity extends Equatable {
  final String logoPath;
  final Duration duration;
  final bool shouldNavigateToOnboarding;

  const SplashEntity({
    required this.logoPath,
    required this.duration,
    required this.shouldNavigateToOnboarding,
  });

  @override
  List<Object?> get props => [logoPath, duration, shouldNavigateToOnboarding];
}

