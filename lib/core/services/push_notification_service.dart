import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:makan_mate/core/utils/logger.dart';

/// Handles push notification permissions, token management,
/// topic subscriptions, and message handling for admin users.
///
/// **What Firebase Messaging uses:**
/// 1. **Device Token** - Unique identifier for each device/app installation
/// 2. **FCM Topics** - Pub/sub system for broadcasting to groups (e.g., admin_123)
/// 3. **Firestore** - Stores device tokens in admin_devices collection
/// 4. **Cloud Functions** - Sends notifications from backend
/// 5. **OS Notification System** - Shows notifications via Android/iOS native APIs
class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final _devicesRef = FirebaseFirestore.instance.collection(
    'admin_devices',
  );

  /// Navigation callback - set this to handle notification taps
  static Function(Map<String, dynamic>)? onNotificationTap;

  /// Requests notification permission and registers the current device
  /// for push notifications associated with the given [adminId].
  ///
  /// Returns true if push notifications are enabled, false otherwise.
  static Future<bool> enableAdminPush(String adminId) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
    );

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!authorized) return false;

    final token = await _messaging.getToken();
    if (token == null) return false;

    await _storeToken(adminId, token);
    await _messaging.subscribeToTopic(_adminTopic(adminId));

    _messaging.onTokenRefresh.listen((newToken) {
      _storeToken(adminId, newToken);
    });

    return true;
  }

  /// Removes push notification capabilities for the given [adminId].
  static Future<void> disableAdminPush(String adminId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _devicesRef.doc(adminId).set({
        'tokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await _messaging.unsubscribeFromTopic(_adminTopic(adminId));
  }

  static Future<void> _storeToken(String adminId, String token) async {
    await _devicesRef.doc(adminId).set({
      'tokens': FieldValue.arrayUnion([token]),
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static String _adminTopic(String adminId) => 'admin_$adminId';

  /// Initialize message listeners for foreground notifications and taps
  ///
  /// **What it uses:**
  /// - `onMessage` - Handles notifications when app is OPEN (foreground)
  /// - `onMessageOpenedApp` - Handles when user TAPS notification (app in background)
  /// - `getInitialMessage` - Handles when user TAPS notification (app terminated)
  ///
  /// **When each is called:**
  /// 1. **onMessage**: App is open → Show in-app notification or update UI
  /// 2. **onMessageOpenedApp**: App in background → User taps notification → Navigate
  /// 3. **getInitialMessage**: App terminated → User taps notification → Navigate
  static void initializeListeners() {
    // ============================================================
    // 1. FOREGROUND MESSAGES (App is open)
    // ============================================================
    // **What it uses:** Firebase Messaging onMessage stream (static)
    // **When called:** Notification arrives while app is visible
    // **Purpose:** Show custom UI or in-app notification since OS won't show it
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.i('Foreground message received: ${message.messageId}');
      log.i('Title: ${message.notification?.title}');
      log.i('Body: ${message.notification?.body}');
      log.i('Data: ${message.data}');

      // Show in-app notification or update UI
      // Note: OS won't show notification banner when app is in foreground
      // You can use flutter_local_notifications to show custom notification
      _handleForegroundMessage(message);
    });

    // ============================================================
    // 2. NOTIFICATION TAP (App in background)
    // ============================================================
    // **What it uses:** Firebase Messaging onMessageOpenedApp stream (static)
    // **When called:** User taps notification while app is in background
    // **Purpose:** Navigate to specific screen based on notification data
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log.i('Notification tapped (app was in background)');
      log.i('Data: ${message.data}');

      _handleNotificationTap(message.data);
    });

    // ============================================================
    // 3. NOTIFICATION TAP (App was terminated)
    // ============================================================
    // **What it uses:** Firebase Messaging getInitialMessage() (instance method)
    // **When called:** User taps notification that opened the app
    // **Purpose:** Navigate to specific screen when app launches from notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log.i('App opened from notification (app was terminated)');
        log.i('Data: ${message.data}');

        // Delay navigation to ensure app is fully initialized
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap(message.data);
        });
      }
    });

    // ============================================================
    // 4. TOKEN REFRESH HANDLER
    // ============================================================
    // **What it uses:** Firebase Messaging onTokenRefresh stream (instance method)
    // **When called:** FCM token changes (app reinstall, device restore, etc.)
    // **Purpose:** Update stored token in Firestore automatically
    _messaging.onTokenRefresh.listen((String newToken) {
      log.i('FCM token refreshed: $newToken');
      // Token will be updated when admin enables push notifications
      // This listener ensures token stays current
    });
  }

  /// Handle foreground messages (app is open)
  ///
  /// **What it uses:**
  /// - Notification data from FCM
  /// - Can show in-app banner, update UI, or use flutter_local_notifications
  ///
  /// **Current implementation:** Logs the message
  /// **Future enhancement:** Show in-app notification banner
  static void _handleForegroundMessage(RemoteMessage message) {

    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';

    log.i('Foreground notification: $title - $body');
    log.i('Notification data: ${message.data}');

    // Example: You could use a global navigator key to show a dialog
    // or use a state management solution to update UI
  }

  /// Handle notification tap navigation
  ///
  /// **What it uses:**
  /// - Notification data payload (custom data sent from Cloud Functions)
  /// - Navigation callback (if set via onNotificationTap)
  ///
  /// **Data structure expected:**
  /// ```json
  /// {
  ///   "type": "security_event",
  ///   "action": "password_changed",
  ///   "logId": "abc123"
  /// }
  /// ```
  static void _handleNotificationTap(Map<String, dynamic> data) {
    log.i('Handling notification tap with data: $data');

    // Call custom navigation handler if set
    if (onNotificationTap != null) {
      onNotificationTap!(data);
      return;
    }

    // Default handling based on notification type
    final type = data['type'] as String?;

    switch (type) {
      case 'security_event':
        // Navigate to admin profile security activity
        log.i('Security event notification tapped');
        // You can use Navigator or routing solution here
        break;
      case 'announcement':
        // Handle announcement notification tap
        log.i('Announcement notification tapped: ${data['announcementId']}');
        // Navigate to announcements page or show announcement details
        // You can use Navigator or routing solution here
        break;
      default:
        log.i('Unknown notification type: $type');
    }
  }

  /// Subscribe user to FCM topics based on their role
  /// 
  /// Call this after user login to ensure they receive relevant announcements
  static Future<void> subscribeToAnnouncementTopics(String userRole) async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Subscribe based on role
      switch (userRole.toLowerCase()) {
        case 'user':
          await messaging.subscribeToTopic('all_users');
          log.i('Subscribed to all_users topic');
          break;
        case 'vendor':
          await messaging.subscribeToTopic('all_vendors');
          log.i('Subscribed to all_vendors topic');
          break;
        case 'admin':
          await messaging.subscribeToTopic('all_admins');
          log.i('Subscribed to all_admins topic');
          break;
        default:
          // Subscribe to all users topic as default
          await messaging.subscribeToTopic('all_users');
          log.i('Subscribed to all_users topic (default)');
      }
      
      // Always subscribe to all_users for general announcements
      await messaging.subscribeToTopic('all_users');
    } catch (e) {
      log.e('Error subscribing to announcement topics: $e');
    }
  }

  /// Unsubscribe from all announcement topics
  static Future<void> unsubscribeFromAnnouncementTopics() async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      await Future.wait([
        messaging.unsubscribeFromTopic('all_users'),
        messaging.unsubscribeFromTopic('all_vendors'),
        messaging.unsubscribeFromTopic('all_admins'),
      ]);
      
      log.i('Unsubscribed from all announcement topics');
    } catch (e) {
      log.e('Error unsubscribing from announcement topics: $e');
    }
  }

  /// Request notification permissions for iOS
  ///
  /// **What it uses:**
  /// - iOS native permission system
  /// - Returns authorization status
  ///
  /// **Note:** Android doesn't require runtime permission (uses manifest)
  static Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true, // Show alert/banner
      badge: true, // Show app badge
      sound: true, // Play sound
      announcement: true, // iOS 13+ voice announcements
      provisional: false, // iOS 12+ provisional authorization
      criticalAlert: false, // Critical alerts (requires special entitlement)
    );

    return settings.authorizationStatus;
  }
}
