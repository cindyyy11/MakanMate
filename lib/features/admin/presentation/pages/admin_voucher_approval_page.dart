import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_voucher_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_voucher_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_voucher_management_state.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_voucher_management_datasource.dart';
import 'package:makan_mate/features/vendor/data/models/promotion_model.dart';

class AdminVoucherApprovalPage extends StatelessWidget {
  const AdminVoucherApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher Approvals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<AdminVoucherManagementBloc,
          AdminVoucherManagementState>(
        listener: (context, state) {
          if (state is VoucherOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AdminVoucherManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminVoucherManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminVoucherManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<AdminVoucherManagementBloc>()
                          .add(const LoadPendingVouchers());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<PromotionWithVendorInfo> vouchers = [];
          if (state is VouchersLoaded) {
            vouchers = state.vouchers;
          }

          if (state is AdminVoucherManagementInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context
                  .read<AdminVoucherManagementBloc>()
                  .add(const LoadPendingVouchers());
            });
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<AdminVoucherManagementBloc>()
                  .add(const LoadPendingVouchers());
            },
            child: vouchers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: UIConstants.spacingMd),
                        Text(
                          'No pending vouchers',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: UIConstants.spacingSm),
                        Text(
                          'All vouchers have been reviewed',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: UIConstants.paddingLg,
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final voucherWithInfo = vouchers[index];
                      return _buildVoucherCard(
                        context,
                        voucherWithInfo.promotion,
                        voucherWithInfo.vendorId,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildVoucherCard(
    BuildContext context,
    PromotionModel voucher,
    String vendorId,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.borderRadiusMd,
      ),
      child: Padding(
        padding: UIConstants.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voucher Image
            if (voucher.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: UIConstants.borderRadiusSm,
                child: CachedNetworkImage(
                  imageUrl: voucher.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            const SizedBox(height: UIConstants.spacingMd),
            
            // Voucher Title and Type
            Row(
              children: [
                Expanded(
                  child: Text(
                    voucher.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    voucher.getTypeTag(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingSm),
            
            // Description
            Text(
              voucher.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            // Discount Details
            Container(
              padding: UIConstants.paddingSm,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: AppColors.primary, size: 20),
                  const SizedBox(width: UIConstants.spacingSm),
                  Text(
                    voucher.getDisplayText(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            // Date Range
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: UIConstants.spacingSm),
                Text(
                  '${_formatDate(voucher.startDate)} - ${_formatDate(voucher.expiryDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingMd),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AdminVoucherManagementBloc>().add(
                            ApproveVoucher(
                              vendorId: vendorId,
                              voucherId: voucher.id,
                              reason: 'Approved by admin',
                            ),
                          );
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMd),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showRejectDialog(context, voucher, vendorId);
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    PromotionModel voucher,
    String vendorId,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Voucher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this voucher:'),
            const SizedBox(height: UIConstants.spacingMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                context.read<AdminVoucherManagementBloc>().add(
                      RejectVoucher(
                        vendorId: vendorId,
                        voucherId: voucher.id,
                        reason: reasonController.text,
                      ),
                    );
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

