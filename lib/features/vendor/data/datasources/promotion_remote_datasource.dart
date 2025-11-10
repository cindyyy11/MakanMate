import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<List<PromotionModel>> getPromotions(String vendorId);
  Future<List<PromotionModel>> getPromotionsByStatus(String vendorId, String status);
  Future<void> addPromotion(String vendorId, PromotionModel promotion);
  Future<void> updatePromotion(String vendorId, PromotionModel promotion);
  Future<void> deletePromotion(String vendorId, String promotionId);
  Future<void> deactivatePromotion(String vendorId, String promotionId);
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<List<PromotionModel>> getPromotions(String vendorId) async {
    final snapshot = await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('promotions')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return PromotionModel.fromMap({
            'id': doc.id,
            ...data,
          });
        })
        .toList();
  }

  @override
  Future<List<PromotionModel>> getPromotionsByStatus(
      String vendorId, String status) async {
    QuerySnapshot snapshot;
    
    if (status == 'active') {
      // Active promotions: status is 'active' and not expired
      final now = Timestamp.now();
      snapshot = await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .where('status', isEqualTo: 'active')
          .where('expiryDate', isGreaterThan: now)
          .orderBy('expiryDate')
          .orderBy('createdAt', descending: true)
          .get();
    } else if (status == 'expired') {
      // Expired promotions: past expiry date or status is expired
      final now = Timestamp.now();
      snapshot = await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .where('expiryDate', isLessThan: now)
          .orderBy('expiryDate', descending: true)
          .get();
    } else {
      // Other statuses (pending, approved, deactivated)
      snapshot = await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
    }

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return PromotionModel.fromMap({
            'id': doc.id,
            ...data,
          });
        })
        .toList();
  }

  @override
  Future<void> addPromotion(String vendorId, PromotionModel promotion) async {
    // Add to vendor's promotions collection
    await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('promotions')
        .add(promotion.toMap());
    
    // Also add to admin approval queue
    final promotionMap = promotion.toMap();
    promotionMap['vendorId'] = vendorId;
    promotionMap['submittedAt'] = Timestamp.now();
    await firestore
        .collection('admin')
        .doc('approvals')
        .collection('promotions')
        .add(promotionMap);
  }

  @override
  Future<void> updatePromotion(String vendorId, PromotionModel promotion) async {
    await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('promotions')
        .doc(promotion.id)
        .update(promotion.toMap());
  }

  @override
  Future<void> deletePromotion(String vendorId, String promotionId) async {
    await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('promotions')
        .doc(promotionId)
        .delete();
  }

  @override
  Future<void> deactivatePromotion(String vendorId, String promotionId) async {
    await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('promotions')
        .doc(promotionId)
        .update({
      'status': 'deactivated',
    });
  }
}

