import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/presentation/widgets/3d_card.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_state.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_state.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';
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
    return BlocConsumer<AdminUserManagementBloc, AdminUserManagementState>(
      listener: (context, state) {
        // Handle any side effects if needed
      },
      builder: (context, state) {
        if (state is AdminUserManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminUserManagementError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: UIConstants.spacingMd),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: UIConstants.spacingMd),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminUserManagementBloc>().add(
                      const LoadUsers(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is UsersLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: AppColorsExtension.getTextSecondary(context),
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  Text(
                    'No users found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColorsExtension.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminUserManagementBloc>().add(const LoadUsers());
            },
            child: ListView.builder(
              padding: UIConstants.paddingLg,
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        if (user.isVerified)
                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.success),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      // Navigate to user details page
                      await Navigator.of(context).pushNamed(
                        '/userDetails',
                        arguments: user,
                      );
                      // Refresh users list when returning from details page
                      // Use a small delay to ensure the page is fully back and context is ready
                      await Future.delayed(const Duration(milliseconds: 100));
                      if (context.mounted) {
                        context.read<AdminUserManagementBloc>().add(
                              const LoadUsers(),
                            );
                      }
                    },
                  ),
                );
              },
            ),
          );
        }

        // Initial state - load users
        if (state is AdminUserManagementInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AdminUserManagementBloc>().add(const LoadUsers());
          });
        }

        // If state is UserOperationSuccess, still show the last loaded users
        // or trigger a reload
        if (state is UserOperationSuccess) {
          // Trigger reload to get fresh data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AdminUserManagementBloc>().add(const LoadUsers());
          });
          // Show loading while reloading
          return const Center(child: CircularProgressIndicator());
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ReviewModerationTab extends StatelessWidget {
  const _ReviewModerationTab();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminReviewManagementBloc, AdminReviewManagementState>(
      listener: (context, state) {
        if (state is ReviewOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload reviews after operation
          context.read<AdminReviewManagementBloc>().add(
                const LoadFlaggedReviews(),
              );
        } else if (state is AdminReviewManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AdminReviewManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminReviewManagementError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: UIConstants.spacingMd),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: UIConstants.spacingMd),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminReviewManagementBloc>().add(
                          const LoadFlaggedReviews(),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<AdminReviewEntity> reviews = [];
        if (state is ReviewsLoaded) {
          reviews = state.reviews;
        }

        // Load reviews on initial build
        if (state is AdminReviewManagementInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AdminReviewManagementBloc>().add(
                  const LoadFlaggedReviews(),
                );
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminReviewManagementBloc>().add(
                  const LoadFlaggedReviews(),
                );
          },
          child: ListView(
            padding: UIConstants.paddingLg,
            children: [
              _buildStatsRow(context, reviews),
              const SizedBox(height: UIConstants.spacingLg),
              if (reviews.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: AppColorsExtension.getTextSecondary(context),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      Text(
                        'No flagged reviews',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColorsExtension.getTextSecondary(context),
                            ),
                      ),
                    ],
                  ),
                )
              else
                ...reviews.map((review) => _buildReviewCard(context, review)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(BuildContext context, AdminReviewEntity review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFlagged = review.flagged == true;

    return Card3D(
      child: Container(
        margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
          border: Border.all(
            color: isFlagged
                ? AppColors.error.withOpacity(0.3)
                : AppColors.grey200.withOpacity(0.3),
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
                          isFlagged ? AppColors.error : AppColors.warning,
                          (isFlagged ? AppColors.error : AppColors.warning)
                              .withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isFlagged ? Icons.flag_rounded : Icons.rate_review_rounded,
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
                          review.vendorName ?? 'Unknown Vendor',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < review.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: AppColors.rating,
                              ),
                            ),
                            const SizedBox(width: UIConstants.spacingSm),
                            Text(
                              review.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: review.userProfileImageUrl != null
                              ? NetworkImage(review.userProfileImageUrl!)
                              : null,
                          child: review.userProfileImageUrl == null
                              ? const Icon(Icons.person, size: 18)
                              : null,
                        ),
                        const SizedBox(width: UIConstants.spacingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName ?? 'Anonymous',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _formatDate(review.createdAt),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColorsExtension.getTextSecondary(
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
                      review.comment,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (review.flagReason != null) ...[
                      const SizedBox(height: UIConstants.spacingSm),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: UIConstants.spacingSm),
                            Expanded(
                              child: Text(
                                'Flag reason: ${review.flagReason}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: UIConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AdminReviewManagementBloc>().add(
                              ApproveReview(
                                reviewId: review.id,
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
                        _showRemoveDialog(context, review);
                      },
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
    );
  }

  void _showRemoveDialog(BuildContext context, AdminReviewEntity review) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for removing this review:'),
            const SizedBox(height: UIConstants.spacingMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for removal',
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
                context.read<AdminReviewManagementBloc>().add(
                      RemoveReview(
                        reviewId: review.id,
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, List<AdminReviewEntity> reviews) {
    final flaggedCount = reviews.where((r) => r.flagged == true).length;
    final pendingCount = reviews.length;
    final resolvedCount = reviews.where((r) => r.removed == true).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Flagged',
            flaggedCount.toString(),
            Icons.flag_rounded,
            AppColors.error,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'Pending',
            pendingCount.toString(),
            Icons.pending_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: _buildStatCard(
            context,
            'Resolved',
            resolvedCount.toString(),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
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
