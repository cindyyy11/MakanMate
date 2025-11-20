import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/platform_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';

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

  /// Get seasonal trend analysis
  Future<Either<Failure, SeasonalTrendAnalysis>> getSeasonalTrends({
    DateTime? startDate,
    DateTime? endDate,
  });


  
  /// Create a system-wide announcement
  Future<Either<Failure, String>> createAnnouncement({
    required String title,
    required String message,
    String priority = 'medium',
    String targetAudience = 'all',
    DateTime? expiresAt,
  });
  
  /// Get announcements
  Future<Either<Failure, List<Map<String, dynamic>>>> getAnnouncements({
    String? targetAudience,
    bool activeOnly = true,
  });
  
  /// Stream announcements (real-time updates)
  Stream<Either<Failure, List<Map<String, dynamic>>>> streamAnnouncements({
    String? targetAudience,
    bool activeOnly = true,
  });
}
