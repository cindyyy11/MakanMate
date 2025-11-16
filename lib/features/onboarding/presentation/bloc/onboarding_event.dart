import 'package:equatable/equatable.dart';

/// Base class for onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load onboarding pages
class LoadOnboardingPages extends OnboardingEvent {
  const LoadOnboardingPages();
}

/// Event to navigate to next page
class NextPage extends OnboardingEvent {
  const NextPage();
}

/// Event to navigate to previous page
class PreviousPage extends OnboardingEvent {
  const PreviousPage();
}

/// Event to skip onboarding
class SkipOnboarding extends OnboardingEvent {
  const SkipOnboarding();
}

/// Event to complete onboarding
class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

/// Event to update current page
class UpdateCurrentPage extends OnboardingEvent {
  final int pageIndex;

  const UpdateCurrentPage(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

