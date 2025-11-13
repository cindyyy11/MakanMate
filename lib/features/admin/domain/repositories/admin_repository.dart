import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/platform_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/fairness_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/data_quality_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';

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

  /// Get fairness metrics for AI recommendations
  Future<Either<Failure, FairnessMetrics>> getFairnessMetrics({
    int recommendationLimit = 1000,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get seasonal trend analysis
  Future<Either<Failure, SeasonalTrendAnalysis>> getSeasonalTrends({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get data quality metrics
  Future<Either<Failure, DataQualityMetrics>> getDataQualityMetrics();

  // A/B Test Management

  /// Create a new A/B test
  Future<Either<Failure, ABTest>> createABTest(ABTest test);

  /// Get all A/B tests
  Future<Either<Failure, List<ABTest>>> getABTests({
    ABTestStatus? status,
    int? limit,
  });

  /// Get a specific A/B test by ID
  Future<Either<Failure, ABTest>> getABTest(String testId);

  /// Update an A/B test
  Future<Either<Failure, ABTest>> updateABTest(ABTest test);

  /// Start an A/B test
  Future<Either<Failure, void>> startABTest(String testId);

  /// Pause an A/B test
  Future<Either<Failure, void>> pauseABTest(String testId);

  /// Complete an A/B test
  Future<Either<Failure, void>> completeABTest(String testId);

  /// Get A/B test results
  Future<Either<Failure, ABTestResult>> getABTestResults(String testId);

  /// Assign a user to a variant
  Future<Either<Failure, ABTestAssignment>> assignUserToVariant({
    required String testId,
    required String userId,
  });

  /// Track an A/B test event (e.g., click, conversion)
  Future<Either<Failure, void>> trackABTestEvent({
    required String testId,
    required String userId,
    required String eventType,
    Map<String, dynamic>? eventData,
  });

  /// Calculate and update A/B test statistics
  Future<Either<Failure, ABTestResult>> calculateABTestStats(String testId);

  /// Rollout winner to 100%
  Future<Either<Failure, void>> rolloutWinner({
    required String testId,
    required String winnerVariantId,
  });
}
