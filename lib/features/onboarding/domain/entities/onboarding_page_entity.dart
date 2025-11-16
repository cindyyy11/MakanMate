import 'package:equatable/equatable.dart';

/// Entity representing an onboarding page
class OnboardingPageEntity extends Equatable {
  final String title;
  final String description;
  final String? lottieAsset;
  final List<String> features;
  final String iconEmoji;

  const OnboardingPageEntity({
    required this.title,
    required this.description,
    this.lottieAsset,
    this.features = const [],
    this.iconEmoji = '🎉',
  });

  @override
  List<Object?> get props => [
        title,
        description,
        lottieAsset,
        features,
        iconEmoji,
      ];
}

