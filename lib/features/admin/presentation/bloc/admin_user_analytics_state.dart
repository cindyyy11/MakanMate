import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/analytics/domain/entities/user_analytics_entity.dart';

abstract class AdminUserAnalyticsState extends Equatable {
  const AdminUserAnalyticsState();
  @override
  List<Object?> get props => [];
}

class AdminUserAnalyticsInitial extends AdminUserAnalyticsState {}

class AdminUserAnalyticsLoading extends AdminUserAnalyticsState {}

class AdminUserAnalyticsLoaded extends AdminUserAnalyticsState {
  final UserAnalytics analytics;
  const AdminUserAnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class AdminUserAnalyticsError extends AdminUserAnalyticsState {
  final String message;
  const AdminUserAnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}


