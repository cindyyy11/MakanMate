import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/services/base_service.dart';
import 'package:logger/logger.dart';

/// Service to automatically generate admin notifications
class NotificationService extends BaseService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Logger _logger = Logger();

  /// Create a notification
  Future<void> createNotification({
    required String title,
    required String message,
    required String type, // 'info', 'warning', 'critical'
    String? actionUrl,
  }) async {
    try {
      await BaseService.firestore.collection('admin_notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'actionUrl': actionUrl,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _logger.i('Created notification: $title');
    } catch (e) {
      _logger.e('Error creating notification: $e');
    }
  }

  /// Notify about new vendor application
  Future<void> notifyNewVendorApplication(String vendorName) async {
    await createNotification(
      title: 'New Vendor Application',
      message: '$vendorName has submitted a vendor application',
      type: 'info',
      actionUrl: '/admin/vendors/pending',
    );
  }

  /// Notify about flagged review
  Future<void> notifyFlaggedReview(String reviewId, String reason) async {
    await createNotification(
      title: 'Flagged Review',
      message: 'A review has been flagged: $reason',
      type: 'warning',
      actionUrl: '/admin/reviews/flagged',
    );
  }

  /// Notify about high error rate
  Future<void> notifyHighErrorRate(double errorRate) async {
    await createNotification(
      title: 'High Error Rate',
      message: 'System error rate is ${errorRate.toStringAsFixed(2)}%',
      type: 'critical',
      actionUrl: '/admin/system-health',
    );
  }

  /// Notify about pending applications threshold
  Future<void> notifyPendingApplicationsThreshold(int count) async {
    if (count >= 10) {
      await createNotification(
        title: 'Pending Applications Alert',
        message: 'You have $count pending vendor applications',
        type: 'warning',
        actionUrl: '/admin/vendors/pending',
      );
    }
  }
}
