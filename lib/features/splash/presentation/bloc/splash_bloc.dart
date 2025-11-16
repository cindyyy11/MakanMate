import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/splash/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:makan_mate/features/splash/presentation/bloc/splash_event.dart';
import 'package:makan_mate/features/splash/presentation/bloc/splash_state.dart';

/// BLoC for managing splash screen logic
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckOnboardingStatusUseCase checkOnboardingStatus;
  final Logger logger;

  SplashBloc({
    required this.checkOnboardingStatus,
    required this.logger,
  }) : super(const SplashInitial()) {
    on<StartSplash>(_onStartSplash);
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
  }

  Future<void> _onStartSplash(
    StartSplash event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashLoading());
      
      // Wait for minimum splash duration (3 seconds for animation)
      await Future.delayed(const Duration(seconds: 3));
      
      // Check onboarding status
      add(const CheckOnboardingStatus());
    } catch (e) {
      logger.e('Error in splash: $e');
      emit(SplashError(e.toString()));
    }
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<SplashState> emit,
  ) async {
    try {
      final result = await checkOnboardingStatus();
      
      result.fold(
        (failure) {
          logger.e('Error checking onboarding status: $failure');
          // Navigate to onboarding on error to be safe
          emit(const NavigateToOnboarding());
        },
        (hasCompleted) {
          if (hasCompleted) {
            emit(const NavigateToAuth());
          } else {
            emit(const NavigateToOnboarding());
          }
        },
      );
    } catch (e) {
      logger.e('Error checking onboarding status: $e');
      emit(const NavigateToOnboarding());
    }
  }
}

