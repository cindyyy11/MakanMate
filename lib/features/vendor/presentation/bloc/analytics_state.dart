import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics_entity.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final ReviewAnalyticsEntity? weeklyReviews;
  final ReviewAnalyticsEntity? monthlyReviews;
  final FavouriteStatsEntity? favourites;
  final PromotionAnalyticsEntity? promotions;
  final bool isWeeklyView;

  const AnalyticsLoaded({
    this.weeklyReviews,
    this.monthlyReviews,
    this.favourites,
    this.promotions,
    this.isWeeklyView = true,
  });

  AnalyticsLoaded copyWith({
    ReviewAnalyticsEntity? weeklyReviews,
    ReviewAnalyticsEntity? monthlyReviews,
    FavouriteStatsEntity? favourites,
    PromotionAnalyticsEntity? promotions,
    bool? isWeeklyView,
  }) {
    return AnalyticsLoaded(
      weeklyReviews: weeklyReviews ?? this.weeklyReviews,
      monthlyReviews: monthlyReviews ?? this.monthlyReviews,
      favourites: favourites ?? this.favourites,
      promotions: promotions ?? this.promotions,
      isWeeklyView: isWeeklyView ?? this.isWeeklyView,
    );
  }

  @override
  List<Object?> get props => [
        weeklyReviews,
        monthlyReviews,
        favourites,
        promotions,
        isWeeklyView,
      ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

