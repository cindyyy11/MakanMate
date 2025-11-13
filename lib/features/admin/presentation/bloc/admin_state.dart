import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/platform_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/fairness_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/data_quality_metrics_entity.dart';

/// States for admin BLoC
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// Loading state
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// Refreshing state (shows cached data while refreshing)
class AdminRefreshing extends AdminState {
  final PlatformMetrics metrics;

  const AdminRefreshing(this.metrics);

  @override
  List<Object> get props => [metrics];
}

/// Loaded state
class AdminLoaded extends AdminState {
  final PlatformMetrics metrics;
  final MetricTrend? userTrend;
  final MetricTrend? vendorTrend;
  final List<ActivityLog>? activityLogs;
  final List<AdminNotification>? notifications;
  final SystemMetrics? systemMetrics;
  final FairnessMetrics? fairnessMetrics;
  final SeasonalTrendAnalysis? seasonalTrends;
  final DataQualityMetrics? dataQualityMetrics;

  const AdminLoaded(
    this.metrics, {
    this.userTrend,
    this.vendorTrend,
    this.activityLogs,
    this.notifications,
    this.systemMetrics,
    this.fairnessMetrics,
    this.seasonalTrends,
    this.dataQualityMetrics,
  });

  @override
  List<Object?> get props => [
    metrics,
    userTrend,
    vendorTrend,
    activityLogs,
    notifications,
    systemMetrics,
    fairnessMetrics,
    seasonalTrends,
    dataQualityMetrics,
  ];
}

/// Error state
class AdminError extends AdminState {
  final String message;
  final PlatformMetrics? cachedMetrics;

  const AdminError(this.message, {this.cachedMetrics});

  @override
  List<Object?> get props => [message, cachedMetrics];
}

/// Exporting state
class AdminExporting extends AdminState {
  final String format;

  const AdminExporting(this.format);

  @override
  List<Object> get props => [format];
}

/// Export success state
class AdminExportSuccess extends AdminState {
  final String filePath;
  final String format;

  const AdminExportSuccess(this.filePath, this.format);

  @override
  List<Object> get props => [filePath, format];
}
