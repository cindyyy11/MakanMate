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

/// Event to export metrics
class ExportMetrics extends AdminEvent {
  final String format; // 'csv' or 'pdf'
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportMetrics({required this.format, this.startDate, this.endDate});

  @override
  List<Object?> get props => [format, startDate, endDate];
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

