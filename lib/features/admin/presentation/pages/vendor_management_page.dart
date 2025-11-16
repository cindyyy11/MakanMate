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

// Predefined suspension reasons
class SuspensionReasons {
  static const List<String> reasons = [
    'Violation of Terms of Service',
    'Health and Safety Violations',
    'Food Quality Issues',
    'Hygiene Concerns',
    'Customer Complaints',
    'Payment Issues',
    'Documentation Incomplete',
    'Operating Without License',
    'Fraudulent Activity',
    'Non-compliance with Regulations',
    'Other',
  ];
}

// Predefined deactivation reasons
class DeactivationReasons {
  static const List<String> reasons = [
    'Business Closure',
    'Repeated Violations',
    'Serious Health Violations',
    'Legal Issues',
    'Requested by Vendor',
    'Non-payment of Fees',
    'License Revoked',
    'Fraudulent Activity',
    'Permanent Ban',
    'Other',
  ];
}

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
    _tabController = TabController(length: 6, vsync: this);
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
    if (_tabController.index == 5) {
      Navigator.of(context).pushNamed('/voucherApproval');
      // Reset to previous tab after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _tabController.index == 5) {
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
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              'Vendor Management',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
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
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.pending_actions_rounded, size: 20),
                  text: 'Applications',
                ),
                Tab(
                  icon: Icon(Icons.check_circle_rounded, size: 20),
                  text: 'Active',
                ),
                Tab(
                  icon: Icon(Icons.pause_circle_rounded, size: 20),
                  text: 'Suspended',
                ),
                Tab(
                  icon: Icon(Icons.cancel_rounded, size: 20),
                  text: 'Deactivated',
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
          const _DeactivatedVendorsTab(),
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
  final TextEditingController _searchController = TextEditingController();

  // Filter state for Applications tab
  String? _filterRisk;
  String? _selectedCuisineType;
  DateTime? _submittedFromDate;
  DateTime? _submittedToDate;
  bool? _hasCertifications; // null = all, true = has certs, false = no certs
  bool? _hasMenuItems; // null = all, true = has items, false = no items
  int? _minOutlets;
  bool _hasActiveFilters = false;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _filterRisk != null ||
          _selectedCuisineType != null ||
          _submittedFromDate != null ||
          _submittedToDate != null ||
          _hasCertifications != null ||
          _hasMenuItems != null ||
          _minOutlets != null ||
          _searchQuery.isNotEmpty;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterRisk = null;
      _selectedCuisineType = null;
      _submittedFromDate = null;
      _submittedToDate = null;
      _hasCertifications = null;
      _hasMenuItems = null;
      _minOutlets = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  List<String> get _availableCuisineTypes {
    final cuisines = _vendors
        .map((v) => v.cuisineType)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .toList();
    cuisines.sort();
    return cuisines.cast<String>();
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
    return _vendors.where((vendor) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = vendor.businessName.toLowerCase();
        final email = vendor.emailAddress.toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !email.contains(query)) {
          return false;
        }
      }

      // Risk filter
      if (_filterRisk != null) {
        final riskScore = _calculateRiskScore(vendor);
        switch (_filterRisk) {
          case 'low':
            if (riskScore >= 30) return false;
            break;
          case 'medium':
            if (riskScore < 30 || riskScore >= 70) return false;
            break;
          case 'high':
            if (riskScore < 70) return false;
            break;
        }
      }

      // Cuisine type filter
      if (_selectedCuisineType != null && _selectedCuisineType!.isNotEmpty) {
        final vendorCuisine = vendor.cuisineType?.toLowerCase() ?? '';
        if (vendorCuisine != _selectedCuisineType!.toLowerCase()) {
          return false;
        }
      }

      // Submitted date range filter
      if (_submittedFromDate != null &&
          vendor.createdAt.isBefore(_submittedFromDate!)) {
        return false;
      }
      if (_submittedToDate != null &&
          vendor.createdAt.isAfter(
            _submittedToDate!.add(const Duration(days: 1)),
          )) {
        return false;
      }

      // Certifications filter
      if (_hasCertifications != null) {
        if (_hasCertifications! && vendor.certifications.isEmpty) {
          return false;
        }
        if (!_hasCertifications! && vendor.certifications.isNotEmpty) {
          return false;
        }
      }

      // Menu items filter
      if (_hasMenuItems != null) {
        if (_hasMenuItems! && vendor.menuItems.isEmpty) {
          return false;
        }
        if (!_hasMenuItems! && vendor.menuItems.isNotEmpty) {
          return false;
        }
      }

      // Minimum outlets filter
      if (_minOutlets != null) {
        if (vendor.outlets.length < _minOutlets!) {
          return false;
        }
      }

      return true;
    }).toList();
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
                  controller: _searchController,
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
                    setState(() {
                      _searchQuery = value;
                      _updateFilterState();
                    });
                  },
                ),
              ),
              const SizedBox(width: UIConstants.spacingSm),
              IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: _hasActiveFilters
                          ? AppColors.primary
                          : AppColorsExtension.getTextSecondary(context),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'Filter applications',
              ),
              if (_hasActiveFilters)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearFilters,
                  tooltip: 'Clear filters',
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
                        _hasActiveFilters || _searchQuery.isNotEmpty
                            ? Icons.filter_alt_off_rounded
                            : Icons.inbox_rounded,
                        size: 64,
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        _hasActiveFilters || _searchQuery.isNotEmpty
                            ? 'No applications match your filters'
                            : 'No pending applications',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                      ),
                      if (_hasActiveFilters || _searchQuery.isNotEmpty) ...[
                        const SizedBox(height: UIConstants.spacingSm),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear_rounded),
                          label: const Text('Clear filters'),
                        ),
                      ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                            Flexible(
                              child: Text(
                                'Submitted ${_formatDate(submittedDate)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColorsExtension.getTextSecondary(
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
                  const SizedBox(width: UIConstants.spacingSm),
                  Container(
                    constraints: const BoxConstraints(minWidth: 70, maxWidth: 90),
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(width: UIConstants.spacingXs),
                  IconButton(
                    onPressed: () => _showVendorDetails(context, vendor),
                    icon: const Icon(Icons.more_vert_rounded),
                    tooltip: 'More options',
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? tempFilterRisk = _filterRisk;
    String? tempCuisineType = _selectedCuisineType;
    DateTime? tempSubmittedFromDate = _submittedFromDate;
    DateTime? tempSubmittedToDate = _submittedToDate;
    bool? tempHasCertifications = _hasCertifications;
    bool? tempHasMenuItems = _hasMenuItems;
    int? tempMinOutlets = _minOutlets;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Applications'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Risk Level Filter
                Text(
                  'Risk Level',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempFilterRisk,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select risk level',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Risk Levels'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'low',
                      child: Text('Low Risk (<30)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'medium',
                      child: Text('Medium Risk (30-70)'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'high',
                      child: Text('High Risk (≥70)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempFilterRisk = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Cuisine Type Filter
                if (_availableCuisineTypes.isNotEmpty) ...[
                  Text(
                    'Cuisine Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempCuisineType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Select cuisine type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Cuisines'),
                      ),
                      ..._availableCuisineTypes.map(
                        (cuisine) => DropdownMenuItem<String>(
                          value: cuisine,
                          child: Text(cuisine),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempCuisineType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Submitted Date Range
                Text(
                  'Submitted Date Range',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                tempSubmittedFromDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              tempSubmittedFromDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tempSubmittedFromDate != null
                                      ? '${tempSubmittedFromDate!.day}/${tempSubmittedFromDate!.month}/${tempSubmittedFromDate!.year}'
                                      : 'From date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempSubmittedToDate ?? DateTime.now(),
                            firstDate: tempSubmittedFromDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              tempSubmittedToDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tempSubmittedToDate != null
                                      ? '${tempSubmittedToDate!.day}/${tempSubmittedToDate!.month}/${tempSubmittedToDate!.year}'
                                      : 'To date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Certifications Filter
                Text(
                  'Certifications',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<bool>(
                  value: tempHasCertifications,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select option',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<bool>(value: null, child: Text('All')),
                    DropdownMenuItem<bool>(
                      value: true,
                      child: Text('Has Certifications'),
                    ),
                    DropdownMenuItem<bool>(
                      value: false,
                      child: Text('No Certifications'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempHasCertifications = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Menu Items Filter
                Text(
                  'Menu Items',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<bool>(
                  value: tempHasMenuItems,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select option',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<bool>(value: null, child: Text('All')),
                    DropdownMenuItem<bool>(
                      value: true,
                      child: Text('Has Menu Items'),
                    ),
                    DropdownMenuItem<bool>(
                      value: false,
                      child: Text('No Menu Items'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempHasMenuItems = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Minimum Outlets Filter
                Text(
                  'Minimum Outlets',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempMinOutlets?.toDouble() ?? 0.0,
                        min: 0.0,
                        max: 10.0,
                        divisions: 10,
                        label: tempMinOutlets != null
                            ? tempMinOutlets.toString()
                            : 'None',
                        onChanged: (value) {
                          setState(() {
                            tempMinOutlets = value > 0 ? value.toInt() : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        tempMinOutlets != null
                            ? tempMinOutlets.toString()
                            : 'None',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempFilterRisk = null;
                  tempCuisineType = null;
                  tempSubmittedFromDate = null;
                  tempSubmittedToDate = null;
                  tempHasCertifications = null;
                  tempHasMenuItems = null;
                  tempMinOutlets = null;
                });
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterRisk = tempFilterRisk;
                  _selectedCuisineType = tempCuisineType;
                  _submittedFromDate = tempSubmittedFromDate;
                  _submittedToDate = tempSubmittedToDate;
                  _hasCertifications = tempHasCertifications;
                  _hasMenuItems = tempHasMenuItems;
                  _minOutlets = tempMinOutlets;
                  _updateFilterState();
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Apply'),
            ),
          ],
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
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _selectedCuisineType;
  double? _minRating;
  int? _minOutlets;
  bool _hasActiveFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  Future<void> _suspendVendor(
    String vendorId,
    String reason,
    DateTime? suspendUntil,
  ) async {
    try {
      final result = await _vendorRepository.suspendVendor(
        vendorId: vendorId,
        reason: reason,
        suspendUntil: suspendUntil,
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
          // Build suspension details message
          String suspensionMessage;
          if (suspendUntil == null) {
            suspensionMessage =
                'Vendor suspended indefinitely. Manual reactivation required.';
          } else {
            final now = DateTime.now();
            final duration = suspendUntil.difference(now);
            final durationText = _formatDuration(duration);
            final reactivationDate = _formatDateTime(suspendUntil);

            suspensionMessage =
                'Vendor suspended for $durationText.\n'
                'Auto-reactivation: $reactivationDate';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(suspensionMessage),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 5),
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
    return _vendors.where((vendor) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = vendor.businessName.toLowerCase();
        final email = vendor.emailAddress.toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !email.contains(query)) {
          return false;
        }
      }

      // Cuisine type filter
      if (_selectedCuisineType != null && _selectedCuisineType!.isNotEmpty) {
        final vendorCuisine = vendor.cuisineType?.toLowerCase() ?? '';
        if (vendorCuisine != _selectedCuisineType!.toLowerCase()) {
          return false;
        }
      }

      // Rating filter
      if (_minRating != null) {
        if (vendor.ratingAverage == null ||
            vendor.ratingAverage! < _minRating!) {
          return false;
        }
      }

      // Outlets filter
      if (_minOutlets != null) {
        if (vendor.outlets.length < _minOutlets!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _selectedCuisineType != null ||
          _minRating != null ||
          _minOutlets != null;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCuisineType = null;
      _minRating = null;
      _minOutlets = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  List<String> get _availableCuisineTypes {
    final cuisines = _vendors
        .map((v) => v.cuisineType)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .toList();
    cuisines.sort();
    return cuisines.cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar and Filter
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search active vendors...',
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
              const SizedBox(width: UIConstants.spacingSm),
              IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: _hasActiveFilters
                          ? AppColors.primary
                          : AppColorsExtension.getTextSecondary(context),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'Filter vendors',
              ),
              if (_hasActiveFilters)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearFilters,
                  tooltip: 'Clear filters',
                ),
            ],
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
                        _hasActiveFilters || _searchQuery.isNotEmpty
                            ? Icons.filter_alt_off_rounded
                            : Icons.store_rounded,
                        size: 64,
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        _hasActiveFilters || _searchQuery.isNotEmpty
                            ? 'No vendors match your filters'
                            : 'No active vendors',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                      ),
                      if (_hasActiveFilters || _searchQuery.isNotEmpty) ...[
                        const SizedBox(height: UIConstants.spacingSm),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear_rounded),
                          label: const Text('Clear filters'),
                        ),
                      ],
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
                  _hasActiveFilters || _searchQuery.isNotEmpty
                      ? '${_filteredVendors.length} of ${_vendors.length} vendors'
                      : '${_vendors.length} vendors',
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

  String _getTimeUntilReactivation(DateTime suspendUntil) {
    final now = DateTime.now();
    if (suspendUntil.isBefore(now)) {
      return 'Reactivation time has passed';
    }
    final difference = suspendUntil.difference(now);
    if (difference.inDays > 0) {
      return 'Auto-reactivates in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Auto-reactivates in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Auto-reactivates in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '$days day${days > 1 ? 's' : ''} and $hours hour${hours > 1 ? 's' : ''}';
      }
      return '$days day${days > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '$hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''}';
      }
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final minutes = duration.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute';
  }

  void _showSuspendDialog(BuildContext context, VendorProfileEntity vendor) {
    String? selectedReason;
    final additionalNotesController = TextEditingController();
    DateTime? suspendUntil;
    bool suspendForever = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Suspend Vendor'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suspend ${vendor.businessName}?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  // Reason Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Suspension Reason *',
                      hintText: 'Select a reason',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: SuspensionReasons.reasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return SuspensionReasons.reasons.map((reason) {
                        return Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        );
                      }).toList();
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  // Additional notes if "Other" is selected
                  if (selectedReason == 'Other') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: additionalNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Details *',
                        hintText: 'Please provide more details...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Suspension Type Section with Clear Visual Cards
                  Text(
                    'Suspension Duration',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Forever Option Card
                  InkWell(
                    onTap: () {
                      setState(() {
                        suspendForever = true;
                        suspendUntil = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: suspendForever
                            ? AppColors.warning.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: suspendForever
                              ? AppColors.warning
                              : AppColors.grey300,
                          width: suspendForever ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: suspendForever,
                            onChanged: (value) {
                              setState(() {
                                suspendForever = value ?? true;
                                if (suspendForever) {
                                  suspendUntil = null;
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.block_rounded,
                                      size: 18,
                                      color: suspendForever
                                          ? AppColors.warning
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Suspend Forever',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: suspendForever
                                        ? AppColors.warning.withOpacity(0.1)
                                        : AppColors.grey100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 16,
                                        color: suspendForever
                                            ? AppColors.warning
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'The vendor will remain suspended indefinitely. Manual reactivation by an admin is required.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: suspendForever
                                                    ? AppColors.warning
                                                    : AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Temporary Option Card
                  InkWell(
                    onTap: () {
                      setState(() {
                        suspendForever = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !suspendForever
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: !suspendForever
                              ? AppColors.primary
                              : AppColors.grey300,
                          width: !suspendForever ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: !suspendForever,
                            onChanged: (value) {
                              setState(() {
                                suspendForever = !(value ?? false);
                                if (suspendForever) {
                                  suspendUntil = null;
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 18,
                                      color: !suspendForever
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Suspend Temporarily',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: !suspendForever
                                        ? AppColors.primary.withOpacity(0.1)
                                        : AppColors.grey100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.autorenew_rounded,
                                        size: 16,
                                        color: !suspendForever
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'The vendor will be automatically reactivated when the selected date/time passes. No manual action required.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: !suspendForever
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Date/Time Picker for Temporary Suspension
                  if (!suspendForever) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Select Reactivation Date & Time',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 7),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            final selectedDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                            // Ensure the selected time is in the future
                            if (selectedDateTime.isAfter(DateTime.now())) {
                              setState(() {
                                suspendUntil = selectedDateTime;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select a future date and time',
                                  ),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: suspendUntil != null
                              ? AppColors.primary.withOpacity(0.05)
                              : AppColors.grey100,
                          border: Border.all(
                            color: suspendUntil != null
                                ? AppColors.primary
                                : AppColors.grey300,
                            width: suspendUntil != null ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: suspendUntil != null
                                    ? AppColors.primary
                                    : AppColors.grey300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: suspendUntil != null
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suspendUntil != null
                                        ? '${suspendUntil!.day}/${suspendUntil!.month}/${suspendUntil!.year} ${suspendUntil!.hour}:${suspendUntil!.minute.toString().padLeft(2, '0')}'
                                        : 'Select date and time',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: suspendUntil != null
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (suspendUntil != null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.autorenew_rounded,
                                            size: 12,
                                            color: AppColors.success,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              _getTimeUntilReactivation(
                                                suspendUntil!,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.success,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedReason != null &&
                    selectedReason!.isNotEmpty &&
                    (selectedReason != 'Other' ||
                        additionalNotesController.text.isNotEmpty)) {
                  final finalReason = selectedReason == 'Other'
                      ? 'Other: ${additionalNotesController.text}'
                      : selectedReason!;
                  _suspendVendor(
                    vendor.id,
                    finalReason,
                    suspendForever ? null : suspendUntil,
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: const Text('Suspend'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, VendorProfileEntity vendor) {
    String? selectedReason;
    final additionalNotesController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Deactivate Vendor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deactivate ${vendor.businessName}? This action cannot be undone.',
                ),
                const SizedBox(height: 16),
                // Reason Dropdown
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Deactivation Reason *',
                    hintText: 'Select a reason',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: DeactivationReasons.reasons.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(
                        reason,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) {
                    return DeactivationReasons.reasons.map((reason) {
                      return Text(
                        reason,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 14),
                      );
                    }).toList();
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
                // Additional notes if "Other" is selected
                if (selectedReason == 'Other') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: additionalNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Details *',
                      hintText: 'Please provide more details...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedReason != null &&
                    selectedReason!.isNotEmpty &&
                    (selectedReason != 'Other' ||
                        additionalNotesController.text.isNotEmpty)) {
                  final finalReason = selectedReason == 'Other'
                      ? 'Other: ${additionalNotesController.text}'
                      : selectedReason!;
                  _deactivateVendor(vendor.id, finalReason);
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Deactivate'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? tempCuisineType = _selectedCuisineType;
    double? tempMinRating = _minRating;
    int? tempMinOutlets = _minOutlets;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Vendors'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cuisine Type Filter
                Text(
                  'Cuisine Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempCuisineType,
                  decoration: const InputDecoration(
                    hintText: 'Select cuisine type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Cuisines'),
                    ),
                    ..._availableCuisineTypes.map(
                      (cuisine) => DropdownMenuItem<String>(
                        value: cuisine,
                        child: Text(cuisine),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempCuisineType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Rating Filter
                Text(
                  'Minimum Rating',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempMinRating ?? 0.0,
                        min: 0.0,
                        max: 5.0,
                        divisions: 10,
                        label: tempMinRating != null
                            ? tempMinRating!.toStringAsFixed(1)
                            : 'None',
                        onChanged: (value) {
                          setState(() {
                            tempMinRating = value > 0 ? value : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        tempMinRating != null
                            ? tempMinRating!.toStringAsFixed(1)
                            : 'None',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Outlets Filter
                Text(
                  'Minimum Outlets',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempMinOutlets?.toDouble() ?? 0.0,
                        min: 0.0,
                        max: 10.0,
                        divisions: 10,
                        label: tempMinOutlets != null
                            ? tempMinOutlets.toString()
                            : 'None',
                        onChanged: (value) {
                          setState(() {
                            tempMinOutlets = value > 0 ? value.toInt() : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        tempMinOutlets != null
                            ? tempMinOutlets.toString()
                            : 'None',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempCuisineType = null;
                  tempMinRating = null;
                  tempMinOutlets = null;
                });
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCuisineType = tempCuisineType;
                  _minRating = tempMinRating;
                  _minOutlets = tempMinOutlets;
                  _updateFilterState();
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
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

class _SuspendedVendorsTab extends StatefulWidget {
  const _SuspendedVendorsTab();

  @override
  State<_SuspendedVendorsTab> createState() => _SuspendedVendorsTabState();
}

class _SuspendedVendorsTabState extends State<_SuspendedVendorsTab> {
  final GetVendorsUseCase _getVendorsUseCase = sl<GetVendorsUseCase>();
  final AdminVendorRepository _vendorRepository = sl<AdminVendorRepository>();

  List<VendorProfileEntity> _vendors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter state for Suspended tab
  String? _suspensionType; // 'forever' or 'temporary'
  DateTime? _suspendedFromDate;
  DateTime? _suspendedToDate;
  int? _minDaysSuspended;
  String? _selectedSuspensionReason;
  bool _hasActiveFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _suspensionType != null ||
          _suspendedFromDate != null ||
          _suspendedToDate != null ||
          _minDaysSuspended != null ||
          _selectedSuspensionReason != null ||
          _searchQuery.isNotEmpty;
    });
  }

  void _clearFilters() {
    setState(() {
      _suspensionType = null;
      _suspendedFromDate = null;
      _suspendedToDate = null;
      _minDaysSuspended = null;
      _selectedSuspensionReason = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  // Use predefined reasons for filtering
  List<String> get _availableSuspensionReasons => SuspensionReasons.reasons;

  int _getDaysSuspended(VendorProfileEntity vendor) {
    if (vendor.suspendedAt == null) return 0;
    return DateTime.now().difference(vendor.suspendedAt!).inDays;
  }

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getVendorsUseCase.call(
        GetVendorsParams(approvalStatus: 'suspended'),
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

  Future<void> _reactivateVendor(String vendorId) async {
    try {
      final result = await _vendorRepository.activateVendor(
        vendorId: vendorId,
        reason: 'Vendor reactivated by admin',
      );
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error reactivating vendor: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor reactivated successfully'),
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
    return _vendors.where((vendor) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = vendor.businessName.toLowerCase();
        final email = vendor.emailAddress.toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !email.contains(query)) {
          return false;
        }
      }

      // Suspension type filter (forever vs temporary)
      if (_suspensionType != null) {
        if (_suspensionType == 'forever' && vendor.suspendedUntil != null) {
          return false; // Should be forever but has suspendedUntil
        }
        if (_suspensionType == 'temporary' && vendor.suspendedUntil == null) {
          return false; // Should be temporary but no suspendedUntil
        }
      }

      // Suspended date range filter
      if (vendor.suspendedAt != null) {
        if (_suspendedFromDate != null &&
            vendor.suspendedAt!.isBefore(_suspendedFromDate!)) {
          return false;
        }
        if (_suspendedToDate != null &&
            vendor.suspendedAt!.isAfter(
              _suspendedToDate!.add(const Duration(days: 1)),
            )) {
          return false;
        }
      } else if (_suspendedFromDate != null || _suspendedToDate != null) {
        return false; // No suspendedAt date but filter requires it
      }

      // Days suspended filter
      if (_minDaysSuspended != null) {
        final daysSuspended = _getDaysSuspended(vendor);
        if (daysSuspended < _minDaysSuspended!) {
          return false;
        }
      }

      // Suspension reason filter
      if (_selectedSuspensionReason != null &&
          _selectedSuspensionReason!.isNotEmpty) {
        final vendorReason = vendor.suspensionReason?.toLowerCase() ?? '';
        final selectedReasonLower = _selectedSuspensionReason!.toLowerCase();

        // Handle "Other" reason - check if reason starts with "other:"
        if (selectedReasonLower == 'other') {
          if (!vendorReason.startsWith('other:')) {
            return false;
          }
        } else {
          // Exact match for predefined reasons
          if (vendorReason != selectedReasonLower) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar and Filter
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search suspended vendors...',
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
                    setState(() {
                      _searchQuery = value;
                      _updateFilterState();
                    });
                  },
                ),
              ),
              const SizedBox(width: UIConstants.spacingSm),
              IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: _hasActiveFilters
                          ? AppColors.primary
                          : AppColorsExtension.getTextSecondary(context),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'Filter vendors',
              ),
              if (_hasActiveFilters)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearFilters,
                  tooltip: 'Clear filters',
                ),
            ],
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
                        Icons.pause_circle_outline_rounded,
                        size: 64,
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        _hasActiveFilters || _searchQuery.isNotEmpty
                            ? 'No vendors match your filters'
                            : 'No suspended vendors',
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
          Icon(Icons.pause_circle_rounded, color: AppColors.warning, size: 32),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suspended Vendors',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _searchQuery.isNotEmpty
                      ? '${_filteredVendors.length} of ${_vendors.length} vendors'
                      : '${_vendors.length} vendors',
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
    final now = DateTime.now();
    final suspendedAt = vendor.suspendedAt;
    final suspendedUntil = vendor.suspendedUntil;

    // Calculate suspension duration and reactivation info
    String? suspensionDurationText;
    String? reactivationInfo;
    bool isForever = suspendedUntil == null;

    if (suspendedAt != null) {
      if (isForever) {
        final daysSuspended = now.difference(suspendedAt).inDays;
        suspensionDurationText =
            'Suspended for $daysSuspended day${daysSuspended != 1 ? 's' : ''} (Indefinite)';
        reactivationInfo = 'Manual reactivation required';
      } else {
        final duration = suspendedUntil.difference(suspendedAt);
        final durationText = _formatDuration(duration);
        suspensionDurationText = 'Suspended for $durationText';

        if (suspendedUntil.isAfter(now)) {
          final timeUntil = suspendedUntil.difference(now);
          final timeUntilText = _formatDuration(timeUntil);
          reactivationInfo =
              'Auto-reactivates in $timeUntilText\n(${_formatDateTime(suspendedUntil)})';
        } else {
          reactivationInfo = 'Reactivation time has passed';
        }
      }
    }

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
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Suspended',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // Suspension Details
              if (suspensionDurationText != null ||
                  reactivationInfo != null) ...[
                const SizedBox(height: UIConstants.spacingMd),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isForever
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isForever
                          ? AppColors.warning.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (suspensionDurationText != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: isForever
                                  ? AppColors.warning
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suspensionDurationText,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isForever
                                          ? AppColors.warning
                                          : AppColors.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      if (reactivationInfo != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isForever
                                  ? Icons.block_rounded
                                  : Icons.autorenew_rounded,
                              size: 16,
                              color: isForever
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reactivationInfo,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isForever
                                          ? AppColors.warning
                                          : AppColors.success,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: UIConstants.spacingMd),
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReactivateDialog(context, vendor),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                  label: const Text('Reactivate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '$days day${days > 1 ? 's' : ''} and $hours hour${hours > 1 ? 's' : ''}';
      }
      return '$days day${days > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '$hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''}';
      }
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final minutes = duration.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute';
  }

  void _showFilterDialog(BuildContext context) {
    String? tempSuspensionType = _suspensionType;
    DateTime? tempSuspendedFromDate = _suspendedFromDate;
    DateTime? tempSuspendedToDate = _suspendedToDate;
    int? tempMinDaysSuspended = _minDaysSuspended;
    String? tempSelectedReason = _selectedSuspensionReason;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Suspended Vendors'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suspension Type Filter
                Text(
                  'Suspension Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempSuspensionType,
                  decoration: const InputDecoration(
                    hintText: 'Select suspension type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'forever',
                      child: Text('Suspended Forever'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'temporary',
                      child: Text('Temporary Suspension'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempSuspensionType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Suspended Date Range
                Text(
                  'Suspended Date Range',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                tempSuspendedFromDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              tempSuspendedFromDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tempSuspendedFromDate != null
                                      ? '${tempSuspendedFromDate!.day}/${tempSuspendedFromDate!.month}/${tempSuspendedFromDate!.year}'
                                      : 'From date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempSuspendedToDate ?? DateTime.now(),
                            firstDate: tempSuspendedFromDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              tempSuspendedToDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tempSuspendedToDate != null
                                      ? '${tempSuspendedToDate!.day}/${tempSuspendedToDate!.month}/${tempSuspendedToDate!.year}'
                                      : 'To date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Days Suspended Filter
                Text(
                  'Minimum Days Suspended',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempMinDaysSuspended?.toDouble() ?? 0.0,
                        min: 0.0,
                        max: 365.0,
                        divisions: 73,
                        label: tempMinDaysSuspended != null
                            ? tempMinDaysSuspended.toString()
                            : 'None',
                        onChanged: (value) {
                          setState(() {
                            tempMinDaysSuspended = value > 0
                                ? value.toInt()
                                : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        tempMinDaysSuspended != null
                            ? tempMinDaysSuspended.toString()
                            : 'None',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Suspension Reason Filter
                Text(
                  'Suspension Reason',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempSelectedReason,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select reason',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'All Reasons',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    ..._availableSuspensionReasons.map(
                      (reason) => DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                  selectedItemBuilder: (context) {
                    return [
                      const Text(
                        'All Reasons',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      ..._availableSuspensionReasons.map(
                        (reason) => Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ];
                  },
                  onChanged: (value) {
                    setState(() {
                      tempSelectedReason = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempSuspensionType = null;
                  tempSuspendedFromDate = null;
                  tempSuspendedToDate = null;
                  tempMinDaysSuspended = null;
                  tempSelectedReason = null;
                });
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _suspensionType = tempSuspensionType;
                  _suspendedFromDate = tempSuspendedFromDate;
                  _suspendedToDate = tempSuspendedToDate;
                  _minDaysSuspended = tempMinDaysSuspended;
                  _selectedSuspensionReason = tempSelectedReason;
                  _updateFilterState();
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactivateDialog(BuildContext context, VendorProfileEntity vendor) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reactivate Vendor'),
        content: Text(
          'Are you sure you want to reactivate ${vendor.businessName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _reactivateVendor(vendor.id);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Reactivate'),
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
              _buildDetailRow('Contact', vendor.contactNumber),
              _buildDetailRow('Address', vendor.businessAddress),
              if (vendor.cuisineType != null)
                _buildDetailRow('Cuisine', vendor.cuisineType!),
              if (vendor.ratingAverage != null)
                _buildDetailRow(
                  'Rating',
                  vendor.ratingAverage!.toStringAsFixed(1),
                ),
              _buildDetailRow('Outlets', '${vendor.outlets.length}'),
              _buildDetailRow('Menu Items', '${vendor.menuItems.length}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

class _DeactivatedVendorsTab extends StatefulWidget {
  const _DeactivatedVendorsTab();

  @override
  State<_DeactivatedVendorsTab> createState() => _DeactivatedVendorsTabState();
}

class _DeactivatedVendorsTabState extends State<_DeactivatedVendorsTab> {
  final GetVendorsUseCase _getVendorsUseCase = sl<GetVendorsUseCase>();
  final AdminVendorRepository _vendorRepository = sl<AdminVendorRepository>();

  List<VendorProfileEntity> _vendors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter state for Deactivated tab
  DateTime? _deactivatedFromDate;
  DateTime? _deactivatedToDate;
  int? _minDaysDeactivated;
  String? _selectedDeactivationReason;
  bool _hasActiveFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _deactivatedFromDate != null ||
          _deactivatedToDate != null ||
          _minDaysDeactivated != null ||
          _selectedDeactivationReason != null ||
          _searchQuery.isNotEmpty;
    });
  }

  void _clearFilters() {
    setState(() {
      _deactivatedFromDate = null;
      _deactivatedToDate = null;
      _minDaysDeactivated = null;
      _selectedDeactivationReason = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  // Use predefined reasons for filtering
  List<String> get _availableDeactivationReasons => DeactivationReasons.reasons;

  int _getDaysDeactivated(VendorProfileEntity vendor) {
    if (vendor.deactivatedAt == null) return 0;
    return DateTime.now().difference(vendor.deactivatedAt!).inDays;
  }

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getVendorsUseCase.call(
        GetVendorsParams(approvalStatus: 'deactivate'),
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

  Future<void> _reactivateVendor(String vendorId) async {
    try {
      final result = await _vendorRepository.activateVendor(
        vendorId: vendorId,
        reason: 'Vendor reactivated by admin',
      );
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error reactivating vendor: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor reactivated successfully'),
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
    return _vendors.where((vendor) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = vendor.businessName.toLowerCase();
        final email = vendor.emailAddress.toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !email.contains(query)) {
          return false;
        }
      }

      // Deactivated date range filter
      if (vendor.deactivatedAt != null) {
        if (_deactivatedFromDate != null &&
            vendor.deactivatedAt!.isBefore(_deactivatedFromDate!)) {
          return false;
        }
        if (_deactivatedToDate != null &&
            vendor.deactivatedAt!.isAfter(
              _deactivatedToDate!.add(const Duration(days: 1)),
            )) {
          return false;
        }
      } else if (_deactivatedFromDate != null || _deactivatedToDate != null) {
        return false; // No deactivatedAt date but filter requires it
      }

      // Days deactivated filter
      if (_minDaysDeactivated != null) {
        final daysDeactivated = _getDaysDeactivated(vendor);
        if (daysDeactivated < _minDaysDeactivated!) {
          return false;
        }
      }

      // Deactivation reason filter
      if (_selectedDeactivationReason != null &&
          _selectedDeactivationReason!.isNotEmpty) {
        final vendorReason = vendor.deactivationReason?.toLowerCase() ?? '';
        final selectedReasonLower = _selectedDeactivationReason!.toLowerCase();

        // Handle "Other" reason - check if reason starts with "other:"
        if (selectedReasonLower == 'other') {
          if (!vendorReason.startsWith('other:')) {
            return false;
          }
        } else {
          // Exact match for predefined reasons
          if (vendorReason != selectedReasonLower) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar and Filter
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search deactivated vendors...',
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
                    setState(() {
                      _searchQuery = value;
                      _updateFilterState();
                    });
                  },
                ),
              ),
              const SizedBox(width: UIConstants.spacingSm),
              IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: _hasActiveFilters
                          ? AppColors.primary
                          : AppColorsExtension.getTextSecondary(context),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'Filter vendors',
              ),
              if (_hasActiveFilters)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearFilters,
                  tooltip: 'Clear filters',
                ),
            ],
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
                        Icons.cancel_outlined,
                        size: 64,
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        _hasActiveFilters || _searchQuery.isNotEmpty
                            ? 'No vendors match your filters'
                            : 'No deactivated vendors',
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
          Icon(Icons.cancel_rounded, color: AppColors.error, size: 32),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deactivated Vendors',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _searchQuery.isNotEmpty
                      ? '${_filteredVendors.length} of ${_vendors.length} vendors'
                      : '${_vendors.length} vendors',
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
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Deactivated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMd),
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReactivateDialog(context, vendor),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reactivate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    DateTime? tempDeactivatedFromDate = _deactivatedFromDate;
    DateTime? tempDeactivatedToDate = _deactivatedToDate;
    int? tempMinDaysDeactivated = _minDaysDeactivated;
    String? tempSelectedReason = _selectedDeactivationReason;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Deactivated Vendors'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deactivated Date Range
                Text(
                  'Deactivated Date Range',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                tempDeactivatedFromDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              tempDeactivatedFromDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tempDeactivatedFromDate != null
                                      ? '${tempDeactivatedFromDate!.day}/${tempDeactivatedFromDate!.month}/${tempDeactivatedFromDate!.year}'
                                      : 'From date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                tempDeactivatedToDate ?? DateTime.now(),
                            firstDate:
                                tempDeactivatedFromDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              tempDeactivatedToDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tempDeactivatedToDate != null
                                      ? '${tempDeactivatedToDate!.day}/${tempDeactivatedToDate!.month}/${tempDeactivatedToDate!.year}'
                                      : 'To date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Days Deactivated Filter
                Text(
                  'Minimum Days Deactivated',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempMinDaysDeactivated?.toDouble() ?? 0.0,
                        min: 0.0,
                        max: 365.0,
                        divisions: 73,
                        label: tempMinDaysDeactivated != null
                            ? tempMinDaysDeactivated.toString()
                            : 'None',
                        onChanged: (value) {
                          setState(() {
                            tempMinDaysDeactivated = value > 0
                                ? value.toInt()
                                : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        tempMinDaysDeactivated != null
                            ? tempMinDaysDeactivated.toString()
                            : 'None',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Deactivation Reason Filter
                Text(
                  'Deactivation Reason',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempSelectedReason,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select reason',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'All Reasons',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    ..._availableDeactivationReasons.map(
                      (reason) => DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                  selectedItemBuilder: (context) {
                    return [
                      const Text(
                        'All Reasons',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      ..._availableDeactivationReasons.map(
                        (reason) => Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ];
                  },
                  onChanged: (value) {
                    setState(() {
                      tempSelectedReason = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempDeactivatedFromDate = null;
                  tempDeactivatedToDate = null;
                  tempMinDaysDeactivated = null;
                  tempSelectedReason = null;
                });
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _deactivatedFromDate = tempDeactivatedFromDate;
                  _deactivatedToDate = tempDeactivatedToDate;
                  _minDaysDeactivated = tempMinDaysDeactivated;
                  _selectedDeactivationReason = tempSelectedReason;
                  _updateFilterState();
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactivateDialog(BuildContext context, VendorProfileEntity vendor) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reactivate Vendor'),
        content: Text(
          'Are you sure you want to reactivate ${vendor.businessName}? This will restore the vendor to active status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _reactivateVendor(vendor.id);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Reactivate'),
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
              _buildDetailRow('Contact', vendor.contactNumber),
              _buildDetailRow('Address', vendor.businessAddress),
              if (vendor.cuisineType != null)
                _buildDetailRow('Cuisine', vendor.cuisineType!),
              if (vendor.ratingAverage != null)
                _buildDetailRow(
                  'Rating',
                  vendor.ratingAverage!.toStringAsFixed(1),
                ),
              _buildDetailRow('Outlets', '${vendor.outlets.length}'),
              _buildDetailRow('Menu Items', '${vendor.menuItems.length}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
