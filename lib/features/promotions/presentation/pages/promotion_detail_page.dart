import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      final check = di.sl<CheckUserRedemptionUseCase>();
      final redeemed = await check(widget.vendorId, widget.promotion.id, userId);
      setState(() {
        _isRedeemed = redeemed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _redeem() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnack('Please log in to redeem promotions', true);
      return;
    }

    if (_isRedeemed) {
      _showSnack('You have already redeemed this promotion', true);
      return;
    }

    setState(() => _isRedeeming = true);

    try {
      final redeemUseCase = di.sl<RedeemPromotionUseCase>();
      await redeemUseCase(widget.vendorId, widget.promotion.id, userId);

      final inc = di.sl<IncrementPromotionRedeemedForUserUseCase>();
      await inc(widget.vendorId, widget.promotion.id);

      setState(() {
        _isRedeemed = true;
        _isRedeeming = false;
      });

      _showSnack('Promotion redeemed! Show this to the vendor.', false);
    } catch (e) {
      setState(() => _isRedeeming = false);
      _showSnack('Failed to redeem. Please try again.', true);
    }
  }

  void _showSnack(String msg, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(widget.promotion.title),
        elevation: 0.5,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE BANNER
            if (widget.promotion.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.promotion.imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(height: 240, color: theme.cardColor),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Vendor Name
                  if (widget.promotion.vendorName != null) ...[
                    Row(
                      children: [
                        Icon(Icons.store,
                            color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.promotion.vendorName!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  /// TITLE
                  Text(
                    widget.promotion.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Discount Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.promotion.getDisplayText(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Description
                  Text(
                    "Description",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.promotion.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Valid Until
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: theme.iconTheme.color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Valid until: ${dateFormat.format(widget.promotion.expiryDate)}",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  /// Redeem Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isRedeemed || _isRedeeming ? null : _redeem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRedeemed
                                  ? Colors.grey
                                  : theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isRedeeming
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isRedeemed
                                        ? "Already Redeemed ✓"
                                        : "Redeem Now",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                          ),
                        ),

                  if (_isRedeemed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "You have redeemed this. Show this screen to the vendor.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green[800],
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
