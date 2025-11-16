import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/models/activity_log_model.dart';
import 'package:makan_mate/features/admin/data/models/admin_notification_model.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/data/models/metric_trend_model.dart';
import 'package:makan_mate/features/admin/data/models/platform_metrics_model.dart';
import 'package:makan_mate/features/admin/data/models/system_metrics_model.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';
import 'package:makan_mate/features/admin/data/models/fairness_metrics_model.dart';
import 'package:makan_mate/features/admin/data/models/seasonal_trend_model.dart';
import 'package:makan_mate/features/admin/data/models/data_quality_metrics_model.dart';
import 'package:makan_mate/features/admin/data/models/ab_test_model.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/services/fairness_metrics_calculator_interface.dart';
import 'package:makan_mate/features/admin/domain/services/seasonal_trend_calculator_interface.dart';
import 'package:makan_mate/features/admin/data/datasources/fairness_metrics_calculator_impl.dart';
import 'package:makan_mate/features/admin/data/datasources/seasonal_trend_calculator_impl.dart';

/// Remote data source for admin operations
///
/// Fetches aggregate metrics from Firestore
abstract class AdminRemoteDataSource {
  Future<PlatformMetricsModel> getPlatformMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<MetricTrendModel> getMetricTrend({
    required String metricName,
    required int days,
  });

