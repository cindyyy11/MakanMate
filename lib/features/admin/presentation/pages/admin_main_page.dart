import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:makan_mate/features/admin/presentation/pages/audit_log_viewer_page.dart';
import 'package:makan_mate/features/admin/presentation/pages/vendor_management_page.dart';
import 'package:makan_mate/features/admin/presentation/pages/user_management_page.dart';
import 'package:makan_mate/features/admin/presentation/pages/create_admin_page.dart';
import 'package:makan_mate/features/admin/presentation/pages/create_announcement_page.dart';
import 'package:makan_mate/features/admin/presentation/widgets/creative_bottom_nav_bar.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/navigation/admin_nav_controller.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;

/// Main admin page with navigation drawer
class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late final AdminNavController _navController;

  @override
  void initState() {
    super.initState();
    _navController = di.sl<AdminNavController>();
    _navController.addListener(_handleAdminNavRequest);
  }

  // Expose navigateToPage for external access
  void navigateToPage(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _navController.removeListener(_handleAdminNavRequest);
    _pageController.dispose();
    super.dispose();
  }

  void _handleAdminNavRequest() {
    final title = _navController.targetSectionTitle;
    if (title == null) return;
    final idx = _navItems.indexWhere((item) => item.title == title);
    if (idx != -1) {
      navigateToPage(idx);
    }
    _navController.clear();
  }

  final List<AdminNavItem> _navItems = [
    // Category 1: System Admin Features
    AdminNavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_rounded,
      page: const AdminDashboardPage(),
      category: 'System',
    ),
    AdminNavItem(
      title: 'Audit Log Viewer',
      icon: Icons.history_rounded,
      page: const AuditLogViewerPage(),
      category: 'System',
    ),
    // Category 2: Admin-Vendor Interaction
    AdminNavItem(
      title: 'Vendor Management',
      icon: Icons.store_rounded,
      page: const VendorManagementPage(),
      category: 'Vendors',
    ),
    // Category 3: Admin-User Interaction
    AdminNavItem(
      title: 'User Management',
      icon: Icons.people_rounded,
      page: const UserManagementPage(),
      category: 'Users',
    ),
    AdminNavItem(
      title: 'Create Admin',
      icon: Icons.person_add_rounded,
      page: const CreateAdminPage(),
      category: 'Users',
    ),
    AdminNavItem(
      title: 'Create Announcement',
      icon: Icons.campaign_rounded,
      page: const CreateAnnouncementPage(),
      category: 'System',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    if (isDesktop) {
      return _buildDesktopLayout(isDark);
    } else {
      return _buildMobileLayout(isDark);
    }
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationDrawer(isDark, isDesktop: true),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _navItems.map((item) => item.page).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Scaffold(
      drawer: _buildNavigationDrawer(isDark, isDesktop: false),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _navItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  void _showAllFeaturesDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _navItems.map((e) => e.category).toSet().toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: UIConstants.borderRadiusLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: UIConstants.paddingLg,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.apps_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: UIConstants.spacingMd),
                    Expanded(
                      child: Text(
                        'All Admin Features',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: UIConstants.paddingLg,
                  itemCount: categories.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = categories[categoryIndex];
                    final categoryItems = _navItems
                        .where((item) => item.category == category)
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: UIConstants.spacingMd,
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColorsExtension.getGrey600(context),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        ...categoryItems.map((item) {
                          final itemIndex = _navItems.indexOf(item);
                          final isSelected = _selectedIndex == itemIndex;

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppColors.primaryGradient
                                    : null,
                                color: isSelected
                                    ? null
                                    : AppColorsExtension.getGrey600(
                                        context,
                                      ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.white
                                    : AppColorsExtension.getGrey700(context),
                                size: 20,
                              ),
                            ),
                            title: Text(item.title),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  )
                                : const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.pop(context);
                              navigateToPage(itemIndex);
                            },
                          );
                        }),
                        if (categoryIndex < categories.length - 1)
                          const Divider(height: UIConstants.spacingXl),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(bool isDark, {required bool isDesktop}) {
    final categories = _navItems.map((e) => e.category).toSet().toList();

    return Container(
      width: isDesktop ? 280 : 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingLg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.grey200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MakanMate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
          // Navigation items grouped by category
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: UIConstants.spacingMd,
              ),
              itemCount: categories.length,
              itemBuilder: (context, categoryIndex) {
                final category = categories[categoryIndex];
                final categoryItems = _navItems
                    .where((item) => item.category == category)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.spacingLg,
                        vertical: UIConstants.spacingSm,
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColorsExtension.getGrey600(context),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...categoryItems.asMap().entries.map((entry) {
                      final index = _navItems.indexOf(entry.value);
                      final isSelected = _selectedIndex == index;

                      return _buildNavItem(
                        entry.value,
                        index,
                        isSelected,
                        isDark,
                      );
                    }),
                    if (categoryIndex < categories.length - 1)
                      const Divider(height: UIConstants.spacingXl),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    AdminNavItem item,
    int index,
    bool isSelected,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          navigateToPage(index);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingMd,
            vertical: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingMd,
            vertical: UIConstants.spacingMd,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: UIConstants.borderRadiusMd,
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColorsExtension.getGrey700(context),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColorsExtension.getTextPrimary(context),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    // Show most useful functions that are always used
    final mainItems = [
      _navItems[0], // Dashboard
      _navItems[2], // Vendor Management
      _navItems[3], // User Management
      _navItems[5], // Create Announcement
    ];

    final navBarItems = mainItems.map((item) {
      return BottomNavItem(
        icon: item.icon,
        activeIcon: item.icon,
        label: item.title,
      );
    }).toList();

    // Add "All Features" as the 5th item
    navBarItems.add(
      const BottomNavItem(
        icon: Icons.apps_rounded,
        activeIcon: Icons.apps_rounded,
        label: 'More',
      ),
    );

    final currentMainIndex = mainItems.indexWhere(
      (item) => _navItems.indexOf(item) == _selectedIndex,
    );
    final currentIndex = currentMainIndex >= 0
        ? currentMainIndex
        : 4; // Default to "More" if not found

    return CreativeBottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index < mainItems.length) {
          // Navigate to main feature
          final selectedNavItem = mainItems[index];
          final pageIndex = _navItems.indexOf(selectedNavItem);
          setState(() => _selectedIndex = pageIndex);
          _pageController.jumpToPage(pageIndex);
        } else {
          // Open "All Features" dialog
          _showAllFeaturesDialog(context);
        }
      },
      items: navBarItems,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

class AdminNavItem {
  final String title;
  final IconData icon;
  final Widget page;
  final String category;

  const AdminNavItem({
    required this.title,
    required this.icon,
    required this.page,
    required this.category,
  });
}
