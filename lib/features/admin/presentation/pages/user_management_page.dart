import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/presentation/widgets/3d_card.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 5,
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
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              const Text('User Management'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {},
              tooltip: 'Search Users',
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
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    icon: Icon(Icons.people_outline_rounded, size: 20),
                    text: 'All Users',
                  ),
                  Tab(
                    icon: Icon(Icons.rate_review_rounded, size: 20),
                    text: 'Review Moderation',
                  ),
                  Tab(
                    icon: Icon(Icons.block_rounded, size: 20),
                    text: 'Bans & Warnings',
                  ),
                  Tab(
                    icon: Icon(Icons.support_agent_rounded, size: 20),
                    text: 'Support Tickets',
                  ),
                  Tab(
                    icon: Icon(Icons.analytics_rounded, size: 20),
                    text: 'Analytics',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _AllUsersTab(),
            _ReviewModerationTab(),
            _BansWarningsTab(),
            _SupportTicketsTab(),
            _AnalyticsTab(),
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

class _AllUsersTab extends StatelessWidget {
  const _AllUsersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: UIConstants.paddingLg,
      children: const [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('John Doe'),
          subtitle: Text('john@example.com'),
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _ReviewModerationTab extends StatelessWidget {
  const _ReviewModerationTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: UIConstants.paddingLg,
      children: [
        _buildStatsRow(context),
        const SizedBox(height: UIConstants.spacingLg),
        Card3D(
          child: Container(
            margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: UIConstants.borderRadiusLg,
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: UIConstants.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.error,
                              AppColors.error.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flagged Review',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
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
                                'Toxicity: 0.75 (High)',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Container(
                    padding: UIConstants.paddingSm,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              child: Icon(Icons.person, size: 18),
                            ),
                            const SizedBox(width: UIConstants.spacingSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'John Doe',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '2 days ago',
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
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingSm),
                        Text(
                          'This place is TERRIBLE! Don\'t waste your time or money here. The food was cold, service was rude, and the place was dirty.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Keep'),
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
                          onPressed: () {},
                          icon: const Icon(Icons.delete_rounded, size: 18),
                          label: const Text('Remove'),
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
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Flagged',
            '12',
            Icons.flag_rounded,
            AppColors.error,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'Pending',
            '8',
            Icons.pending_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'Resolved',
            '45',
            Icons.check_circle_rounded,
            AppColors.success,
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
}

class _BansWarningsTab extends StatelessWidget {
  const _BansWarningsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bans & Warnings'));
  }
}

class _SupportTicketsTab extends StatelessWidget {
  const _SupportTicketsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Support Tickets'));
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('User Analytics'));
  }
}
