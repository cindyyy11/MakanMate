import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../vendor/domain/entities/promotion_entity.dart';

class PromotionCard extends StatelessWidget {
  final PromotionEntity promotion;
  final VoidCallback? onEdit;
  final VoidCallback? onDeactivate;

  const PromotionCard({
    required this.promotion,
    this.onEdit,
    this.onDeactivate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isExpired = promotion.isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Promotion type tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          promotion.getTypeTag(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator with better colors
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(promotion.status, isExpired),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(promotion.status, isExpired),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(promotion.status, isExpired),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Image and highlight section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: promotion.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: promotion.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.local_offer, size: 40),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.local_offer, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                // Highlight text
                Expanded(
                  child: Text(
                    promotion.getDisplayText(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              promotion.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Expiry date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  isExpired
                      ? 'Expired: ${dateFormat.format(promotion.expiryDate)}'
                      : 'Expires: ${dateFormat.format(promotion.expiryDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[700],
                      side: BorderSide(color: Colors.orange[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDeactivate,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Deactivate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PromotionStatus status, bool isExpired) {
    if (isExpired) return Colors.grey;
    switch (status) {
      case PromotionStatus.pending:
        return Colors.orange;
      case PromotionStatus.approved:
        return Colors.blue;
      case PromotionStatus.active:
        return Colors.green;
      case PromotionStatus.rejected:
        return Colors.red;
      case PromotionStatus.deactivated:
        return Colors.grey;
      case PromotionStatus.expired:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PromotionStatus status, bool isExpired) {
    if (isExpired) return Icons.access_time;
    switch (status) {
      case PromotionStatus.pending:
        return Icons.pending;
      case PromotionStatus.approved:
        return Icons.check_circle;
      case PromotionStatus.active:
        return Icons.check_circle;
      case PromotionStatus.rejected:
        return Icons.cancel;
      case PromotionStatus.deactivated:
        return Icons.block;
      case PromotionStatus.expired:
        return Icons.access_time;
    }
  }

  String _getStatusText(PromotionStatus status, bool isExpired) {
    if (isExpired) return 'Expired';
    switch (status) {
      case PromotionStatus.pending:
        return 'Pending Approval';
      case PromotionStatus.approved:
        return 'Approved';
      case PromotionStatus.active:
        return 'Active';
      case PromotionStatus.rejected:
        return 'Rejected';
      case PromotionStatus.deactivated:
        return 'Deactivated';
      case PromotionStatus.expired:
        return 'Expired';
    }
  }
}

