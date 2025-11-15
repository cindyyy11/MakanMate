import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository analyticsRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AnalyticsBloc({required this.analyticsRepository})
      : super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<LoadWeeklyReviews>(_onLoadWeeklyReviews);
    on<LoadMonthlyReviews>(_onLoadMonthlyReviews);
    on<LoadFavourites>(_onLoadFavourites);
    on<LoadPromotionStats>(_onLoadPromotionStats);
  }

  String get vendorId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final weeklyReviews = await analyticsRepository.getWeeklyReviewData(event.vendorId);
      final favourites = await analyticsRepository.getFavouriteData(event.vendorId);
      final promotions = await analyticsRepository.getPromotionAnalytics(event.vendorId);

      emit(AnalyticsLoaded(
        weeklyReviews: weeklyReviews,
        favourites: favourites,
        promotions: promotions,
        isWeeklyView: true,
      ));
    } catch (e) {
      emit(AnalyticsError('Failed to load analytics: $e'));
    }
  }

  Future<void> _onLoadWeeklyReviews(
    LoadWeeklyReviews event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (state is AnalyticsLoaded) {
      emit((state as AnalyticsLoaded).copyWith(isWeeklyView: true));
    }
    
    try {
      final weeklyReviews = await analyticsRepository.getWeeklyReviewData(event.vendorId);
      
      if (state is AnalyticsLoaded) {
        emit((state as AnalyticsLoaded).copyWith(
          weeklyReviews: weeklyReviews,
          isWeeklyView: true,
        ));
      } else {
        emit(AnalyticsLoaded(
          weeklyReviews: weeklyReviews,
          isWeeklyView: true,
        ));
      }
    } catch (e) {
      emit(AnalyticsError('Failed to load weekly reviews: $e'));
    }
  }

  Future<void> _onLoadMonthlyReviews(
    LoadMonthlyReviews event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (state is AnalyticsLoaded) {
      emit((state as AnalyticsLoaded).copyWith(isWeeklyView: false));
    }
    
    try {
      final monthlyReviews = await analyticsRepository.getMonthlyReviewData(event.vendorId);
      
      if (state is AnalyticsLoaded) {
        emit((state as AnalyticsLoaded).copyWith(
          monthlyReviews: monthlyReviews,
          isWeeklyView: false,
        ));
      } else {
        emit(AnalyticsLoaded(
          monthlyReviews: monthlyReviews,
          isWeeklyView: false,
        ));
      }
    } catch (e) {
      emit(AnalyticsError('Failed to load monthly reviews: $e'));
    }
  }

  Future<void> _onLoadFavourites(
    LoadFavourites event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final favourites = await analyticsRepository.getFavouriteData(event.vendorId);
      
      if (state is AnalyticsLoaded) {
        emit((state as AnalyticsLoaded).copyWith(favourites: favourites));
      } else {
        emit(AnalyticsLoaded(favourites: favourites));
      }
    } catch (e) {
      emit(AnalyticsError('Failed to load favourites: $e'));
    }
  }

  Future<void> _onLoadPromotionStats(
    LoadPromotionStats event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final promotions = await analyticsRepository.getPromotionAnalytics(event.vendorId);
      
      if (state is AnalyticsLoaded) {
        emit((state as AnalyticsLoaded).copyWith(promotions: promotions));
      } else {
        emit(AnalyticsLoaded(promotions: promotions));
      }
    } catch (e) {
      emit(AnalyticsError('Failed to load promotion stats: $e'));
    }
  }
}

