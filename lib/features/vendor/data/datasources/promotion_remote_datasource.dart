import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion_model.dart';
import '../../domain/entities/promotion_entity.dart';

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
    // Use simple server-side filters (single-field) to avoid composite index requirements.
    final col = firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('promotions');

    final nowTs = Timestamp.fromDate(DateTime.now());

    if (status == 'active') {
      // Query by expiryDate only, filter status client-side to avoid composite index.
      final snapshot = await col
          .where('expiryDate', isGreaterThan: nowTs)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return PromotionModel.fromMap({'id': doc.id, ...data});
      }).toList();

      final filtered = items.where((promo) {
        final s = _statusToString(promo.status);
        return s == 'active' || s == 'approved';
      }).toList();

      // Sort by expiry date ascending, then createdAt desc
      filtered.sort((a, b) {
        final cmp = a.expiryDate.compareTo(b.expiryDate);
        if (cmp != 0) return cmp;
        return b.createdAt.compareTo(a.createdAt);
      });
      return filtered;
    } else if (status == 'expired') {
      // Query by expiryDate only, then filter to include explicit expired status too.
      final snapshot = await col
          .where('expiryDate', isLessThan: nowTs)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return PromotionModel.fromMap({'id': doc.id, ...data});
      }).toList();

      final filtered = items.where((promo) {
        final s = _statusToString(promo.status);
        return promo.expiryDate.isBefore(DateTime.now()) || s == 'expired';
      }).toList();
      filtered.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
      return filtered;
    } else {
      // Single equality filter; sort client-side to avoid composite index.
      final snapshot = await col
          .where('status', isEqualTo: status)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return PromotionModel.fromMap({'id': doc.id, ...data});
      }).toList();

      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    }
  }

  @override
  Future<void> addPromotion(String vendorId, PromotionModel promotion) async {
    // Create promotion map with vendorId
    final promotionMap = promotion.toMap();
    promotionMap.remove('id'); // Remove id as Firestore will generate it
    
    // Add to vendor's promotions collection
    final docRef = await firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('promotions')
        .add(promotionMap);
    
    // Also add to admin approval queue with the generated ID
    final adminPromotionMap = Map<String, dynamic>.from(promotionMap);
    adminPromotionMap['vendorId'] = vendorId;
    adminPromotionMap['promotionId'] = docRef.id; // Link to vendor's promotion
    adminPromotionMap['status'] = 'pending'; // Ensure status is pending
    adminPromotionMap['submittedAt'] = Timestamp.now();
    await firestore
        .collection('admin')
        .doc('approvals')
        .collection('promotions')
        .add(adminPromotionMap);
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

  String _statusToString(PromotionStatus status) {
    switch (status) {
      case PromotionStatus.pending:
        return 'pending';
      case PromotionStatus.approved:
        return 'approved';
      case PromotionStatus.rejected:
        return 'rejected';
      case PromotionStatus.active:
        return 'active';
      case PromotionStatus.expired:
        return 'expired';
      case PromotionStatus.deactivated:
        return 'deactivated';
    }
  }
}

