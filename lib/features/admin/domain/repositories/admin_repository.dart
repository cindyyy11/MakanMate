import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/platform_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';

/// Repository interface for admin operations
abstract class AdminRepository {
  /// Get platform metrics (aggregate statistics)
  Future<Either<Failure, PlatformMetrics>> getPlatformMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get trend data for a specific metric
  Future<Either<Failure, MetricTrend>> getMetricTrend({
    required String metricName,
    required int days,
  });

  /// Get user activity logs
  Future<Either<Failure, List<ActivityLog>>> getActivityLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
  });

  /// Get admin notifications
  Future<Either<Failure, List<AdminNotification>>> getNotifications({
    bool? unreadOnly,
    int? limit,
  });

  /// Mark notification as read
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);

  /// Export metrics to CSV
  Future<Either<Failure, String>> exportMetricsToCSV({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Export metrics to PDF
  Future<Either<Failure, String>> exportMetricsToPDF({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Stream real-time system metrics
  Stream<Either<Failure, SystemMetrics>> streamSystemMetrics();
}
