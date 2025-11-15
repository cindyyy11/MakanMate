import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to track promotion analytics (views, clicks, redemptions)
class PromotionAnalyticsService {
  final FirebaseFirestore firestore;

  PromotionAnalyticsService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Track when a promotion is viewed (e.g., appears in a list)
  Future<void> trackView(String vendorId, String promotionId) async {
    try {
      final analyticsRef = firestore
          .collection('analytics_promotions')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId);

      await analyticsRef.set({
        'views': FieldValue.increment(1),
        'clicks': 0,
        'redeemed': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Log error but don't throw - analytics shouldn't break the app
      print('Error tracking promotion view: $e');
    }
  }

  /// Track when a user clicks on a promotion (views details or clicks claim button)
  Future<void> trackClick(String vendorId, String promotionId) async {
    try {
      final analyticsRef = firestore
          .collection('analytics_promotions')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId);

      await analyticsRef.set({
        'clicks': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error tracking promotion click: $e');
    }
  }

  /// Track when a user redeems a promotion
  Future<void> trackRedemption(String vendorId, String promotionId) async {
    try {
      final analyticsRef = firestore
          .collection('analytics_promotions')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId);

      await analyticsRef.set({
        'redeemed': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error tracking promotion redemption: $e');
    }
  }

  /// Track both view and click in one call (for when user clicks directly)
  Future<void> trackViewAndClick(String vendorId, String promotionId) async {
    try {
      final analyticsRef = firestore
          .collection('analytics_promotions')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId);

      await analyticsRef.set({
        'views': FieldValue.increment(1),
        'clicks': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error tracking promotion view and click: $e');
    }
  }
}

