import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_state.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsPage extends StatefulWidget {
  final UserEntity user;

  const UserDetailsPage({super.key, required this.user});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late UserEntity _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
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
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            const Text('User Details'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'verify':
                  _showVerifyDialog(context);
                  break;
                case 'ban':
                  _showBanDialog(context);
                  break;
                case 'warn':
                  _showWarnDialog(context);
                  break;
                case 'violation_history':
                  context.read<AdminUserManagementBloc>().add(
                    LoadUserViolationHistory(_currentUser.id),
                  );
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!_currentUser.isVerified)
                const PopupMenuItem(
                  value: 'verify',
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 20, color: AppColors.success),
                      SizedBox(width: UIConstants.spacingSm),
                      Text('Verify User'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'ban',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20, color: AppColors.error),
                    SizedBox(width: UIConstants.spacingSm),
                    Text('Ban User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'warn',
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 20, color: AppColors.warning),
                    SizedBox(width: UIConstants.spacingSm),
                    Text('Warn User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'violation_history',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20),
                    SizedBox(width: UIConstants.spacingSm),
                    Text('Violation History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppColors.error),
                    SizedBox(width: UIConstants.spacingSm),
                    Text('Delete Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<AdminUserManagementBloc, AdminUserManagementState>(
        listener: (context, state) {
          if (state is UserOperationSuccess) {
            // Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Navigate back after showing snackbar, then user list will reload automatically
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Navigator.of(
                  context,
                ).pop(true); // Return true to indicate success
              }
            });
          } else if (state is AdminUserManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is UserViolationHistoryLoaded) {
            _showViolationHistoryDialog(context, state.violations);
          }
        },
        buildWhen: (previous, current) {
          // Only rebuild when loading state changes
          if (current is AdminUserManagementLoading) return true;
          if (previous is AdminUserManagementLoading &&
              current is! AdminUserManagementLoading)
            return true;
          return false;
        },
        builder: (context, state) {
          // Show loading indicator while loading
          if (state is AdminUserManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: UIConstants.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(context),
                const SizedBox(height: UIConstants.spacingLg),
                _buildUserInfoSection(context),
                const SizedBox(height: UIConstants.spacingLg),
                _buildPreferencesSection(context),
                const SizedBox(height: UIConstants.spacingLg),
                _buildActivitySection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadiusLg),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: UIConstants.paddingLg,
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _currentUser.profileImageUrl != null
                  ? NetworkImage(_currentUser.profileImageUrl!)
                  : null,
              child: _currentUser.profileImageUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: UIConstants.spacingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  Text(
                    _currentUser.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorsExtension.getTextSecondary(context),
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _currentUser.isVerified
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _currentUser.isVerified
                                  ? Icons.verified
                                  : Icons.pending,
                              size: 14,
                              color: _currentUser.isVerified
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentUser.isVerified
                                  ? 'Verified'
                                  : 'Unverified',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _currentUser.isVerified
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(
                            _currentUser.role,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentUser.role.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _getRoleColor(_currentUser.role),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadiusLg),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: UIConstants.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            _buildInfoRow(context, 'User ID', _currentUser.id),
            _buildInfoRow(context, 'Email', _currentUser.email),
            _buildInfoRow(context, 'Name', _currentUser.name),
            _buildInfoRow(
              context,
              'Role',
              _currentUser.role,
              valueColor: _getRoleColor(_currentUser.role),
            ),
            _buildInfoRow(
              context,
              'Verification Status',
              _currentUser.isVerified ? 'Verified' : 'Unverified',
              valueColor: _currentUser.isVerified
                  ? AppColors.success
                  : AppColors.warning,
            ),
            _buildInfoRow(
              context,
              'Created At',
              _formatDate(_currentUser.createdAt),
            ),
            _buildInfoRow(
              context,
              'Last Updated',
              _formatDate(_currentUser.updatedAt),
            ),
            if (_currentUser.profileImageUrl != null)
              _buildInfoRow(
                context,
                'Profile Image',
                _currentUser.profileImageUrl!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadiusLg),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: UIConstants.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            _buildInfoRow(
              context,
              'Cultural Background',
              _currentUser.culturalBackground,
            ),
            _buildInfoRow(
              context,
              'Spice Tolerance',
              '${(_currentUser.spiceTolerance * 100).toStringAsFixed(0)}%',
            ),
            if (_currentUser.dietaryRestrictions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        'Dietary Restrictions:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: UIConstants.spacingXs,
                        runSpacing: UIConstants.spacingXs,
                        children: _currentUser.dietaryRestrictions.map((
                          restriction,
                        ) {
                          return Chip(
                            label: Text(restriction),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: AppColors.primary,
                              fontSize: UIConstants.fontSizeSm,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            if (_currentUser.cuisinePreferences.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuisine Preferences:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXs),
                    Wrap(
                      spacing: UIConstants.spacingXs,
                      runSpacing: UIConstants.spacingXs,
                      children: _currentUser.cuisinePreferences.entries.map((
                        entry,
                      ) {
                        return Chip(
                          label: Text(
                            '${entry.key}: ${(entry.value * 100).toStringAsFixed(0)}%',
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: AppColors.primary,
                            fontSize: UIConstants.fontSizeSm,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            _buildInfoRow(
              context,
              'Location',
              '${_currentUser.currentLocation.city ?? 'N/A'}, ${_currentUser.currentLocation.state ?? 'N/A'}',
            ),
            if (_currentUser.currentLocation.address != null)
              _buildInfoRow(
                context,
                'Address',
                _currentUser.currentLocation.address!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadiusLg),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: UIConstants.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            if (_currentUser.behaviorPatterns.isNotEmpty)
              ..._currentUser.behaviorPatterns.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key.replaceAll('_', ' ').toUpperCase(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: AppColors.grey200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingSm),
                      Text(
                        '${(entry.value * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              })
            else
              Text(
                'No activity data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorsExtension.getTextSecondary(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColorsExtension.getTextSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'vendor':
        return AppColors.warning;
      case 'user':
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showVerifyDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Do you want to verify this user account?'),
            const SizedBox(height: UIConstants.spacingMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminUserManagementBloc>().add(
                VerifyUser(
                  userId: _currentUser.id,
                  reason: reasonController.text.isEmpty
                      ? null
                      : reasonController.text,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to ban this user?'),
            const SizedBox(height: UIConstants.spacingMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason (required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: reasonController.text.isEmpty
                ? null
                : () {
                    Navigator.pop(context);
                    context.read<AdminUserManagementBloc>().add(
                      BanUser(
                        userId: _currentUser.id,
                        reason: reasonController.text,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Ban'),
          ),
        ],
      ),
    );
  }

  void _showWarnDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warn User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send a warning to this user'),
            const SizedBox(height: UIConstants.spacingMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Warning reason (required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: reasonController.text.isEmpty
                ? null
                : () {
                    Navigator.pop(context);
                    context.read<AdminUserManagementBloc>().add(
                      WarnUser(
                        userId: _currentUser.id,
                        reason: reasonController.text,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Warn'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: UIConstants.spacingSm),
            Text('Delete User Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action will permanently delete user data (PDPA compliance). This cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.spacingMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Deletion reason (required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: reasonController.text.isEmpty
                ? null
                : () {
                    Navigator.pop(context);
                    context.read<AdminUserManagementBloc>().add(
                      DeleteUserData(
                        userId: _currentUser.id,
                        reason: reasonController.text,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showViolationHistoryDialog(
    BuildContext context,
    List<Map<String, dynamic>> violations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Violation History'),
        content: SizedBox(
          width: double.maxFinite,
          child: violations.isEmpty
              ? const Center(child: Text('No violations found'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: violations.length,
                  itemBuilder: (context, index) {
                    final violation = violations[index];
                    return ListTile(
                      title: Text(violation['action'] ?? 'Unknown'),
                      subtitle: Text(
                        violation['reason'] ?? 'No reason provided',
                      ),
                      trailing: violation['timestamp'] != null
                          ? Text(
                              _formatDate(
                                violation['timestamp'] is Timestamp
                                    ? (violation['timestamp'] as Timestamp)
                                          .toDate()
                                    : DateTime.parse(
                                        violation['timestamp'].toString(),
                                      ),
                              ),
                            )
                          : null,
                    );
                  },
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
}