  Future<List<ActivityLogModel>> getActivityLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
  });

  Future<List<AdminNotificationModel>> getNotifications({
    bool? unreadOnly,
    int? limit,
  });

  Future<void> markNotificationAsRead(String notificationId);

  Future<String> exportMetricsToCSV({DateTime? startDate, DateTime? endDate});

  Future<String> exportMetricsToPDF({DateTime? startDate, DateTime? endDate});

  /// Stream real-time system metrics
  Stream<SystemMetricsModel> streamSystemMetrics();

  /// Get fairness metrics for AI recommendations
  Future<FairnessMetricsModel> getFairnessMetrics({
    int recommendationLimit = 1000,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Trigger fairness metrics calculation (for cloud function)
  Future<void> calculateAndSaveFairnessMetrics();

  /// Get seasonal trend analysis
  Future<SeasonalTrendAnalysisModel> getSeasonalTrends({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get data quality metrics
  Future<DataQualityMetricsModel> getDataQualityMetrics();

  // A/B Test Management

  /// Create a new A/B test
  Future<ABTestModel> createABTest(ABTestModel test);

  /// Get all A/B tests
  Future<List<ABTestModel>> getABTests({String? status, int? limit});

  /// Get a specific A/B test by ID
  Future<ABTestModel> getABTest(String testId);

  /// Update an A/B test
  Future<ABTestModel> updateABTest(ABTestModel test);

  /// Start an A/B test
  Future<void> startABTest(String testId);

  /// Pause an A/B test
  Future<void> pauseABTest(String testId);

  /// Complete an A/B test
  Future<void> completeABTest(String testId);

  /// Get A/B test results
  Future<ABTestResultModel> getABTestResults(String testId);

  /// Assign a user to a variant
  Future<ABTestAssignmentModel> assignUserToVariant({
    required String testId,
    required String userId,
  });

  /// Track an A/B test event
  Future<void> trackABTestEvent({
    required String testId,
    required String userId,
    required String eventType,
    Map<String, dynamic>? eventData,
  });

  /// Calculate and update A/B test statistics
  Future<ABTestResultModel> calculateABTestStats(String testId);

  /// Rollout winner to 100%
  Future<void> rolloutWinner({
    required String testId,
    required String winnerVariantId,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final Logger logger;
  late final FairnessMetricsCalculatorInterface _fairnessCalculator;
  late final SeasonalTrendCalculatorInterface _seasonalTrendCalculator;

  AdminRemoteDataSourceImpl({required this.firestore, required this.logger}) {
    _fairnessCalculator = FairnessMetricsCalculatorImpl(
      firestore: firestore,
      logger: logger,
    );
    _seasonalTrendCalculator = SeasonalTrendCalculatorImpl(
      firestore: firestore,
      logger: logger,
    );
  }

  @override
  Future<PlatformMetricsModel> getPlatformMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      logger.i('Fetching platform metrics from Firestore');

      // Get all counts in parallel for better performance
      final results = await Future.wait([
        _getTotalUsers(),
        _getTotalVendors(),
        _getActiveVendors(),
        _getPendingApplications(),
        _getFlaggedReviews(),
        _getAverageRating(),
        _getTodaysActiveUsers(),
        _getTotalRestaurants(),
        _getTotalFoodItems(),
      ]);

      return PlatformMetricsModel(
        totalUsers: results[0] as int,
        totalVendors: results[1] as int,
        activeVendors: results[2] as int,
        pendingApplications: results[3] as int,
        flaggedReviews: results[4] as int,
        averagePlatformRating: results[5] as double,
        todaysActiveUsers: results[6] as int,
        totalRestaurants: results[7] as int,
        totalFoodItems: results[8] as int,
        lastUpdated: DateTime.now(),
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching platform metrics: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Count total users
  Future<int> _getTotalUsers() async {
    try {
      final snapshot = await firestore.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting users: $e');
      return 0;
    }
  }

  /// Count total vendors
  Future<int> _getTotalVendors() async {
    try {
      final snapshot = await firestore.collection('vendors').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting vendors: $e');
      return 0;
    }
  }

  /// Count active vendors
  Future<int> _getActiveVendors() async {
    try {
      // Try approvalStatus field first (your structure), then status field
      try {
        final snapshot = await firestore
            .collection('vendors')
            .where('approvalStatus', isEqualTo: 'approved')
            .count()
            .get();
        return snapshot.count ?? 0;
      } catch (e) {
        // Fallback to status field
        try {
          final snapshot = await firestore
              .collection('vendors')
              .where('status', isEqualTo: 'active')
              .count()
              .get();
          return snapshot.count ?? 0;
        } catch (e2) {
          // If neither exists, count all vendors as active
          logger.w(
            'approvalStatus/status field not found, counting all vendors: $e2',
          );
          final snapshot = await firestore.collection('vendors').count().get();
          return snapshot.count ?? 0;
        }
      }
    } catch (e) {
      logger.w('Error counting active vendors: $e');
      return 0;
    }
  }

  /// Count pending vendor applications
  Future<int> _getPendingApplications() async {
    try {
      // Primary: vendors where status == 'pending'
      final vendorsPending = await firestore
          .collection('vendors')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      if ((vendorsPending.count ?? 0) > 0) return vendorsPending.count ?? 0;

      // Fallbacks on alternative field names
      try {
        final approval = await firestore
            .collection('vendors')
            .where('approvalStatus', isEqualTo: 'pending')
            .count()
            .get();
        if ((approval.count ?? 0) > 0) return approval.count ?? 0;
      } catch (_) {}

      try {
        final application = await firestore
            .collection('vendors')
            .where('applicationStatus', isEqualTo: 'pending')
            .count()
            .get();
        if ((application.count ?? 0) > 0) return application.count ?? 0;
      } catch (_) {}

      // Legacy applications collection (optional)
      try {
        final legacy = await firestore
            .collection('vendor_applications')
            .where('status', isEqualTo: 'pending')
            .count()
            .get();
        return legacy.count ?? 0;
      } catch (e) {
        logger.w('No pending vendor applications found: $e');
        return 0;
      }
    } catch (e) {
      logger.w('Error counting pending applications: $e');
      return 0;
    }
  }

  /// Count flagged reviews
  Future<int> _getFlaggedReviews() async {
    try {
      // Primary: read from reviews collection per AdminReviewModel schema
      // Prefer flagged == true and removed == false (if present)
      try {
        final snapshot = await firestore
            .collection('reviews')
            .where('flagged', isEqualTo: true)
            .where('removed', isEqualTo: false)
            .count()
            .get();
        return snapshot.count ?? 0;
      } catch (e) {
        // Fallback: some documents may not have 'removed' field; count only by flagged
        final snapshot = await firestore
            .collection('reviews')
            .where('flagged', isEqualTo: true)
            .count()
            .get();
        return snapshot.count ?? 0;
      }
    } catch (e) {
      // Fallback: legacy flagged_content collection (optional)
      try {
        final legacy = await firestore
            .collection('flagged_content')
            .where('status', isEqualTo: 'pending')
            .count()
            .get();
        return legacy.count ?? 0;
      } catch (e2) {
        logger.w('Error counting flagged reviews: $e2');
      }
      return 0;
    }
  }

  /// Calculate average platform rating
  Future<double> _getAverageRating() async {
    try {
      // Get all reviews and calculate average
      final reviewsSnapshot = await firestore.collection('reviews').get();

      if (reviewsSnapshot.docs.isEmpty) {
        // Try to get ratings from favorites/item if reviews don't exist
        logger.w('reviews collection not found, checking favorites');
        try {
          final favoritesSnapshot = await firestore
              .collection('favorites')
              .doc('item')
              .collection('item')
              .get();

          if (favoritesSnapshot.docs.isEmpty) {
            return 0.0;
          }

          double totalRating = 0.0;
          int count = 0;

          for (var doc in favoritesSnapshot.docs) {
            final rating = doc.data()['rating'];
            if (rating != null) {
              totalRating += (rating as num).toDouble();
              count++;
            }
          }

          return count > 0 ? totalRating / count : 0.0;
        } catch (e2) {
          logger.w('No reviews or ratings found: $e2');
          return 0.0;
        }
      }

      double totalRating = 0.0;
      int count = 0;

      for (var doc in reviewsSnapshot.docs) {
        final rating = doc.data()['rating'];
        if (rating != null) {
          totalRating += (rating as num).toDouble();
          count++;
        }
      }

      return count > 0 ? totalRating / count : 0.0;
    } catch (e) {
      logger.w('Error calculating average rating: $e');
      return 0.0;
    }
  }

  /// Count today's active users
  Future<int> _getTodaysActiveUsers() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await firestore
          .collection('users')
          .where(
            'lastActive',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting today\'s active users: $e');
      return 0;
    }
  }

  /// Count total restaurants based on vendors.outlets
  ///
  /// We sum the number of outlets for each vendor. Supports multiple schema shapes:
  /// - outlets: number                       -> use value directly
  /// - outlets: List<dynamic> (array)        -> use length
  /// - numOutlets / outletCount (number)     -> fallback numeric fields
  Future<int> _getTotalRestaurants() async {
    try {
      int totalOutlets = 0;
      final vendorsSnapshot = await firestore.collection('vendors').get();
      for (final doc in vendorsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('outlets')) {
          final outlets = data['outlets'];
          if (outlets is int) {
            totalOutlets += outlets;
          } else if (outlets is List) {
            totalOutlets += outlets.length;
          } else if (outlets is Map) {
            // Map of outletId -> outletData
            totalOutlets += outlets.length;
          }
        } else if (data['numOutlets'] is int) {
          totalOutlets += (data['numOutlets'] as int);
        } else if (data['outletCount'] is int) {
          totalOutlets += (data['outletCount'] as int);
        } else {
          // If no explicit outlets field, treat as single outlet vendor
          totalOutlets += 1;
        }
      }
      return totalOutlets;
    } catch (e) {
      logger.w('Error counting restaurants (vendors.outlets): $e');
      return 0;
    }
  }

  /// Count total food items using vendors/{vendorId}/menu subcollections
  Future<int> _getTotalFoodItems() async {
    try {
      int totalMenuItems = 0;
      final vendorsSnapshot = await firestore.collection('vendors').get();
      for (var vendorDoc in vendorsSnapshot.docs) {
        try {
          final menuCount = await vendorDoc.reference.collection('menus').count().get();
          totalMenuItems += menuCount.count ?? 0;
        } catch (e) {
          // If the vendor has no menu subcollection, skip
          logger.v('No menu subcollection for vendor ${vendorDoc.id}: $e');
        }
      }
      return totalMenuItems;
    } catch (e) {
      logger.w('Error counting food items from vendor menus: $e');
      return 0;
    }
  }

  @override
  Future<MetricTrendModel> getMetricTrend({
    required String metricName,
    required int days,
  }) async {
    try {
      logger.i('Fetching trend for $metricName over $days days');

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      // Get historical data points
      List<MetricDataPoint> dataPoints = [];

      // Query based on metric type
      QuerySnapshot snapshot;
      switch (metricName) {
        case 'totalUsers':
          snapshot = await firestore
              .collection('users')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .orderBy('createdAt')
              .get();
          break;
        case 'totalVendors':
          snapshot = await firestore
              .collection('vendors')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .orderBy('createdAt')
              .get();
          break;
        default:
          snapshot = await firestore.collection('users').limit(0).get();
      }

      // Group by day and count
      Map<DateTime, int> dailyCounts = {};
      for (var doc in snapshot.docs) {
        final createdAt =
            (doc.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final date = DateTime(
            createdAt.toDate().year,
            createdAt.toDate().month,
            createdAt.toDate().day,
          );
          dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
        }
      }

      // Convert to data points
      int cumulative = 0;
      for (var i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final count = dailyCounts[date] ?? 0;
        cumulative += count;
        dataPoints.add(
          MetricDataPoint(
            date: date,
            value: cumulative.toDouble(),
            label: '${date.day}/${date.month}',
          ),
        );
      }

      final currentValue = dataPoints.isNotEmpty ? dataPoints.last.value : 0.0;
      final previousValue = dataPoints.length > 1
          ? dataPoints[dataPoints.length - 2].value
          : 0.0;
      final percentageChange = previousValue > 0
          ? ((currentValue - previousValue) / previousValue) * 100
          : 0.0;

      return MetricTrendModel(
        metricName: metricName,
        dataPoints: dataPoints,
        currentValue: currentValue,
        previousValue: previousValue,
        percentageChange: percentageChange,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching metric trend: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<ActivityLogModel>> getActivityLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
  }) async {
    try {
      logger.i('Fetching activity logs');

      // Try audit_logs first, fallback to activity_logs
      Query query;
      bool useAuditLogs = true;

      try {
        // Try to query audit_logs to see if it exists
        final testQuery = firestore.collection('audit_logs').limit(1);
        await testQuery.get();
        query = firestore
            .collection('audit_logs')
            .orderBy('timestamp', descending: true);
      } catch (e) {
        // Fallback to activity_logs if audit_logs doesn't exist
        logger.w('audit_logs not found, using activity_logs: $e');
        useAuditLogs = false;
        query = firestore
            .collection('activity_logs')
            .orderBy('timestamp', descending: true);
      }

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (userId != null) {
        // Support both adminId (audit_logs) and userId (activity_logs) fields
        if (useAuditLogs) {
          query = query.where('adminId', isEqualTo: userId);
        } else {
          // Using activity_logs
          query = query.where('userId', isEqualTo: userId);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ActivityLogModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      logger.e('Error fetching activity logs: $e', stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<AdminNotificationModel>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    try {
      logger.i('Fetching admin notifications');

      Query query = firestore
          .collection('admin_notifications')
          .orderBy('timestamp', descending: true);

      if (unreadOnly == true) {
        query = query.where('isRead', isEqualTo: false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AdminNotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Collection doesn't exist yet - return empty list
      logger.w('admin_notifications collection not found: $e');
      return [];
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await firestore
          .collection('admin_notifications')
          .doc(notificationId)
          .update({'isRead': true});
      logger.i('Marked notification $notificationId as read');
    } catch (e, stackTrace) {
      logger.e(
        'Error marking notification as read: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<String> exportMetricsToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      logger.i('Exporting metrics to CSV');

      final metrics = await getPlatformMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final csv = StringBuffer();
      csv.writeln('Metric,Value');
      csv.writeln('Total Users,${metrics.totalUsers}');
      csv.writeln('Total Vendors,${metrics.totalVendors}');
      csv.writeln('Active Vendors,${metrics.activeVendors}');
      csv.writeln('Pending Applications,${metrics.pendingApplications}');
      csv.writeln('Flagged Reviews,${metrics.flaggedReviews}');
      csv.writeln(
        'Average Rating,${metrics.averagePlatformRating.toStringAsFixed(2)}',
      );
      csv.writeln('Today\'s Active Users,${metrics.todaysActiveUsers}');
      csv.writeln('Total Restaurants,${metrics.totalRestaurants}');
      csv.writeln('Total Food Items,${metrics.totalFoodItems}');
      csv.writeln('Last Updated,${metrics.lastUpdated.toIso8601String()}');

      return csv.toString();
    } catch (e, stackTrace) {
      logger.e('Error exporting to CSV: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> exportMetricsToPDF({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      logger.i('Exporting metrics to PDF');

      // PDF generation is handled in repository
      // This method is kept for interface consistency
      await getPlatformMetrics(startDate: startDate, endDate: endDate);
      return 'pdf_export_${DateTime.now().millisecondsSinceEpoch}.pdf';
    } catch (e, stackTrace) {
      logger.e('Error exporting to PDF: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Stream<SystemMetricsModel> streamSystemMetrics() {
    try {
      logger.i('Streaming real-time system metrics');

      return firestore
          .collection('system_metrics')
          .doc('current')
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              // Return default metrics if document doesn't exist
              return SystemMetricsModel(
                activeUsers: 0,
                activeSessions: 0,
                apiCallsPerMinute: 0,
                avgResponseTime: 0.0,
                errorCount: 0,
                errorRate: 0.0,
                healthStatus: SystemHealthStatus.healthy,
                lastUpdated: DateTime.now(),
              );
            }
            return SystemMetricsModel.fromFirestore(doc);
          })
          .handleError((error) {
            logger.e('Error streaming system metrics: $error');
            // Return default metrics on error
            return SystemMetricsModel(
              activeUsers: 0,
              activeSessions: 0,
              apiCallsPerMinute: 0,
              avgResponseTime: 0.0,
              errorCount: 0,
              errorRate: 0.0,
              healthStatus: SystemHealthStatus.warning,
              lastUpdated: DateTime.now(),
            );
          });
    } catch (e, stackTrace) {
      logger.e(
        'Error setting up system metrics stream: $e',
        stackTrace: stackTrace,
      );
      // Return a stream with default metrics
      return Stream.value(
        SystemMetricsModel(
          activeUsers: 0,
          activeSessions: 0,
          apiCallsPerMinute: 0,
          avgResponseTime: 0.0,
          errorCount: 0,
          errorRate: 0.0,
          healthStatus: SystemHealthStatus.warning,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<FairnessMetricsModel> getFairnessMetrics({
    int recommendationLimit = 1000,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      logger.i('Fetching fairness metrics');

      // Try to get latest cached metrics first
      final latestDoc = await firestore
          .collection('fairness_metrics')
          .doc('latest')
          .get();

      if (latestDoc.exists) {
        final cached = FairnessMetricsModel.fromFirestore(latestDoc);
        final cacheAge = DateTime.now().difference(cached.calculatedAt);

        // Use cached if less than 1 hour old
        if (cacheAge.inHours < 1) {
          logger.i(
            'Using cached fairness metrics (age: ${cacheAge.inMinutes} minutes)',
          );
          return cached;
        }
      }

      // Calculate fresh metrics
      logger.i('Calculating fresh fairness metrics');
      final metrics = await _fairnessCalculator.calculateFairnessMetrics(
        recommendationLimit: recommendationLimit,
        startDate: startDate,
        endDate: endDate,
      );

      // Convert to model
      final model = FairnessMetricsModel(
        cuisineDistribution: metrics.cuisineDistribution,
        regionDistribution: metrics.regionDistribution,
        smallVendorVisibility: metrics.smallVendorVisibility,
        largeVendorVisibility: metrics.largeVendorVisibility,
        diversityScore: metrics.diversityScore,
        ndcgScore: metrics.ndcgScore,
        biasAlerts: metrics.biasAlerts,
        totalRecommendations: metrics.totalRecommendations,
        analysisStartDate: metrics.analysisStartDate,
        analysisEndDate: metrics.analysisEndDate,
        calculatedAt: metrics.calculatedAt,
      );

      // Save to Firestore
      await firestore
          .collection('fairness_metrics')
          .doc('latest')
          .set(model.toFirestore());

      logger.i('Successfully fetched fairness metrics');
      return model;
    } catch (e, stackTrace) {
      logger.e('Error fetching fairness metrics: $e', stackTrace: stackTrace);
      // Return default metrics instead of throwing
      return _getDefaultFairnessMetrics();
    }
  }

  /// Get default fairness metrics when data is not available
  FairnessMetricsModel _getDefaultFairnessMetrics() {
    return FairnessMetricsModel(
      cuisineDistribution: {},
      regionDistribution: {},
      smallVendorVisibility: 0.0,
      largeVendorVisibility: 0.0,
      diversityScore: 0.0,
      ndcgScore: 0.0,
      biasAlerts: const [],
      totalRecommendations: 0,
      analysisStartDate: DateTime.now().subtract(const Duration(days: 30)),
      analysisEndDate: DateTime.now(),
      calculatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> calculateAndSaveFairnessMetrics() async {
    try {
      logger.i('Calculating and saving fairness metrics (cloud function)');

      final metrics = await _fairnessCalculator.calculateFairnessMetrics(
        recommendationLimit: 1000,
      );

      final model = FairnessMetricsModel(
        cuisineDistribution: metrics.cuisineDistribution,
        regionDistribution: metrics.regionDistribution,
        smallVendorVisibility: metrics.smallVendorVisibility,
        largeVendorVisibility: metrics.largeVendorVisibility,
        diversityScore: metrics.diversityScore,
        ndcgScore: metrics.ndcgScore,
        biasAlerts: metrics.biasAlerts,
        totalRecommendations: metrics.totalRecommendations,
        analysisStartDate: metrics.analysisStartDate,
        analysisEndDate: metrics.analysisEndDate,
        calculatedAt: metrics.calculatedAt,
      );

      // Save latest
      await firestore
          .collection('fairness_metrics')
          .doc('latest')
          .set(model.toFirestore());

      // Also save historical record
      await firestore
          .collection('fairness_metrics')
          .doc(DateTime.now().toIso8601String())
          .set(model.toFirestore());

      logger.i('Successfully calculated and saved fairness metrics');
    } catch (e, stackTrace) {
      logger.e(
        'Error calculating fairness metrics: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<SeasonalTrendAnalysisModel> getSeasonalTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      logger.i('Fetching seasonal trend analysis');

      // Try to get latest cached trends first
      final latestDoc = await firestore
          .collection('seasonal_trends')
          .doc('latest')
          .get();

      if (latestDoc.exists) {
        final cached = SeasonalTrendAnalysisModel.fromFirestore(latestDoc);
        final cacheAge = DateTime.now().difference(cached.calculatedAt);

        // Use cached if less than 6 hours old
        if (cacheAge.inHours < 6) {
          logger.i(
            'Using cached seasonal trends (age: ${cacheAge.inMinutes} minutes)',
          );
          return cached;
        }
      }

      // Calculate fresh trends
      logger.i('Calculating fresh seasonal trends');

      // Check if searches collection exists
      try {
        final searchCheck = await firestore
            .collection('searches')
            .limit(1)
            .get();
        if (searchCheck.docs.isEmpty) {
          logger.w('No searches data available, returning default trends');
          return _getDefaultSeasonalTrends();
        }
      } catch (e) {
        logger.w('searches collection not found: $e');
        return _getDefaultSeasonalTrends();
      }

      final analysis = await _seasonalTrendCalculator.calculateSeasonalTrends(
        startDate: startDate,
        endDate: endDate,
      );

      // Convert to model
      final model = SeasonalTrendAnalysisModel.fromEntity(analysis);

      // Save to Firestore
      await firestore
          .collection('seasonal_trends')
          .doc('latest')
          .set(model.toFirestore());

      logger.i('Successfully fetched seasonal trends');
      return model;
    } catch (e, stackTrace) {
      logger.e('Error fetching seasonal trends: $e', stackTrace: stackTrace);
      // Return default trends instead of throwing
      return _getDefaultSeasonalTrends();
    }
  }

  /// Get default seasonal trends when data is not available
  SeasonalTrendAnalysisModel _getDefaultSeasonalTrends() {
    final now = DateTime.now();
    final month = now.month;
    Season currentSeason = Season.regular;

    if (month == 3 || month == 4) {
      currentSeason = Season.ramadan;
    } else if (month == 1 || month == 2) {
      currentSeason = Season.cny;
    } else if (month == 6 || month == 7) {
      currentSeason = Season.durian;
    }

    return SeasonalTrendAnalysisModel(
      currentSeason: currentSeason,
      trendingDishes: const [],
      trendingCuisines: const [],
      upcomingEvents: const [],
      recommendations: const [],
      analysisStartDate: now.subtract(const Duration(days: 30)),
      analysisEndDate: now,
      calculatedAt: now,
      totalSearches: 0,
    );
  }

  @override
  Future<DataQualityMetricsModel> getDataQualityMetrics() async {
    try {
      logger.i('Fetching data quality metrics from Firestore');

      // Get latest data quality metrics
      final doc = await firestore
          .collection('data_quality')
          .doc('latest')
          .get();

      if (!doc.exists) {
        logger.w('No data quality metrics found, returning empty metrics');
        // Return default empty metrics
        return DataQualityMetricsModel(
          overallQualityScore: 0.0,
          menuCompleteness: 0.0,
          halalCoverage: 0.0,
          staleness: 0.0,
          locationAccuracy: 0.0,
          totalVendors: 0,
          vendorsWithCompleteMenus: 0,
          vendorsWithValidHalalCerts: 0,
          vendorsStaleData: 0,
          duplicateListings: 0,
          totalFoodItems: 0,
          criticalIssues: const [],
          staleVendorIds: const [],
          expiredCertVendorIds: const [],
          incompleteMenuVendorIds: const [],
          duplicateVendorIds: const [],
          calculatedAt: DateTime.now(),
        );
      }

      final model = DataQualityMetricsModel.fromFirestore(doc);
      logger.i('Successfully fetched data quality metrics');
      return model;
    } catch (e, stackTrace) {
      logger.e(
        'Error fetching data quality metrics: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // A/B Test Management Implementation

  @override
  Future<ABTestModel> createABTest(ABTestModel test) async {
    try {
      logger.i('Creating A/B test: ${test.name}');

      final docRef = firestore.collection('ab_tests').doc();
      final testWithId = ABTestModel(
        id: docRef.id,
        name: test.name,
        description: test.description,
        control: test.control as ABTestVariantModel,
        treatment: test.treatment as ABTestVariantModel,
        metric: test.metric,
        controlSplit: test.controlSplit,
        treatmentSplit: test.treatmentSplit,
        status: test.status,
        startDate: test.startDate,
        endDate: test.endDate,
        createdAt: test.createdAt,
        updatedAt: DateTime.now(),
        createdBy: test.createdBy,
        metadata: test.metadata,
      );

      await docRef.set(testWithId.toFirestore());
      logger.i('Successfully created A/B test: ${docRef.id}');
      return testWithId;
    } catch (e, stackTrace) {
      logger.e('Error creating A/B test: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<ABTestModel>> getABTests({String? status, int? limit}) async {
    try {
      logger.i('Fetching A/B tests');

      Query query = firestore
          .collection('ab_tests')
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ABTestModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      logger.e('Error fetching A/B tests: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ABTestModel> getABTest(String testId) async {
    try {
      logger.i('Fetching A/B test: $testId');

      final doc = await firestore.collection('ab_tests').doc(testId).get();

      if (!doc.exists) {
        throw Exception('A/B test not found: $testId');
      }

      return ABTestModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      logger.e('Error fetching A/B test: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ABTestModel> updateABTest(ABTestModel test) async {
    try {
      logger.i('Updating A/B test: ${test.id}');

      final updatedTest = (test).copyWith(updatedAt: DateTime.now());
      await firestore
          .collection('ab_tests')
          .doc(test.id)
          .update(updatedTest.toFirestore());

      logger.i('Successfully updated A/B test: ${test.id}');
      return updatedTest;
    } catch (e, stackTrace) {
      logger.e('Error updating A/B test: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> startABTest(String testId) async {
    try {
      logger.i('Starting A/B test: $testId');

      await firestore.collection('ab_tests').doc(testId).update({
        'status': ABTestStatus.running.name,
        'startDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      logger.i('Successfully started A/B test: $testId');
    } catch (e, stackTrace) {
      logger.e('Error starting A/B test: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> pauseABTest(String testId) async {
    try {
      logger.i('Pausing A/B test: $testId');

      await firestore.collection('ab_tests').doc(testId).update({
        'status': ABTestStatus.paused.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      logger.i('Successfully paused A/B test: $testId');
    } catch (e, stackTrace) {
      logger.e('Error pausing A/B test: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> completeABTest(String testId) async {
    try {
      logger.i('Completing A/B test: $testId');

      await firestore.collection('ab_tests').doc(testId).update({
        'status': ABTestStatus.completed.name,
        'endDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      logger.i('Successfully completed A/B test: $testId');
    } catch (e, stackTrace) {
      logger.e('Error completing A/B test: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ABTestResultModel> getABTestResults(String testId) async {
    try {
      logger.i('Fetching A/B test results: $testId');

      final doc = await firestore
          .collection('ab_test_results')
          .doc(testId)
          .get();

      if (!doc.exists) {
        // Calculate results if they don't exist
        return await calculateABTestStats(testId);
      }

      return ABTestResultModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      logger.e('Error fetching A/B test results: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ABTestAssignmentModel> assignUserToVariant({
    required String testId,
    required String userId,
  }) async {
    try {
      logger.i('Assigning user $userId to variant in test $testId');

      // Check if user is already assigned
      final existingAssignment = await firestore
          .collection('ab_test_assignments')
          .where('testId', isEqualTo: testId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingAssignment.docs.isNotEmpty) {
        return ABTestAssignmentModel.fromFirestore(
          existingAssignment.docs.first,
        );
      }

      // Get test to determine split
      final test = await getABTest(testId);

      // Use consistent hashing to assign user to variant
      // This ensures the same user always gets the same variant
      final hash = (userId + testId).hashCode;
      final variantId = hash % 100 < test.controlSplit
          ? test.control.id
          : test.treatment.id;

      final assignment = ABTestAssignmentModel(
        id: '', // Will be set by Firestore
        testId: testId,
        userId: userId,
        variantId: variantId,
        assignedAt: DateTime.now(),
      );

      final docRef = firestore.collection('ab_test_assignments').doc();
      await docRef.set(assignment.copyWith(id: docRef.id).toFirestore());

      logger.i('Successfully assigned user $userId to variant $variantId');
      return assignment.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      logger.e('Error assigning user to variant: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> trackABTestEvent({
    required String testId,
    required String userId,
    required String eventType,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      logger.i(
        'Tracking A/B test event: $eventType for user $userId in test $testId',
      );

      // Get user's assignment
      final assignmentQuery = await firestore
          .collection('ab_test_assignments')
          .where('testId', isEqualTo: testId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (assignmentQuery.docs.isEmpty) {
        logger.w('User $userId not assigned to test $testId');
        return;
      }

      final assignment = ABTestAssignmentModel.fromFirestore(
        assignmentQuery.docs.first,
      );

      // Record event
      await firestore.collection('ab_test_events').add({
        'testId': testId,
        'userId': userId,
        'variantId': assignment.variantId,
        'eventType': eventType,
        'eventData': eventData ?? {},
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });

      // Update assignment last seen
      await firestore
          .collection('ab_test_assignments')
          .doc(assignment.id)
          .update({'lastSeenAt': Timestamp.fromDate(DateTime.now())});

      logger.i('Successfully tracked A/B test event');
    } catch (e, stackTrace) {
      logger.e('Error tracking A/B test event: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ABTestResultModel> calculateABTestStats(String testId) async {
    try {
      logger.i('Calculating A/B test statistics: $testId');

      // Get test
      final test = await getABTest(testId);

      // Get all assignments
      final assignmentsSnapshot = await firestore
          .collection('ab_test_assignments')
          .where('testId', isEqualTo: testId)
          .get();

      final assignments = assignmentsSnapshot.docs
          .map((doc) => ABTestAssignmentModel.fromFirestore(doc))
          .toList();

      // Get all events
      final eventsSnapshot = await firestore
          .collection('ab_test_events')
          .where('testId', isEqualTo: testId)
          .get();

      final events = eventsSnapshot.docs.map((doc) => doc.data()).toList();

      // Calculate metrics for each variant
      final controlAssignments = assignments
          .where((a) => a.variantId == test.control.id)
          .toList();
      final treatmentAssignments = assignments
          .where((a) => a.variantId == test.treatment.id)
          .toList();

      // Count events by variant
      final controlEvents = events
          .where((e) => e['variantId'] == test.control.id)
          .toList();
      final treatmentEvents = events
          .where((e) => e['variantId'] == test.treatment.id)
          .toList();

      // Calculate impressions (users who saw the variant)
      final controlImpressions = controlAssignments.length;
      final treatmentImpressions = treatmentAssignments.length;

      // Calculate events (e.g., clicks)
      final controlEventCount = controlEvents.length;
      final treatmentEventCount = treatmentEvents.length;

      // Calculate conversion rate
      final controlConversionRate = controlImpressions > 0
          ? (controlEventCount / controlImpressions) * 100
          : 0.0;
      final treatmentConversionRate = treatmentImpressions > 0
          ? (treatmentEventCount / treatmentImpressions) * 100
          : 0.0;

      // Calculate metric value based on test metric type
      final controlMetricValue = controlConversionRate;
      final treatmentMetricValue = treatmentConversionRate;

      final controlMetrics = ABTestVariantMetricsModel(
        variantId: test.control.id,
        metricValue: controlMetricValue,
        participants: controlAssignments.length,
        events: controlEventCount,
        impressions: controlImpressions,
        conversionRate: controlConversionRate,
      );

      final treatmentMetrics = ABTestVariantMetricsModel(
        variantId: test.treatment.id,
        metricValue: treatmentMetricValue,
        participants: treatmentAssignments.length,
        events: treatmentEventCount,
        impressions: treatmentImpressions,
        conversionRate: treatmentConversionRate,
      );

      // Calculate improvement
      final improvement = controlMetricValue > 0
          ? ((treatmentMetricValue - controlMetricValue) / controlMetricValue) *
                100
          : 0.0;

      // Calculate statistical confidence using z-test
      final confidence = _calculateConfidence(
        controlImpressions,
        controlEventCount,
        treatmentImpressions,
        treatmentEventCount,
      );

      final isSignificant = confidence >= 95.0;
      String? winner;
      if (isSignificant) {
        winner = treatmentMetricValue > controlMetricValue
            ? test.treatment.id
            : test.control.id;
      }

      final result = ABTestResultModel(
        testId: testId,
        controlMetrics: controlMetrics,
        treatmentMetrics: treatmentMetrics,
        improvement: improvement,
        confidence: confidence,
        isSignificant: isSignificant,
        winner: winner,
        calculatedAt: DateTime.now(),
        totalParticipants: assignments.length,
        controlParticipants: controlAssignments.length,
        treatmentParticipants: treatmentAssignments.length,
      );

      // Save results
      await firestore
          .collection('ab_test_results')
          .doc(testId)
          .set(result.toFirestore());

      logger.i('Successfully calculated A/B test statistics');
      return result;
    } catch (e, stackTrace) {
      logger.e(
        'Error calculating A/B test statistics: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Calculate statistical confidence using z-test
  double _calculateConfidence(
    int controlImpressions,
    int controlEvents,
    int treatmentImpressions,
    int treatmentEvents,
  ) {
    if (controlImpressions == 0 || treatmentImpressions == 0) {
      return 0.0;
    }

    final controlRate = controlEvents / controlImpressions;
    final treatmentRate = treatmentEvents / treatmentImpressions;

    if (controlRate == 0 && treatmentRate == 0) {
      return 0.0;
    }

    // Pooled standard error
    final pooledRate =
        (controlEvents + treatmentEvents) /
        (controlImpressions + treatmentImpressions);
    final pooledStdErr = sqrt(
      pooledRate *
          (1 - pooledRate) *
          (1.0 / controlImpressions + 1.0 / treatmentImpressions),
    );

    if (pooledStdErr == 0) {
      return 0.0;
    }

    // Z-score
    final zScore = (treatmentRate - controlRate) / pooledStdErr;

    // Convert to confidence percentage (two-tailed test)
    // Using normal approximation
    final confidence = (1 - 2 * (1 - _normalCDF(zScore.abs()))) * 100;

    return confidence.clamp(0.0, 100.0);
  }

  /// Normal cumulative distribution function approximation
  double _normalCDF(double x) {
    // Approximation using error function
    return 0.5 * (1 + _erf(x / sqrt(2)));
  }

  /// Error function approximation
  double _erf(double x) {
    // Abramowitz and Stegun approximation
    final a1 = 0.254829592;
    final a2 = -0.284496736;
    final a3 = 1.421413741;
    final a4 = -1.453152027;
    final a5 = 1.061405429;
    final p = 0.3275911;

    final sign = x < 0 ? -1 : 1;
    x = x.abs();

    final t = 1.0 / (1.0 + p * x);
    final y =
        1.0 -
        (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);

    return sign * y;
  }

  @override
  Future<void> rolloutWinner({
    required String testId,
    required String winnerVariantId,
  }) async {
    try {
      logger.i('Rolling out winner $winnerVariantId for test $testId');

      // Update test to completed
      await completeABTest(testId);

      // Update all assignments to use winner variant
      final assignmentsSnapshot = await firestore
          .collection('ab_test_assignments')
          .where('testId', isEqualTo: testId)
          .get();

      final batch = firestore.batch();
      for (var doc in assignmentsSnapshot.docs) {
        batch.update(doc.reference, {
          'variantId': winnerVariantId,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();

      logger.i('Successfully rolled out winner');
    } catch (e, stackTrace) {
      logger.e('Error rolling out winner: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
