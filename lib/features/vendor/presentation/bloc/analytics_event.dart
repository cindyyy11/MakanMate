import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {
  final String vendorId;

  const LoadAnalytics(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

class LoadWeeklyReviews extends AnalyticsEvent {
  final String vendorId;

  const LoadWeeklyReviews(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

class LoadMonthlyReviews extends AnalyticsEvent {
  final String vendorId;

  const LoadMonthlyReviews(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

class LoadFavourites extends AnalyticsEvent {
  final String vendorId;

  const LoadFavourites(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

class LoadPromotionStats extends AnalyticsEvent {
  final String vendorId;

  const LoadPromotionStats(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

