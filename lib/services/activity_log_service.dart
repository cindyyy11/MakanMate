import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:makan_mate/services/base_service.dart';
import 'package:logger/logger.dart';
import 'dart:io' show Platform;

/// Service to automatically log user and admin activities
class ActivityLogService extends BaseService {
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal();

  final Logger _logger = Logger();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Log user activity
  Future<void> logActivity({
    required String userId,
    required String userName,
    required String action,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      String? deviceInfo;

      try {
        if (Platform.isAndroid) {
          final androidInfo = await _deviceInfo.androidInfo;
          deviceInfo = '${androidInfo.brand} ${androidInfo.model}';
        } else if (Platform.isIOS) {
          final iosInfo = await _deviceInfo.iosInfo;
          deviceInfo = '${iosInfo.name} ${iosInfo.model}';
        } else {
          deviceInfo = 'Web/Desktop';
        }
      } catch (e) {
        deviceInfo = 'Unknown';
      }

      await BaseService.firestore.collection('activity_logs').add({
        'userId': userId,
        'userName': userName,
        'action': action,
        'details': details,
        'deviceInfo': deviceInfo,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });

      _logger.d('Logged activity: $action by $userName');
    } catch (e) {
      _logger.e('Error logging activity: $e');
    }
  }

  /// Log user sign up
  Future<void> logUserSignUp(String userId, String userName) async {
    await logActivity(
      userId: userId,
      userName: userName,
      action: 'user_signup',
      details: 'User signed up',
    );
  }

  /// Log user sign in
  Future<void> logUserSignIn(String userId, String userName) async {
    await logActivity(
      userId: userId,
      userName: userName,
      action: 'user_login',
      details: 'User signed in',
    );
  }

  /// Log vendor application
  Future<void> logVendorApplication(String userId, String userName) async {
    await logActivity(
      userId: userId,
      userName: userName,
      action: 'vendor_application_submitted',
      details: 'Vendor application submitted',
    );
  }

  /// Log review submission
  Future<void> logReviewSubmission(
    String userId,
    String userName,
    String restaurantId,
  ) async {
    await logActivity(
      userId: userId,
      userName: userName,
      action: 'review_submitted',
      details: 'Review submitted for restaurant',
      metadata: {'restaurantId': restaurantId},
    );
  }

  /// Log food item view
  Future<void> logFoodItemView(
    String userId,
    String userName,
    String foodItemId,
  ) async {
    await logActivity(
      userId: userId,
      userName: userName,
      action: 'food_item_viewed',
      details: 'Food item viewed',
      metadata: {'foodItemId': foodItemId},
    );
  }
}
