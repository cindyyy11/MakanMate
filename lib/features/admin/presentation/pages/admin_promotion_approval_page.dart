import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminPromotionApprovalPage extends StatefulWidget {
  const AdminPromotionApprovalPage({super.key});

  @override
  State<AdminPromotionApprovalPage> createState() =>
      _AdminPromotionApprovalPageState();
}

class _AdminPromotionApprovalPageState
    extends State<AdminPromotionApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _approvePromotion(String approvalDocId, String vendorId,
      String promotionId, Map<String, dynamic> promotionData) async {
    try {
      final adminId = _auth.currentUser?.uid;
      if (adminId == null) return;

      // Update vendor's promotion status
      await _firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
      });

      // Remove from approval queue
      await _firestore
          .collection('admin')
          .doc('approvals')
          .collection('promotions')
          .doc(approvalDocId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promotion approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving promotion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectPromotion(String approvalDocId, String vendorId,
      String promotionId) async {
    try {
      final adminId = _auth.currentUser?.uid;
      if (adminId == null) return;

      // Update vendor's promotion status
      await _firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('promotions')
          .doc(promotionId)
          .update({
        'status': 'rejected',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
      });

      // Remove from approval queue
      await _firestore
          .collection('admin')
          .doc('approvals')
          .collection('promotions')
          .doc(approvalDocId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promotion rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting promotion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Promotion Approvals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('admin')
            .doc('approvals')
            .collection('promotions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No pending promotions',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All promotions have been reviewed',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Filter only pending promotions and sort
          final allPromotions = snapshot.data!.docs;
          final promotions = allPromotions.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String?;
            return status == null || status == 'pending';
          }).toList();
          
          // Sort by submittedAt descending (newest first)
          promotions.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['submittedAt'] as Timestamp?;
            final bTime = bData['submittedAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final doc = promotions[index];
              final data = doc.data() as Map<String, dynamic>;
              final dateFormat = DateFormat('MMM dd, yyyy');

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Type
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? 'Untitled',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getTypeLabel(data['type']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Image
                      if (data['imageUrl'] != null &&
                          (data['imageUrl'] as String).isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: data['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        data['description'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Promotion Details
                      _buildDetailRow('Discount', _getDiscountText(data)),
                      if (data['startDate'] != null)
                        _buildDetailRow(
                          'Start Date',
                          dateFormat.format(
                            (data['startDate'] as Timestamp).toDate(),
                          ),
                        ),
                      if (data['expiryDate'] != null)
                        _buildDetailRow(
                          'Expiry Date',
                          dateFormat.format(
                            (data['expiryDate'] as Timestamp).toDate(),
                          ),
                        ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rejectPromotion(
                                doc.id,
                                data['vendorId'] ?? '',
                                data['promotionId'] ?? '',
                              ),
                              icon: const Icon(Icons.cancel, size: 18),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _approvePromotion(
                                doc.id,
                                data['vendorId'] ?? '',
                                data['promotionId'] ?? '',
                                data,
                              ),
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'discount':
        return 'Discount';
      case 'flatDiscount':
        return 'Flat Discount';
      case 'buyXGetY':
        return 'Buy X Get Y';
      case 'birthday':
        return 'Birthday Voucher';
      default:
        return 'Promotion';
    }
  }

  String _getDiscountText(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'discount' && data['discountPercentage'] != null) {
      return '${data['discountPercentage']}% OFF';
    } else if (type == 'flatDiscount' && data['flatDiscountAmount'] != null) {
      return 'RM ${data['flatDiscountAmount']} OFF';
    } else if (type == 'buyXGetY') {
      return 'Buy ${data['buyQuantity']} Get ${data['getQuantity']}';
    } else if (type == 'birthday') {
      return 'Birthday Special';
    }
    return 'N/A';
  }
}

