import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:makan_mate/features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';
import 'package:makan_mate/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:makan_mate/features/onboarding/presentation/bloc/onboarding_state.dart';

/// BLoC for managing onboarding logic
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingPagesUseCase getOnboardingPages;
  final CompleteOnboardingUseCase completeOnboarding;
  final Logger logger;

  OnboardingBloc({
    required this.getOnboardingPages,
    required this.completeOnboarding,
    required this.logger,
  }) : super(const OnboardingInitial()) {
    on<LoadOnboardingPages>(_onLoadOnboardingPages);
    on<NextPage>(_onNextPage);
    on<PreviousPage>(_onPreviousPage);
    on<SkipOnboarding>(_onSkipOnboarding);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<UpdateCurrentPage>(_onUpdateCurrentPage);
  }

  Future<void> _onLoadOnboardingPages(
    LoadOnboardingPages event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(const OnboardingLoading());

      final result = await getOnboardingPages.call();

      result.fold(
        (failure) {
          logger.e('Error loading onboarding pages: $failure');
          emit(OnboardingError(failure.toString()));
        },
        (pages) {
          emit(OnboardingLoaded(
            pages: pages,
            currentPage: 0,
            isLastPage: pages.length == 1,
          ));
        },
      );
    } catch (e) {
      logger.e('Error loading onboarding pages: $e');
      emit(OnboardingError(e.toString()));
    }
  }

  void _onNextPage(
    NextPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      final nextPage = currentState.currentPage + 1;

      if (nextPage < currentState.pages.length) {
        emit(currentState.copyWith(
          currentPage: nextPage,
          isLastPage: nextPage == currentState.pages.length - 1,
        ));
      }
    }
  }

  void _onPreviousPage(
    PreviousPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      final previousPage = currentState.currentPage - 1;

      if (previousPage >= 0) {
        emit(currentState.copyWith(
          currentPage: previousPage,
          isLastPage: false,
        ));
      }
    }
  }

  Future<void> _onSkipOnboarding(
    SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final result = await completeOnboarding.call();
      
      result.fold(
        (failure) {
          logger.e('Error skipping onboarding: $failure');
          emit(OnboardingError(failure.toString()));
        },
        (_) {
          emit(const OnboardingCompleted());
        },
      );
    } catch (e) {
      logger.e('Error skipping onboarding: $e');
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final result = await completeOnboarding.call();
      
      result.fold(
        (failure) {
          logger.e('Error completing onboarding: $failure');
          emit(OnboardingError(failure.toString()));
        },
        (_) {
          emit(const OnboardingCompleted());
        },
      );
    } catch (e) {
      logger.e('Error completing onboarding: $e');
      emit(OnboardingError(e.toString()));
    }
  }

  void _onUpdateCurrentPage(
    UpdateCurrentPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      emit(currentState.copyWith(
        currentPage: event.pageIndex,
        isLastPage: event.pageIndex == currentState.pages.length - 1,
      ));
    }
  }
}

