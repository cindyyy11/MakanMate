import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/presentation/widgets/3d_card.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VendorManagementPage extends StatelessWidget {
  const VendorManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : AppColors.background,
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
              child: const TabBar(
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
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _VendorApplicationsTab(),
            _ActiveVendorsTab(),
            _SuspendedVendorsTab(),
            _ComplianceTab(),
          ],
        ),
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
  // Search and filter functionality can be implemented here
  // String _searchQuery = '';
  // String? _filterRisk;

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
                    // Implement search functionality
                    // setState(() => _searchQuery = value);
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
                  // Implement filter functionality
                  // setState(() => _filterRisk = value == 'all' ? null : value);
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
          child: ListView(
            padding: UIConstants.paddingLg,
            children: [
              _buildStatsCards(context),
              const SizedBox(height: UIConstants.spacingLg),
              _buildApplicationCard(
                context,
                'Nasi Lemak Corner',
                ownerName: 'Ahmad bin Hassan',
                email: 'ahmad@example.com',
                submittedDate: DateTime.now().subtract(const Duration(days: 2)),
                riskScore: 45,
                redFlags: ['No business reg', 'Halal cert expiring'],
              ),
              _buildApplicationCard(
                context,
                'Mamak Stall KL',
                ownerName: 'Raj Kumar',
                email: 'raj@example.com',
                submittedDate: DateTime.now().subtract(const Duration(days: 1)),
                riskScore: 25,
                redFlags: [],
              ),
              _buildApplicationCard(
                context,
                'Chinese Restaurant',
                ownerName: 'Lee Wei Ming',
                email: 'lee@example.com',
                submittedDate: DateTime.now().subtract(
                  const Duration(hours: 5),
                ),
                riskScore: 75,
                redFlags: [
                  'Invalid license',
                  'Suspicious activity',
                  'Duplicate listing',
                ],
              ),
            ],
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
            '12',
            Icons.pending_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'Low Risk',
            '8',
            Icons.check_circle_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'High Risk',
            '4',
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
    String name, {
    String? ownerName,
    String? email,
    DateTime? submittedDate,
    int? riskScore,
    List<String>? redFlags,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final riskColor = riskScore != null
        ? (riskScore < 30
              ? AppColors.success
              : riskScore < 70
              ? AppColors.warning
              : AppColors.error)
        : AppColors.grey500;

    return Card3D(
      onTap: () {
        // Show detailed view
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
                        if (ownerName != null) ...[
                          const SizedBox(height: UIConstants.spacingXs),
                          Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 14,
                                color: AppColorsExtension.getTextSecondary(
                                  context,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ownerName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color:
                                          AppColorsExtension.getTextSecondary(
                                            context,
                                          ),
                                    ),
                              ),
                            ],
                          ),
                        ],
                        if (email != null) ...[
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
                                  email,
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
                        if (submittedDate != null) ...[
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
                                      color:
                                          AppColorsExtension.getTextSecondary(
                                            context,
                                          ),
                                    ),
                              ),
                            ],
                          ),
                        ],
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
              if (redFlags != null && redFlags.isNotEmpty) ...[
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
                      onPressed: () {},
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
                      onPressed: () {},
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
                    onPressed: () {},
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
}

class _ActiveVendorsTab extends StatelessWidget {
  const _ActiveVendorsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Active Vendors'));
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
