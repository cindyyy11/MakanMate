import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../vendor/domain/entities/promotion_entity.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/usecases/check_user_redemption_usecase.dart';
import '../../domain/usecases/redeem_promotion_usecase.dart';
import '../../../vendor/domain/usecases/increment_promotion_redeemed_for_user_usecase.dart';

class PromotionDetailPage extends StatefulWidget {
  final PromotionEntity promotion;
  final String vendorId;

  const PromotionDetailPage({
    super.key,
    required this.promotion,
    required this.vendorId,
  });

  @override
  State<PromotionDetailPage> createState() => _PromotionDetailPageState();
}

class _PromotionDetailPageState extends State<PromotionDetailPage> {
  bool _isRedeemed = false;
  bool _isLoading = true;
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    _checkRedemptionStatus();
  }

  Future<void> _checkRedemptionStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final checkRedemption = di.sl<CheckUserRedemptionUseCase>();
      final hasRedeemed = await checkRedemption(
        widget.vendorId,
        widget.promotion.id,
        userId,
      );
      
      setState(() {
        _isRedeemed = hasRedeemed;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking redemption: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _redeemPromotion() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('Please log in to redeem promotions', isError: true);
      return;
    }

    if (_isRedeemed) {
      _showSnackBar('You have already redeemed this promotion', isError: true);
      return;
    }

    setState(() => _isRedeeming = true);

    try {
      // Mark as redeemed in database
      final redeemUseCase = di.sl<RedeemPromotionUseCase>();
      await redeemUseCase(widget.vendorId, widget.promotion.id, userId);

      // Increment redeemed count
      final incrementUseCase = di.sl<IncrementPromotionRedeemedForUserUseCase>();
      await incrementUseCase(widget.vendorId, widget.promotion.id);

      setState(() {
        _isRedeemed = true;
        _isRedeeming = false;
      });

      _showSnackBar('Promotion redeemed successfully! Show this to the vendor.', isError: false);
    } catch (e) {
      setState(() => _isRedeeming = false);
      _showSnackBar('Failed to redeem promotion. Please try again.', isError: true);
      print('Error redeeming: $e');
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotion Details'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (widget.promotion.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.promotion.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.local_offer, size: 80),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Name
                  if (widget.promotion.vendorName != null) ...[
                    Row(
                      children: [
                        Icon(Icons.store, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          widget.promotion.vendorName!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Title
                  Text(
                    widget.promotion.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Discount display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Text(
                      widget.promotion.getDisplayText(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.promotion.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dates
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Valid until: ${dateFormat.format(widget.promotion.expiryDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Redeem Button
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isRedeemed || _isRedeeming ? null : _redeemPromotion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRedeemed ? Colors.grey : Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isRedeeming
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isRedeemed ? 'Already Redeemed ✓' : 'Redeem Now',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  
                  if (_isRedeemed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You have already redeemed this promotion. Show this screen to the vendor.',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}