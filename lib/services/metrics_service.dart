import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/services/base_service.dart';
import 'package:logger/logger.dart';

/// Service to automatically track and update platform metrics
///
/// This service runs in the background and updates metrics as users/vendors interact
class MetricsService extends BaseService {
  static final MetricsService _instance = MetricsService._internal();
  factory MetricsService() => _instance;
  MetricsService._internal();

  final Logger _logger = Logger();

  /// Initialize metrics tracking
  /// Call this when app starts
  Future<void> initialize() async {
    _logger.i('Initializing metrics service');

    // Initialize system_metrics document if it doesn't exist
    await _initializeSystemMetrics();

    // Start listening to collection changes to update metrics
    _startMetricsTracking();
  }

  /// Initialize system_metrics document
  Future<void> _initializeSystemMetrics() async {
    try {
      final metricsRef = BaseService.firestore
          .collection('system_metrics')
          .doc('current');

      final doc = await metricsRef.get();

      if (!doc.exists) {
        await metricsRef.set({
          'activeUsers': 0,
          'activeSessions': 0,
          'apiCallsPerMinute': 0,
          'avgResponseTime': 0.0,
          'errorCount': 0,
          'errorRate': 0.0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        _logger.i('Initialized system_metrics document');
      }
    } catch (e) {
      _logger.e('Error initializing system metrics: $e');
    }
  }

  /// Start tracking metrics from collection changes
  void _startMetricsTracking() {
    // Track user activity
    _trackUserActivity();

    // Track vendor activity
    _trackVendorActivity();

    // Update system metrics periodically
    _updateSystemMetricsPeriodically();
  }

  /// Track user activity and update lastActive field
  void _trackUserActivity() {
    // This will be called when users sign in or interact
    _logger.i('User activity tracking initialized');
  }

  /// Track vendor activity
  void _trackVendorActivity() {
    _logger.i('Vendor activity tracking initialized');
  }

  /// Update system metrics periodically
  void _updateSystemMetricsPeriodically() {
    // Update every minute
    Future.delayed(const Duration(minutes: 1), () {
      _updateSystemMetrics();
      _updateSystemMetricsPeriodically(); // Recursive call
    });
  }

  /// Update system metrics based on current activity
  Future<void> _updateSystemMetrics() async {
    try {
      // Count active users (users active in last 5 minutes)
      final activeUsers = await _countActiveUsers();

      // Count active sessions (approximate)
      final activeSessions = activeUsers; // Simplified

      // Get API call count (would need to track this separately)
      final apiCalls = await _getApiCallCount();

      // Update system metrics
      await BaseService.firestore
          .collection('system_metrics')
          .doc('current')
          .update({
            'activeUsers': activeUsers,
            'activeSessions': activeSessions,
            'apiCallsPerMinute': apiCalls,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      _logger.d('Updated system metrics: $activeUsers active users');
    } catch (e) {
      _logger.e('Error updating system metrics: $e');
    }
  }

  /// Count users active in the last 5 minutes
  Future<int> _countActiveUsers() async {
    try {
      final fiveMinutesAgo = DateTime.now().subtract(
        const Duration(minutes: 5),
      );

      final snapshot = await BaseService.firestore
          .collection('users')
          .where(
            'lastActive',
            isGreaterThan: Timestamp.fromDate(fiveMinutesAgo),
          )
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      _logger.w('Error counting active users: $e');
      return 0;
    }
  }

  /// Get API call count (simplified - would need actual tracking)
  Future<int> _getApiCallCount() async {
    // This would ideally come from a separate API tracking system
    // For now, return a placeholder
    return 0;
  }

  /// Update user's lastActive timestamp
  /// Call this whenever a user performs an action
  Future<void> updateUserActivity(String userId) async {
    try {
      await BaseService.firestore.collection('users').doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.w('Error updating user activity: $e');
    }
  }

  /// Track API call
  Future<void> trackApiCall({int? responseTime}) async {
    try {
      // Increment API call counter
      await BaseService.firestore
          .collection('system_metrics')
          .doc('current')
          .update({'apiCallsPerMinute': FieldValue.increment(1)});

      // Update average response time if provided
      if (responseTime != null) {
        final metricsDoc = await BaseService.firestore
            .collection('system_metrics')
            .doc('current')
            .get();

        if (metricsDoc.exists) {
          final data = metricsDoc.data()!;
          final currentAvg = (data['avgResponseTime'] ?? 0.0) as double;
          final callCount = (data['apiCallsPerMinute'] ?? 1) as int;

          // Calculate new average
          final newAvg =
              ((currentAvg * (callCount - 1)) + responseTime) / callCount;

          await BaseService.firestore
              .collection('system_metrics')
              .doc('current')
              .update({'avgResponseTime': newAvg});
        }
      }
    } catch (e) {
      _logger.w('Error tracking API call: $e');
    }
  }

  /// Track error
  Future<void> trackError() async {
    try {
      await BaseService.firestore
          .collection('system_metrics')
          .doc('current')
          .update({'errorCount': FieldValue.increment(1)});

      // Recalculate error rate
      await _recalculateErrorRate();
    } catch (e) {
      _logger.w('Error tracking error: $e');
    }
  }

  /// Recalculate error rate
  Future<void> _recalculateErrorRate() async {
    try {
      final metricsDoc = await BaseService.firestore
          .collection('system_metrics')
          .doc('current')
          .get();

      if (metricsDoc.exists) {
        final data = metricsDoc.data()!;
        final errorCount = (data['errorCount'] ?? 0) as int;
        final apiCalls = (data['apiCallsPerMinute'] ?? 1) as int;

        final errorRate = apiCalls > 0 ? (errorCount / apiCalls) * 100 : 0.0;

        await BaseService.firestore
            .collection('system_metrics')
            .doc('current')
            .update({'errorRate': errorRate});
      }
    } catch (e) {
      _logger.w('Error recalculating error rate: $e');
    }
  }
}
