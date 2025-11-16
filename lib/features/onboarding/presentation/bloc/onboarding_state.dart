import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/onboarding/domain/entities/onboarding_page_entity.dart';

/// Base class for onboarding states
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial onboarding state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Loading onboarding pages
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Onboarding pages loaded
class OnboardingLoaded extends OnboardingState {
  final List<OnboardingPageEntity> pages;
  final int currentPage;
  final bool isLastPage;

  const OnboardingLoaded({
    required this.pages,
    required this.currentPage,
    required this.isLastPage,
  });

  @override
  List<Object?> get props => [pages, currentPage, isLastPage];

  OnboardingLoaded copyWith({
    List<OnboardingPageEntity>? pages,
    int? currentPage,
    bool? isLastPage,
  }) {
    return OnboardingLoaded(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

/// Onboarding completed, navigate to auth
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// Error state
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

