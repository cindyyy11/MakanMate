import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import '../../data/services/promotion_analytics_service.dart';
import '../../domain/entities/promotion_entity.dart';

/// Customer-facing promotion card with analytics tracking
/// Use this widget when displaying promotions to customers
class CustomerPromotionCard extends StatefulWidget {
  final PromotionEntity promotion;
  final String vendorId;
  final VoidCallback? onTap;
  final VoidCallback? onRedeem;

  const CustomerPromotionCard({
    super.key,
    required this.promotion,
    required this.vendorId,
    this.onTap,
    this.onRedeem,
  });

  @override
  State<CustomerPromotionCard> createState() => _CustomerPromotionCardState();
}

class _CustomerPromotionCardState extends State<CustomerPromotionCard> {
  final _analyticsService = di.sl<PromotionAnalyticsService>();
  bool _hasTrackedView = false;

  @override
  void initState() {
    super.initState();
    // Track view when card is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasTrackedView) {
        _analyticsService.trackView(widget.vendorId, widget.promotion.id);
        _hasTrackedView = true;
      }
    });
  }

  void _handleTap() {
    // Track click when user taps on the card
    _analyticsService.trackClick(widget.vendorId, widget.promotion.id);
    widget.onTap?.call();
  }

  void _handleRedeem() {
    // Track redemption when user redeems the promotion
    _analyticsService.trackRedemption(widget.vendorId, widget.promotion.id);
    widget.onRedeem?.call();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isExpired = widget.promotion.isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: widget.promotion.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.promotion.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_offer, size: 60),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_offer, size: 60),
                    ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and highlight
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.promotion.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.promotion.getDisplayText(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Expired',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    widget.promotion.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Expiry date
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        isExpired
                            ? 'Expired: ${dateFormat.format(widget.promotion.expiryDate)}'
                            : 'Expires: ${dateFormat.format(widget.promotion.expiryDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isExpired ? null : _handleRedeem,
                      icon: const Icon(Icons.local_offer),
                      label: const Text('Claim Promotion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

