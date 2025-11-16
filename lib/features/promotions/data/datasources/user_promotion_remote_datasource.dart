import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../vendor/data/models/promotion_model.dart';

abstract class UserPromotionRemoteDataSource {
  Stream<List<PromotionModel>> watchApprovedPromotions();
  Future<bool> hasUserRedeemed(String vendorId, String promotionId, String userId);
  Future<void> redeemPromotion(String vendorId, String promotionId, String userId);
}

class UserPromotionRemoteDataSourceImpl
    implements UserPromotionRemoteDataSource {
  final FirebaseFirestore firestore;

  UserPromotionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<PromotionModel>> watchApprovedPromotions() {
    final now = DateTime.now();

    return firestore
        .collectionGroup('promotions')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .asyncMap((snapshot) async {
          print('📥 Received ${snapshot.docs.length} documents from Firestore');

          final List<PromotionModel> promotionsWithVendors = [];

          for (final doc in snapshot.docs) {
            try {
              final promotion = PromotionModel.fromFirestore(doc);
              
              // Fetch vendor name
              String? vendorName;
              if (promotion.vendorId != null && promotion.vendorId!.isNotEmpty) {
                try {
                  final vendorDoc = await firestore
                      .collection('vendors')
                      .doc(promotion.vendorId)
                      .get();
                  
                  if (vendorDoc.exists) {
                    final vendorData = vendorDoc.data();
                    vendorName = vendorData?['businessName'] as String? ??
                                vendorData?['name'] as String? ??
                                'Unknown Vendor';
                    print('🏪 Found vendor: $vendorName for promotion ${promotion.id}');
                  } else {
                    print('⚠️ Vendor document not found for ID: ${promotion.vendorId}');
                  }
                } catch (e) {
                  print('❌ Error fetching vendor for ${promotion.vendorId}: $e');
                }
              }

              // Create promotion with vendor name
              final promotionWithVendor = PromotionModel(
                id: promotion.id,
                title: promotion.title,
                description: promotion.description,
                type: promotion.type,
                status: promotion.status,
                discountPercentage: promotion.discountPercentage,
                flatDiscountAmount: promotion.flatDiscountAmount,
                buyQuantity: promotion.buyQuantity,
                getQuantity: promotion.getQuantity,
                imageUrl: promotion.imageUrl,
                startDate: promotion.startDate,
                expiryDate: promotion.expiryDate,
                createdAt: promotion.createdAt,
                approvedAt: promotion.approvedAt,
                approvedBy: promotion.approvedBy,
                clickCount: promotion.clickCount,
                redeemedCount: promotion.redeemedCount,
                conversionRate: promotion.conversionRate,
                vendorId: promotion.vendorId,
                vendorName: vendorName, // ⬅️ Add vendor name
              );

              print('✅ Parsed: ${promotionWithVendor.id} - ${promotionWithVendor.title} - Vendor: $vendorName');

              // Filter promotions
              final hasStarted = !promotionWithVendor.startDate.isAfter(now);
              final notExpired = !promotionWithVendor.isExpired;
              final hasVendor = (promotionWithVendor.vendorId ?? '').isNotEmpty;
              final isValidStatus = promotionWithVendor.status.toString().contains('approved') || 
                                    promotionWithVendor.status.toString().contains('active');
              
              if (hasStarted && notExpired && hasVendor && isValidStatus) {
                promotionsWithVendors.add(promotionWithVendor);
              } else {
                print('⏭️ Filtered out ${promotionWithVendor.id}: started=$hasStarted, expired=$notExpired, vendor=$hasVendor, status=$isValidStatus');
              }
            } catch (e) {
              print('❌ Error parsing promotion ${doc.id}: $e');
            }
          }

          promotionsWithVendors.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
          print('📊 Final result: ${promotionsWithVendors.length} valid promotions with vendor names');
          
          return promotionsWithVendors;
        })
        .handleError((error) {
          print('🔥 Firestore query error: $error');
          throw Exception('Failed to load promotions: ${error.toString()}');
        });
  }

  @override
  Future<bool> hasUserRedeemed(String vendorId, String promotionId, String userId) async {
    try {
      final doc = await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .collection('redemptions')
          .doc(userId)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('Error checking redemption: $e');
      return false;
    }
  }

  @override
  Future<void> redeemPromotion(String vendorId, String promotionId, String userId) async {
    try {
      await firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .collection('redemptions')
          .doc(userId)
          .set({
        'redeemedAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });
      
      print('✅ Promotion redeemed successfully');
    } catch (e) {
      print('❌ Error redeeming promotion: $e');
      throw Exception('Failed to redeem promotion: $e');
    }
  }
}   