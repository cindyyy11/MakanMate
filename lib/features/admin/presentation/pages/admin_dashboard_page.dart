import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/core/widgets/error_widget.dart';
import 'package:makan_mate/core/widgets/loading_widget.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_state.dart';
import 'package:makan_mate/features/admin/presentation/widgets/activity_log_item.dart';
import 'package:makan_mate/features/admin/presentation/widgets/animated_metric_card.dart';
import 'package:makan_mate/core/widgets/date_range_filter.dart';
import 'package:makan_mate/core/widgets/loading_animation.dart';
import 'package:makan_mate/core/widgets/theme_toggle_button.dart';
import 'package:makan_mate/features/admin/presentation/widgets/notification_badge.dart';
import 'package:makan_mate/features/admin/presentation/widgets/realtime_monitoring_widget.dart';
import 'package:makan_mate/features/admin/presentation/widgets/trend_chart_widget.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

/// Admin dashboard page showing platform analytics
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Timer? _refreshTimer;
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedTab = 0; // 0: Overview, 1: Trends, 2: Activity, 3: Real-time

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<AdminBloc>().add(const LoadPlatformMetrics());

    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<AdminBloc>().add(
          RefreshPlatformMetrics(startDate: _startDate, endDate: _endDate),
        );
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    // Stop streaming when disposing
    context.read<AdminBloc>().add(const StopStreamingSystemMetrics());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      endDrawer: _buildAlertsDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0E27),
                    const Color(0xFF1A1F3A),
                    const Color(0xFF121212),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.03),
                    AppColors.secondary.withValues(alpha: 0.03),
                    AppColors.background,
                    AppColors.backgroundLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              _buildEnhancedAppBar(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingLg,
        vertical: UIConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2C2C).withValues(alpha: 0.95),
                  const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.9),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo/Icon with animation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 24),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColorsExtension.getTextPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Platform Analytics & Insights',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                    fontSize: UIConstants.fontSizeSm,
                  ),
                ),
              ],
            ),
          ),
          _buildAppBarActions(context),
        ],
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Export button with better styling
            _buildActionButton(
              context: context,
              icon: Icons.download_rounded,
              tooltip: 'Export Data',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildExportBottomSheet(context),
                );
              },
            ),
            const SizedBox(width: UIConstants.spacingXs),
            // Theme toggle button
            const ThemeToggleButton(),
            const SizedBox(width: UIConstants.spacingXs),
            // Alerts button
            _buildAlertsButton(context, state),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    int? badge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey300,
              width: 1,
            ),
          ),
          child: badge != null
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF121212)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          badge > 9 ? '9+' : badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(
                  icon,
                  size: 20,
                  color: AppColorsExtension.getTextPrimary(context),
                ),
        ),
      ),
    );
  }

  Widget _buildAlertsButton(BuildContext context, AdminState state) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final unreadCount = state is AdminLoaded && state.notifications != null
            ? state.notifications!.where((n) => !n.isRead).length
            : 0;

        return _buildActionButton(
          context: context,
          icon: unreadCount > 0
              ? Icons.notifications_rounded
              : Icons.notifications_outlined,
          tooltip: 'Alerts & Notifications',
          badge: unreadCount > 0 ? unreadCount : null,
          onTap: () {
            // Use side drawer on larger screens, bottom sheet on mobile
            final screenWidth = MediaQuery.of(context).size.width;
            if (screenWidth > 600) {
              // Desktop/Tablet: Use side drawer
              Scaffold.of(context).openEndDrawer();
            } else {
              // Mobile: Use bottom sheet
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => _buildAlertsBottomSheet(context, state),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildAlertsDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth > 1200 ? 400.0 : 350.0;

    return Drawer(
      width: drawerWidth,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          final loadedState = state is AdminLoaded ? state : null;

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(UIConstants.spacingLg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                        : [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                  ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: UIConstants.spacingMd),
                        Expanded(
                          child: Text(
                            'Alerts & Notifications',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsExtension.getTextPrimary(
                                    context,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
                  ],
                ),
              ),
              // Refresh button
              Padding(
                padding: const EdgeInsets.all(UIConstants.spacingMd),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.read<AdminBloc>().add(const LoadNotifications());
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.spacingMd,
                        vertical: UIConstants.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: UIConstants.fontSizeSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child:
                    loadedState?.notifications != null &&
                        loadedState!.notifications!.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingLg,
                        ),
                        itemCount: loadedState.notifications!.length,
                        itemBuilder: (context, index) {
                          final notification =
                              loadedState.notifications![index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: UIConstants.spacingMd,
                            ),
                            child: NotificationBadge(
                              notification: notification,
                              onTap: () {
                                if (!notification.isRead) {
                                  context.read<AdminBloc>().add(
                                    MarkNotificationAsRead(notification.id),
                                  );
                                }
                                if (notification.actionUrl != null) {
                                  // Navigate to action URL if needed
                                }
                              },
                              onDismiss: () {
                                context.read<AdminBloc>().add(
                                  MarkNotificationAsRead(notification.id),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: UIConstants.paddingXl,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 64,
                                color: AppColorsExtension.getGrey600(context),
                              ),
                              const SizedBox(height: UIConstants.spacingMd),
                              Text(
                                'No notifications',
                                style: TextStyle(
                                  color: AppColorsExtension.getGrey600(context),
                                  fontSize: UIConstants.fontSizeLg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertsBottomSheet(BuildContext context, AdminState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadedState = state is AdminLoaded ? state : null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: UIConstants.spacingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorsExtension.getGrey600(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingMd),
                    Text(
                      'Alerts & Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColorsExtension.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.read<AdminBloc>().add(const LoadNotifications());
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.spacingMd,
                        vertical: UIConstants.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: UIConstants.fontSizeSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child:
                loadedState?.notifications != null &&
                    loadedState!.notifications!.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingLg,
                    ),
                    itemCount: loadedState.notifications!.length,
                    itemBuilder: (context, index) {
                      final notification = loadedState.notifications![index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: UIConstants.spacingMd,
                        ),
                        child: NotificationBadge(
                          notification: notification,
                          onTap: () {
                            if (!notification.isRead) {
                              context.read<AdminBloc>().add(
                                MarkNotificationAsRead(notification.id),
                              );
                            }
                            if (notification.actionUrl != null) {
                              // Navigate to action URL if needed
                            }
                          },
                          onDismiss: () {
                            context.read<AdminBloc>().add(
                              MarkNotificationAsRead(notification.id),
                            );
                          },
                        ),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: UIConstants.paddingXl,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 64,
                            color: AppColorsExtension.getGrey600(context),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              color: AppColorsExtension.getGrey600(context),
                              fontSize: UIConstants.fontSizeLg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: UIConstants.spacingLg),
        ],
      ),
    );
  }

  Widget _buildExportBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(UIConstants.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorsExtension.getGrey600(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: UIConstants.spacingLg),
          Text(
            'Export Data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColorsExtension.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: UIConstants.spacingLg),
          _buildExportOption(
            context: context,
            icon: Icons.table_chart_rounded,
            title: 'Export as CSV',
            subtitle: 'Comma-separated values file',
            onTap: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(
                ExportMetrics(
                  format: 'csv',
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              );
            },
          ),
          const SizedBox(height: UIConstants.spacingMd),
          _buildExportOption(
            context: context,
            icon: Icons.picture_as_pdf_rounded,
            title: 'Export as PDF',
            subtitle: 'Portable document format',
            onTap: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(
                ExportMetrics(
                  format: 'pdf',
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              );
            },
          ),
          const SizedBox(height: UIConstants.spacingLg),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(UIConstants.spacingMd),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: UIConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorsExtension.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColorsExtension.getGrey600(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingAnimation(size: 60),
                const SizedBox(height: UIConstants.spacingLg),
                Text(
                  'Loading platform metrics...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is AdminError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<AdminBloc>().add(const LoadPlatformMetrics());
            },
          );
        }

        if (state is AdminExportSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleExportSuccess(state.filePath, state.format);
          });
        }

        if (state is AdminLoaded || state is AdminRefreshing) {
          final metrics = state is AdminLoaded
              ? state.metrics
              : (state as AdminRefreshing).metrics;
          final isRefreshing = state is AdminRefreshing;
          final loadedState = state is AdminLoaded ? state : null;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminBloc>().add(
                RefreshPlatformMetrics(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              );
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Column(
              children: [
                // Date Range Filter with better spacing
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UIConstants.spacingLg,
                    UIConstants.spacingMd,
                    UIConstants.spacingLg,
                    UIConstants.spacingMd,
                  ),
                  child: DateRangeFilter(
                    startDate: _startDate,
                    endDate: _endDate,
                    onDateRangeChanged: (start, end) {
                      setState(() {
                        _startDate = start;
                        _endDate = end;
                      });
                      context.read<AdminBloc>().add(
                        LoadPlatformMetrics(startDate: start, endDate: end),
                      );
                    },
                    onClear: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      context.read<AdminBloc>().add(
                        const LoadPlatformMetrics(),
                      );
                    },
                  ),
                ),

                // Enhanced Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingLg,
                  ),
                  child: _buildGlassTabBar(),
                ),

                const SizedBox(height: UIConstants.spacingLg),

                // Content based on selected tab
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: UIConstants.paddingLg,
                    child: _buildTabContent(
                      _selectedTab,
                      metrics,
                      isRefreshing,
                      loadedState,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const LoadingWidget();
      },
    );
  }

  Widget _buildGlassTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: UIConstants.borderRadiusLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : AppColors.grey200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEnhancedTab(0, 'Overview', Icons.dashboard_rounded),
          ),
          Expanded(
            child: _buildEnhancedTab(1, 'Trends', Icons.trending_up_rounded),
          ),
          Expanded(
            child: _buildEnhancedTab(2, 'Activity', Icons.history_rounded),
          ),
          Expanded(
            child: _buildEnhancedTab(3, 'Real-time', Icons.sensors_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final previousTab = _selectedTab;
          setState(() => _selectedTab = index);

          // Start/stop streaming based on tab selection
          if (index == 3 && previousTab != 3) {
            // Starting real-time monitoring
            context.read<AdminBloc>().add(const StartStreamingSystemMetrics());
          } else if (previousTab == 3 && index != 3) {
            // Stopping real-time monitoring
            context.read<AdminBloc>().add(const StopStreamingSystemMetrics());
          }
        },
        borderRadius: UIConstants.borderRadiusMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: UIConstants.borderRadiusMd,
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : AppColorsExtension.getGrey700(context),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: UIConstants.fontSizeXs,
                  color: isSelected
                      ? AppColors.primary
                      : AppColorsExtension.getGrey700(context),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsTab(AdminLoaded? loadedState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedSectionTitle('Trend Analysis', Icons.trending_up_rounded),
        const SizedBox(height: UIConstants.spacingXl),
        if (loadedState?.userTrend != null)
          TrendChartWidget(
            trend: loadedState!.userTrend!,
            lineColor: AppColors.info,
            title: 'User Growth (7 Days)',
          ),
        if (loadedState?.userTrend != null && loadedState?.vendorTrend != null)
          const SizedBox(height: UIConstants.spacingLg),
        if (loadedState?.vendorTrend != null)
          TrendChartWidget(
            trend: loadedState!.vendorTrend!,
            lineColor: AppColors.primary,
            title: 'Vendor Growth (7 Days)',
          ),
        if (loadedState?.userTrend == null && loadedState?.vendorTrend == null)
          Center(
            child: Padding(
              padding: UIConstants.paddingXl,
              child: Column(
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    size: 64,
                    color: AppColorsExtension.getGrey600(context),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No trend data available',
                    style: TextStyle(
                      color: AppColorsExtension.getGrey600(context),
                      fontSize: UIConstants.fontSizeLg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: UIConstants.spacingXl),
      ],
    );
  }

  Widget _buildActivityTab(AdminLoaded? loadedState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildEnhancedSectionTitle(
              'User Activity Logs',
              Icons.history_rounded,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<AdminBloc>().add(
                    const LoadActivityLogs(limit: 100),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingMd,
                    vertical: UIConstants.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Load More',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: UIConstants.fontSizeSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingLg),
        if (loadedState?.activityLogs != null &&
            loadedState!.activityLogs!.isNotEmpty)
          ...loadedState.activityLogs!.map((log) => ActivityLogItem(log: log))
        else
          Center(
            child: Padding(
              padding: UIConstants.paddingXl,
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppColorsExtension.getGrey600(context),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No activity logs available',
                    style: TextStyle(
                      color: AppColorsExtension.getGrey600(context),
                      fontSize: UIConstants.fontSizeLg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: UIConstants.spacingXl),
      ],
    );
  }

  Future<void> _handleExportSuccess(String filePath, String format) async {
    try {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported successfully as $format'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                await OpenFilex.open(filePath);
              },
            ),
          ),
        );
      }

      // Share the file
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'MakanMate Platform Metrics Export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export saved to: $filePath'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    }
  }

  Widget _buildTabContent(
    int tabIndex,
    metrics,
    bool isRefreshing,
    AdminLoaded? loadedState,
  ) {
    switch (tabIndex) {
      case 0:
        return _buildOverviewTab(metrics, isRefreshing);
      case 1:
        return _buildTrendsTab(loadedState);
      case 2:
        return _buildActivityTab(loadedState);
      case 3:
        return _buildRealtimeTab(loadedState);
      default:
        return const SizedBox();
    }
  }

  Widget _buildRealtimeTab(AdminLoaded? loadedState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedSectionTitle(
          'Real-Time Monitoring',
          Icons.sensors_rounded,
        ),
        const SizedBox(height: UIConstants.spacingMd),
        Text(
          'Live system metrics updated in real-time',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColorsExtension.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: UIConstants.spacingXl),
        RealtimeMonitoringWidget(systemMetrics: loadedState?.systemMetrics),
        const SizedBox(height: UIConstants.spacingXl),
      ],
    );
  }

  Widget _buildOverviewTab(metrics, bool isRefreshing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Header with last updated
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingMd),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.grey50,
            borderRadius: UIConstants.borderRadiusMd,
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: UIConstants.spacingMd),
                        Text(
                          'Platform Analytics',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorsExtension.getTextPrimary(
                                  context,
                                ),
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColorsExtension.getGrey600(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Last updated: ${DateFormat('MMM dd, yyyy • HH:mm').format(metrics.lastUpdated)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColorsExtension.getGrey600(context),
                                fontSize: UIConstants.fontSizeSm,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isRefreshing)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: UIConstants.spacingXl),

        // User metrics section with better spacing
        _buildEnhancedSectionTitle('User Analytics', Icons.people_rounded),
        const SizedBox(height: UIConstants.spacingLg),
        _buildUserMetrics(metrics),

        const SizedBox(height: UIConstants.spacing2Xl),

        // Vendor metrics section
        _buildEnhancedSectionTitle('Vendor Analytics', Icons.store_rounded),
        const SizedBox(height: UIConstants.spacingLg),
        _buildVendorMetrics(metrics),

        const SizedBox(height: UIConstants.spacing2Xl),

        // Platform metrics section
        _buildEnhancedSectionTitle(
          'Platform Overview',
          Icons.dashboard_rounded,
        ),
        const SizedBox(height: UIConstants.spacingLg),
        _buildPlatformMetrics(metrics),

        const SizedBox(height: UIConstants.spacingXl),
      ],
    );
  }

  Widget _buildEnhancedSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColorsExtension.getTextPrimary(context),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildUserMetrics(metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Total Users',
                value: _formatNumber(metrics.totalUsers),
                icon: Icons.people,
                color: AppColors.info,
                gradient: AppColors.infoGradient,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Active Today',
                value: _formatNumber(metrics.todaysActiveUsers),
                icon: Icons.trending_up,
                color: AppColors.success,
                gradient: AppColors.successGradient,
                subtitle: 'Last 24 hours',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVendorMetrics(metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Total Vendors',
                value: _formatNumber(metrics.totalVendors),
                icon: Icons.store,
                color: AppColors.primary,
                gradient: AppColors.primaryGradient,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Active Vendors',
                value: '${metrics.activeVendors}',
                icon: Icons.check_circle,
                color: AppColors.success,
                gradient: AppColors.successGradient,
                subtitle: 'of ${metrics.totalVendors} total',
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingMd),
        AnimatedMetricCard(
          title: 'Pending Applications',
          value: _formatNumber(metrics.pendingApplications),
          icon: Icons.pending_actions,
          color: AppColors.warning,
          gradient: AppColors.warningGradient,
          subtitle: metrics.pendingApplications > 0
              ? 'Requires review'
              : 'All applications processed',
        ),
      ],
    );
  }

  Widget _buildPlatformMetrics(metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Restaurants',
                value: _formatNumber(metrics.totalRestaurants),
                icon: Icons.restaurant,
                color: AppColors.secondary,
                gradient: AppColors.secondaryGradient,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Food Items',
                value: _formatNumber(metrics.totalFoodItems),
                icon: Icons.fastfood,
                color: AppColors.aiPrimary,
                gradient: AppColors.aiGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: AnimatedMetricCard(
                title: 'Average Rating',
                value: metrics.averagePlatformRating > 0
                    ? metrics.averagePlatformRating.toStringAsFixed(1)
                    : 'N/A',
                icon: Icons.star,
                color: AppColors.rating,
                gradient: AppColors.ratingGradient,
                subtitle: 'Platform-wide average',
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: AnimatedMetricCard(
                title: 'Flagged Reviews',
                value: _formatNumber(metrics.flaggedReviews),
                icon: Icons.flag,
                color: AppColors.error,
                gradient: AppColors.errorGradient,
                subtitle: metrics.flaggedReviews > 0
                    ? 'Needs attention'
                    : 'No flagged content',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
