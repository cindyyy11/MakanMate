import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/data/models/activity_log_model.dart';
import 'package:makan_mate/features/admin/data/models/admin_notification_model.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/data/models/metric_trend_model.dart';
import 'package:makan_mate/features/admin/data/models/platform_metrics_model.dart';
import 'package:makan_mate/features/admin/data/models/system_metrics_model.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';

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
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final Logger logger;

  AdminRemoteDataSourceImpl({required this.firestore, required this.logger});

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
      final snapshot = await firestore
          .collection('vendors')
          .where('status', isEqualTo: 'active')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting active vendors: $e');
      return 0;
    }
  }

  /// Count pending vendor applications
  Future<int> _getPendingApplications() async {
    try {
      final snapshot = await firestore
          .collection('vendor_applications')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting pending applications: $e');
      return 0;
    }
  }

  /// Count flagged reviews
  Future<int> _getFlaggedReviews() async {
    try {
      final snapshot = await firestore
          .collection('flagged_content')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting flagged reviews: $e');
      return 0;
    }
  }

  /// Calculate average platform rating
  Future<double> _getAverageRating() async {
    try {
      // Get all reviews and calculate average
      final reviewsSnapshot = await firestore.collection('reviews').get();

      if (reviewsSnapshot.docs.isEmpty) {
        return 0.0;
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

  /// Count total restaurants
  Future<int> _getTotalRestaurants() async {
    try {
      final snapshot = await firestore.collection('restaurants').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting restaurants: $e');
      return 0;
    }
  }

  /// Count total food items
  Future<int> _getTotalFoodItems() async {
    try {
      final snapshot = await firestore.collection('food_items').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      logger.w('Error counting food items: $e');
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

      Query query = firestore
          .collection('activity_logs')
          .orderBy('timestamp', descending: true);

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
        query = query.where('userId', isEqualTo: userId);
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
    } catch (e, stackTrace) {
      logger.e('Error fetching notifications: $e', stackTrace: stackTrace);
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
}
