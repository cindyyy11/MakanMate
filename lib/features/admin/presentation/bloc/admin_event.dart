import 'package:equatable/equatable.dart';

/// Events for admin BLoC
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load platform metrics
class LoadPlatformMetrics extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadPlatformMetrics({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to refresh platform metrics
class RefreshPlatformMetrics extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const RefreshPlatformMetrics({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load metric trend
class LoadMetricTrend extends AdminEvent {
  final String metricName;
  final int days;

  const LoadMetricTrend({required this.metricName, required this.days});

  @override
  List<Object> get props => [metricName, days];
}

/// Event to load activity logs
class LoadActivityLogs extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;
  final int? limit;

  const LoadActivityLogs({
    this.startDate,
    this.endDate,
    this.userId,
    this.limit,
  });

  @override
  List<Object?> get props => [startDate, endDate, userId, limit];
}

/// Event to load notifications
class LoadNotifications extends AdminEvent {
  final bool? unreadOnly;
  final int? limit;

  const LoadNotifications({this.unreadOnly, this.limit});

  @override
  List<Object?> get props => [unreadOnly, limit];
}

/// Event to mark notification as read
class MarkNotificationAsRead extends AdminEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Event to export metrics
class ExportMetrics extends AdminEvent {
  final String format; // 'csv' or 'pdf'
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportMetrics({required this.format, this.startDate, this.endDate});

  @override
  List<Object?> get props => [format, startDate, endDate];
}


/// Event to load fairness metrics
class LoadFairnessMetrics extends AdminEvent {
  final int recommendationLimit;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadFairnessMetrics({
    this.recommendationLimit = 1000,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [recommendationLimit, startDate, endDate];
}

/// Event to refresh fairness metrics
class RefreshFairnessMetrics extends AdminEvent {
  final int recommendationLimit;
  final DateTime? startDate;
  final DateTime? endDate;

  const RefreshFairnessMetrics({
    this.recommendationLimit = 1000,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [recommendationLimit, startDate, endDate];
}

/// Event to load seasonal trend analysis
class LoadSeasonalTrends extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSeasonalTrends({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to refresh seasonal trend analysis
class RefreshSeasonalTrends extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const RefreshSeasonalTrends({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load data quality metrics
class LoadDataQualityMetrics extends AdminEvent {
  const LoadDataQualityMetrics();
}

/// Event to refresh data quality metrics
class RefreshDataQualityMetrics extends AdminEvent {
  const RefreshDataQualityMetrics();
}
