import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/core/di/injection_container.dart';
import 'package:makan_mate/features/admin/presentation/widgets/3d_card.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_vendors_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/approve_vendor_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/reject_vendor_usecase.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_vendor_repository.dart';
import 'package:makan_mate/features/vendor/domain/entities/vendor_profile_entity.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VendorManagementPage extends StatefulWidget {
  const VendorManagementPage({super.key});

  @override
  State<VendorManagementPage> createState() => _VendorManagementPageState();
}

class _VendorManagementPageState extends State<VendorManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    // Navigate to voucher approval page when the Voucher Approvals tab is selected
    if (_tabController.index == 4) {
      Navigator.of(context).pushNamed('/voucherApproval');
      // Reset to previous tab after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _tabController.index == 4) {
          _tabController.animateTo(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                  : [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            const Text('Vendor Management'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
            tooltip: 'Search Vendors',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
            tooltip: 'Filter',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    SizedBox(width: UIConstants.spacingSm),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.grey200,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: Icon(Icons.pending_actions_rounded, size: 20),
                  text: 'Applications',
                ),
                Tab(
                  icon: Icon(Icons.check_circle_rounded, size: 20),
                  text: 'Active',
                ),
                Tab(
                  icon: Icon(Icons.block_rounded, size: 20),
                  text: 'Suspended',
                ),
                Tab(
                  icon: Icon(Icons.warning_rounded, size: 20),
                  text: 'Compliance',
                ),
                Tab(
                  icon: Icon(Icons.card_giftcard_rounded, size: 20),
                  text: 'Voucher Approvals',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _VendorApplicationsTab(),
          const _ActiveVendorsTab(),
          const _SuspendedVendorsTab(),
          const _ComplianceTab(),
          const _VoucherApprovalsTab(),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadiusLg),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: UIConstants.spacingSm),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _VendorApplicationsTab extends StatefulWidget {
  const _VendorApplicationsTab();

  @override
  State<_VendorApplicationsTab> createState() => _VendorApplicationsTabState();
}

class _VendorApplicationsTabState extends State<_VendorApplicationsTab> {
  final GetVendorsUseCase _getVendorsUseCase = sl<GetVendorsUseCase>();
  final ApproveVendorUseCase _approveVendorUseCase = sl<ApproveVendorUseCase>();
  final RejectVendorUseCase _rejectVendorUseCase = sl<RejectVendorUseCase>();

  List<VendorProfileEntity> _vendors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _filterRisk;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getVendorsUseCase.call(
        GetVendorsParams(approvalStatus: 'pending'),
      );
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading vendors: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        (vendors) {
          if (mounted) {
            setState(() {
              _vendors = vendors;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _approveVendor(String vendorId) async {
    try {
      final result = await _approveVendorUseCase.call(
        ApproveVendorParams(vendorId: vendorId),
      );
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error approving vendor: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor approved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadVendors(); // Reload list
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _rejectVendor(String vendorId, String reason) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        final result = await _rejectVendorUseCase.call(
          RejectVendorParams(vendorId: vendorId, reason: reasonController.text),
        );
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error rejecting vendor: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vendor rejected'),
                backgroundColor: AppColors.warning,
              ),
            );
            _loadVendors(); // Reload list
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<VendorProfileEntity> get _filteredVendors {
    var filtered = _vendors;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vendor) {
        final name = vendor.businessName.toLowerCase();
        final email = vendor.emailAddress.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    // Apply risk filter
    if (_filterRisk != null) {
      filtered = filtered.where((vendor) {
        final riskScore = _calculateRiskScore(vendor);
        switch (_filterRisk) {
          case 'low':
            return riskScore < 30;
          case 'medium':
            return riskScore >= 30 && riskScore < 70;
          case 'high':
            return riskScore >= 70;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  int get _pendingCount => _vendors.length;
  int get _lowRiskCount =>
      _vendors.where((v) => _calculateRiskScore(v) < 30).length;
  int get _highRiskCount =>
      _vendors.where((v) => _calculateRiskScore(v) >= 70).length;

  int _calculateRiskScore(VendorProfileEntity vendor) {
    // Simple risk calculation based on available fields
    int score = 0;

    // Check for missing critical fields
    if (vendor.businessAddress.isEmpty) score += 20;
    if (vendor.contactNumber.isEmpty) score += 15;
    if (vendor.emailAddress.isEmpty) score += 10;

    // Check certifications (Halal cert is important)
    final hasHalalCert = vendor.certifications.any(
      (cert) =>
          cert.type.toLowerCase().contains('halal') &&
          cert.status == CertificationStatus.verified,
    );
    if (!hasHalalCert) score += 25;

    // Check if business name is missing
    if (vendor.businessName.isEmpty) score += 30;

    return score;
  }

  List<String> _getRedFlags(VendorProfileEntity vendor) {
    List<String> flags = [];

    if (vendor.businessName.isEmpty) {
      flags.add('Missing business name');
    }

    final hasHalalCert = vendor.certifications.any(
      (cert) =>
          cert.type.toLowerCase().contains('halal') &&
          cert.status == CertificationStatus.verified,
    );
    if (!hasHalalCert) {
      flags.add('No verified Halal certificate');
    }

    if (vendor.businessAddress.isEmpty) {
      flags.add('Missing business address');
    }

    if (vendor.contactNumber.isEmpty) {
      flags.add('Missing contact number');
    }

    return flags;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: UIConstants.paddingMd,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.grey200,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search applications...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF2C2C2C)
                        : AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded),
                ),
                onSelected: (value) {
                  setState(() => _filterRisk = value == 'all' ? null : value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('All Risk Levels'),
                  ),
                  const PopupMenuItem(
                    value: 'low',
                    child: Text('Low Risk (<30)'),
                  ),
                  const PopupMenuItem(
                    value: 'medium',
                    child: Text('Medium Risk (30-70)'),
                  ),
                  const PopupMenuItem(
                    value: 'high',
                    child: Text('High Risk (>70)'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Applications List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredVendors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 64,
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        'No pending applications',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVendors,
                  child: ListView(
                    padding: UIConstants.paddingLg,
                    children: [
                      _buildStatsCards(context),
                      const SizedBox(height: UIConstants.spacingLg),
                      ..._filteredVendors.map(
                        (vendor) => _buildApplicationCard(context, vendor),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Pending',
            '$_pendingCount',
            Icons.pending_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'Low Risk',
            '$_lowRiskCount',
            Icons.check_circle_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'High Risk',
            '$_highRiskCount',
            Icons.warning_rounded,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: UIConstants.paddingMd,
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: UIConstants.spacingSm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColorsExtension.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    VendorProfileEntity vendor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vendorId = vendor.id;
    final name = vendor.businessName;
    final email = vendor.emailAddress;
    final submittedDate = vendor.createdAt;
    final riskScore = _calculateRiskScore(vendor);
    final redFlags = _getRedFlags(vendor);
    final riskColor = riskScore < 30
        ? AppColors.success
        : riskScore < 70
        ? AppColors.warning
        : AppColors.error;

    return Card3D(
      onTap: () {
        // Show detailed vendor view
        _showVendorDetails(context, vendor);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
          border: Border.all(color: riskColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: riskColor.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: UIConstants.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.store_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingSm),
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (vendor.contactNumber.isNotEmpty) ...[
                          const SizedBox(height: UIConstants.spacingXs),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: AppColorsExtension.getTextSecondary(
                                  context,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vendor.contactNumber,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color:
                                            AppColorsExtension.getTextSecondary(
                                              context,
                                            ),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.email_rounded,
                                size: 14,
                                color: AppColorsExtension.getTextSecondary(
                                  context,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vendor.emailAddress,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color:
                                            AppColorsExtension.getTextSecondary(
                                              context,
                                            ),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Submitted ${_formatDate(submittedDate)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColorsExtension.getTextSecondary(
                                      context,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingSm),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            riskColor.withOpacity(0.2),
                            riskColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: riskColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Risk',
                            style: TextStyle(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                              fontSize: UIConstants.fontSizeXs,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$riskScore',
                              style: TextStyle(
                                color: riskColor,
                                fontWeight: FontWeight.bold,
                                fontSize: UIConstants.fontSizeLg,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (redFlags.isNotEmpty) ...[
                const SizedBox(height: UIConstants.spacingMd),
                Container(
                  padding: UIConstants.paddingSm,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Red Flags (${redFlags.length})',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingXs),
                      ...redFlags.map(
                        (flag) => Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 6, right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  flag,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color:
                                            AppColorsExtension.getTextPrimary(
                                              context,
                                            ),
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: UIConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveVendor(vendorId),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingMd),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectVendor(vendorId, ''),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingSm),
                  IconButton(
                    onPressed: () => _showVendorDetails(context, vendor),
                    icon: const Icon(Icons.more_vert_rounded),
                    tooltip: 'More options',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showVendorDetails(BuildContext context, VendorProfileEntity vendor) {
    CertificationEntity? halalCert;
    try {
      halalCert = vendor.certifications.firstWhere(
        (cert) => cert.type.toLowerCase().contains('halal'),
      );
    } catch (e) {
      // No halal cert found
      halalCert = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vendor.businessName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Business Name', vendor.businessName),
              _buildDetailRow('Email', vendor.emailAddress),
              _buildDetailRow('Phone', vendor.contactNumber),
              _buildDetailRow('Address', vendor.businessAddress),
              _buildDetailRow('Description', vendor.shortDescription),
              if (halalCert != null) ...[
                _buildDetailRow(
                  'Halal Cert',
                  halalCert.certificateNumber ?? 'Pending',
                ),
                _buildDetailRow('Cert Status', halalCert.status.name),
              ] else
                _buildDetailRow('Halal Cert', 'Not provided'),
              _buildDetailRow('Approval Status', vendor.approvalStatus),
              _buildDetailRow('Outlets', '${vendor.outlets.length}'),
              _buildDetailRow(
                'Certifications',
                '${vendor.certifications.length}',
              ),
              _buildDetailRow('Submitted', _formatDate(vendor.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ActiveVendorsTab extends StatefulWidget {
  const _ActiveVendorsTab();

  @override
  State<_ActiveVendorsTab> createState() => _ActiveVendorsTabState();
}

class _ActiveVendorsTabState extends State<_ActiveVendorsTab> {
  final GetVendorsUseCase _getVendorsUseCase = sl<GetVendorsUseCase>();
  final AdminVendorRepository _vendorRepository = sl<AdminVendorRepository>();

  List<VendorProfileEntity> _vendors = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getVendorsUseCase.call(
        GetVendorsParams(approvalStatus: 'approved'),
      );
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading vendors: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() => _isLoading = false);
          }
        },
        (vendors) {
          if (mounted) {
            setState(() {
              _vendors = vendors;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _suspendVendor(String vendorId, String reason) async {
    try {
      final result = await _vendorRepository.suspendVendor(
        vendorId: vendorId,
        reason: reason,
      );
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error suspending vendor: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor suspended successfully'),
              backgroundColor: AppColors.warning,
            ),
          );
          _loadVendors(); // Reload list
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deactivateVendor(String vendorId, String reason) async {
    try {
      final result = await _vendorRepository.deactivateVendor(
        vendorId: vendorId,
        reason: reason,
      );
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deactivating vendor: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor deactivated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadVendors(); // Reload list
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  List<VendorProfileEntity> get _filteredVendors {
    if (_searchQuery.isEmpty) return _vendors;

    return _vendors.where((vendor) {
      final name = vendor.businessName.toLowerCase();
      final email = vendor.emailAddress.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar
        Container(
          padding: UIConstants.paddingMd,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.grey200,
              ),
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search active vendors...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2C) : AppColors.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        // Vendors List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredVendors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_rounded,
                        size: 64,
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        'No active vendors',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVendors,
                  child: ListView(
                    padding: UIConstants.paddingLg,
                    children: [
                      _buildStatsCard(context),
                      const SizedBox(height: UIConstants.spacingLg),
                      ..._filteredVendors.map(
                        (vendor) => _buildVendorCard(context, vendor),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.store_rounded, color: AppColors.primary, size: 32),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Vendors',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_vendors.length} vendors',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, VendorProfileEntity vendor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card3D(
      onTap: () {
        _showVendorDetails(context, vendor);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: UIConstants.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Image
                  ClipRRect(
                    borderRadius: UIConstants.borderRadiusMd,
                    child: vendor.businessLogoUrl != null
                        ? Image.network(
                            vendor.businessLogoUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: AppColors.grey200,
                              child: const Icon(Icons.store_rounded),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: AppColors.grey200,
                            child: const Icon(Icons.store_rounded),
                          ),
                  ),
                  const SizedBox(width: UIConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.businessName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vendor.emailAddress,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColorsExtension.getTextSecondary(
                                  context,
                                ),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vendor.businessAddress,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color:
                                          AppColorsExtension.getTextSecondary(
                                            context,
                                          ),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMd),
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.star_rounded,
                      vendor.ratingAverage?.toStringAsFixed(1) ?? 'N/A',
                      'Rating',
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.storefront_rounded,
                      '${vendor.outlets.length}',
                      'Outlets',
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.restaurant_menu_rounded,
                      '${vendor.menuItems.length}',
                      'Menu Items',
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
                      onPressed: () => _showSuspendDialog(context, vendor),
                      icon: const Icon(
                        Icons.pause_circle_outline_rounded,
                        size: 18,
                      ),
                      label: const Text('Suspend'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingMd),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeactivateDialog(context, vendor),
                      icon: const Icon(Icons.block_rounded, size: 18),
                      label: const Text('Deactivate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColorsExtension.getTextSecondary(context),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColorsExtension.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  void _showSuspendDialog(BuildContext context, VendorProfileEntity vendor) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Suspend Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Suspend ${vendor.businessName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for suspension...',
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
                _suspendVendor(vendor.id, reasonController.text);
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, VendorProfileEntity vendor) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deactivate ${vendor.businessName}? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for deactivation...',
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
                _deactivateVendor(vendor.id, reasonController.text);
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showVendorDetails(BuildContext context, VendorProfileEntity vendor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vendor.businessName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', vendor.emailAddress),
              _buildDetailRow('Phone', vendor.contactNumber),
              _buildDetailRow('Address', vendor.businessAddress),
              _buildDetailRow('Cuisine', vendor.cuisineType ?? 'N/A'),
              _buildDetailRow(
                'Rating',
                vendor.ratingAverage?.toStringAsFixed(1) ?? 'N/A',
              ),
              _buildDetailRow('Outlets', '${vendor.outlets.length}'),
              _buildDetailRow('Menu Items', '${vendor.menuItems.length}'),
              _buildDetailRow(
                'Certifications',
                '${vendor.certifications.length}',
              ),
              _buildDetailRow('Approved', _formatDate(vendor.updatedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SuspendedVendorsTab extends StatelessWidget {
  const _SuspendedVendorsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Suspended Vendors'));
  }
}

class _ComplianceTab extends StatelessWidget {
  const _ComplianceTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Compliance Alerts'));
  }
}

class _VoucherApprovalsTab extends StatelessWidget {
  const _VoucherApprovalsTab();

  @override
  Widget build(BuildContext context) {
    // This tab navigates to the voucher approval page
    // The navigation is handled by the TabController listener in the parent widget
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: UIConstants.spacingMd),
          Text('Loading voucher approvals...'),
        ],
      ),
    );
  }
}
