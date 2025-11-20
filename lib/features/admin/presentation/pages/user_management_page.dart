import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/presentation/widgets/3d_card.dart';
import 'package:makan_mate/features/admin/presentation/utils/admin_utils.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_state.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_state.dart';
import 'package:makan_mate/features/reviews/domain/entities/admin_review_entity.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/user_ban_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/support_ticket_entity.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_support_ticket_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_support_ticket_state.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_support_ticket_event.dart';
import 'package:makan_mate/core/di/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:makan_mate/features/admin/presentation/pages/user_details_page.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_analytics_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_analytics_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_analytics_state.dart';

/// High-level admin console for managing end users, reviews, bans, tickets, analytics.
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
                    : [Colors.white, Colors.white.withValues(alpha: 0.95)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
              const SizedBox(width: UIConstants.spacingSm),
              Text(
                'User Management',
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
                  AdminUtils.showLogoutDialog(context);
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
                        ? Colors.white.withValues(alpha: 0.1)
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
        body: TabBarView(
          children: [
            const _AllUsersTab(),
            const _ReviewModerationTab(),
            const _BansWarningsTab(),
            BlocProvider<AdminSupportTicketBloc>(
              create: (_) => sl<AdminSupportTicketBloc>(),
              child: const _SupportTicketsTab(),
            ),
            BlocProvider<AdminUserAnalyticsBloc>(
              create: (_) => sl<AdminUserAnalyticsBloc>(),
              child: const _AnalyticsTab(),
            ),
          ],
        ),
      ),
    );
  }
}

// region: Tab 1 – master user directory with search/filter/export
class _AllUsersTab extends StatefulWidget {
  const _AllUsersTab();

  @override
  State<_AllUsersTab> createState() => _AllUsersTabState();
}

class _AllUsersTabState extends State<_AllUsersTab>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _filterRole;
  bool? _filterVerificationStatus;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  bool _hasActiveFilters = false;
  List<UserEntity> _users = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load users when tab is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminUserManagementBloc>().add(const LoadUsers());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Keeps pill indicator in sync so UI knows filters are active.
  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _filterRole != null ||
          _filterVerificationStatus != null ||
          _filterDateFrom != null ||
          _filterDateTo != null ||
          _searchQuery.isNotEmpty;
    });
  }

  // Resets every filter/search field and refreshes full list.
  void _clearFilters() {
    setState(() {
      _filterRole = null;
      _filterVerificationStatus = null;
      _filterDateFrom = null;
      _filterDateTo = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  // Applies search + role + verification + date filters to cached users.
  List<UserEntity> get _filteredUsers {
    // Use _users if available, otherwise return empty list
    if (_users.isEmpty) return [];
    var filtered = List<UserEntity>.from(_users);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.role.toLowerCase().contains(query);
      }).toList();
    }

    // Role filter
    if (_filterRole != null) {
      filtered = filtered.where((user) => user.role == _filterRole).toList();
    }

    // Verification status filter
    if (_filterVerificationStatus != null) {
      filtered = filtered
          .where((user) => user.isVerified == _filterVerificationStatus)
          .toList();
    }

    // Date range filter
    if (_filterDateFrom != null) {
      filtered = filtered
          .where(
            (user) =>
                user.createdAt.isAfter(_filterDateFrom!) ||
                user.createdAt.isAtSameMomentAs(_filterDateFrom!),
          )
          .toList();
    }
    if (_filterDateTo != null) {
      filtered = filtered
          .where(
            (user) =>
                user.createdAt.isBefore(_filterDateTo!) ||
                user.createdAt.isAtSameMomentAs(_filterDateTo!),
          )
          .toList();
    }

    return filtered;
  }

  // Launches modal with role/status/date controls; applies on save.
  void _showFilterDialog(BuildContext context) {
    String? tempFilterRole = _filterRole;
    bool? tempFilterVerificationStatus = _filterVerificationStatus;
    DateTime? tempFilterDateFrom = _filterDateFrom;
    DateTime? tempFilterDateTo = _filterDateTo;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Users'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Filter
                Text(
                  'Role',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempFilterRole,
                  decoration: const InputDecoration(
                    hintText: 'Select role',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Roles'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'user',
                      child: Text('User'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'vendor',
                      child: Text('Vendor'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempFilterRole = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Verification Status Filter
                Text(
                  'Verification Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<bool>(
                  value: tempFilterVerificationStatus,
                  decoration: const InputDecoration(
                    hintText: 'Select verification status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<bool>(
                      value: null,
                      child: Text('All Users'),
                    ),
                    const DropdownMenuItem<bool>(
                      value: true,
                      child: Text('Verified'),
                    ),
                    const DropdownMenuItem<bool>(
                      value: false,
                      child: Text('Not Verified'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempFilterVerificationStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Date Range Filter
                Text(
                  'Account Created Date Range',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempFilterDateFrom ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              tempFilterDateFrom = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          tempFilterDateFrom != null
                              ? '${tempFilterDateFrom!.day}/${tempFilterDateFrom!.month}/${tempFilterDateFrom!.year}'
                              : 'From Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempFilterDateTo ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              tempFilterDateTo = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          tempFilterDateTo != null
                              ? '${tempFilterDateTo!.day}/${tempFilterDateTo!.month}/${tempFilterDateTo!.year}'
                              : 'To Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (tempFilterDateFrom != null || tempFilterDateTo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          tempFilterDateFrom = null;
                          tempFilterDateTo = null;
                        });
                      },
                      child: const Text('Clear Date Range'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempFilterRole = null;
                  tempFilterVerificationStatus = null;
                  tempFilterDateFrom = null;
                  tempFilterDateTo = null;
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
                  _filterRole = tempFilterRole;
                  _filterVerificationStatus = tempFilterVerificationStatus;
                  _filterDateFrom = tempFilterDateFrom;
                  _filterDateTo = tempFilterDateTo;
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AdminUserManagementBloc, AdminUserManagementState>(
      listener: (context, state) {
        // Handle any side effects if needed
        if (state is UsersLoaded) {
          setState(() {
            _users = state.users;
          });
        }
      },
      builder: (context, state) {
        // Only show blocking loader when no cached users
        if (state is AdminUserManagementLoading && _users.isEmpty) {
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

        // If we have newly loaded users OR a cached list, show the list
        if (state is UsersLoaded || _users.isNotEmpty) {
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
                          ? Colors.white.withValues(alpha: 0.1)
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
                          hintText: 'Search users...',
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
                      tooltip: 'Filter users',
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
              // Users List
              Expanded(
                child: _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasActiveFilters || _searchQuery.isNotEmpty
                                  ? Icons.filter_alt_off_rounded
                                  : Icons.people_outline_rounded,
                              size: 64,
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingMd),
                            Text(
                              _hasActiveFilters || _searchQuery.isNotEmpty
                                  ? 'No users match your filters'
                                  : 'No users found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColorsExtension.getTextSecondary(
                                      context,
                                    ),
                                  ),
                            ),
                            if (_hasActiveFilters ||
                                _searchQuery.isNotEmpty) ...[
                              const SizedBox(height: UIConstants.spacingMd),
                              OutlinedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_rounded),
                                label: const Text('Clear filters'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<AdminUserManagementBloc>().add(
                            const LoadUsers(),
                          );
                        },
                        child: Column(
                          children: [
                            if (_hasActiveFilters || _searchQuery.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                color: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : AppColors.grey50,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color:
                                          AppColorsExtension.getTextSecondary(
                                            context,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_filteredUsers.length} of ${_users.length} users',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
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
                            Expanded(
                              child: ListView.builder(
                                padding: UIConstants.paddingLg,
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return Card(
                                    margin: const EdgeInsets.only(
                                      bottom: UIConstants.spacingMd,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            user.profileImageUrl != null
                                            ? NetworkImage(
                                                user.profileImageUrl!,
                                              )
                                            : null,
                                        child: user.profileImageUrl == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      title: Text(
                                        user.name,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.email,
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              if (user.isBanned)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.error
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'BANNED',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              AppColors.error,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  user.role.toUpperCase(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                              if (user.isVerified)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.verified,
                                                      size: 14,
                                                      color: AppColors.success,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Verified',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: AppColors
                                                                .success,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          if (user.isBanned) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.block_rounded,
                                                  size: 14,
                                                  color: AppColors.error,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Builder(
                                                    builder: (context) {
                                                      if (user.bannedUntil ==
                                                          null) {
                                                        return Text(
                                                          'Banned (Permanent)',
                                                          softWrap: true,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                color: AppColors
                                                                    .error,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        );
                                                      }
                                                      final now =
                                                          DateTime.now();
                                                      final expires =
                                                          user.bannedUntil!;
                                                      final diff = expires
                                                          .difference(now)
                                                          .inDays;
                                                      final text = diff <= 0
                                                          ? 'Banned (expires today - ${AdminUtils.formatDate(expires)})'
                                                          : 'Banned • $diff day${diff == 1 ? '' : 's'} left (${AdminUtils.formatDate(expires)})';
                                                      return Text(
                                                        text,
                                                        softWrap: true,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: AppColors
                                                                  .error,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                                        await Future.delayed(
                                          const Duration(milliseconds: 100),
                                        );
                                        if (context.mounted) {
                                          context
                                              .read<AdminUserManagementBloc>()
                                              .add(const LoadUsers());
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        }

        // Initial state - show loading while data is being fetched (no cache yet)
        if (state is AdminUserManagementInitial && _users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // If state is UserOperationSuccess, trigger a reload but show the cached users
        if (state is UserOperationSuccess) {
          // Trigger reload to get fresh data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<AdminUserManagementBloc>().add(const LoadUsers());
            }
          });
          // If we have cached users, show them while reloading
          if (_users.isNotEmpty) {
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
                            ? Colors.white.withValues(alpha: 0.1)
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
                            hintText: 'Search users...',
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
                                  : AppColorsExtension.getTextSecondary(
                                      context,
                                    ),
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
                        tooltip: 'Filter users',
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
                // Show cached users with a loading indicator
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminUserManagementBloc>().add(
                        const LoadUsers(),
                      );
                    },
                    child: Stack(
                      children: [
                        ListView.builder(
                          padding: UIConstants.paddingLg,
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: UIConstants.spacingMd,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.profileImageUrl != null
                                      ? NetworkImage(user.profileImageUrl!)
                                      : null,
                                  child: user.profileImageUrl == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(
                                  user.name,
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.email,
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        if (user.isBanned)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.error
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'BANNED',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.error,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            user.role.toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        if (user.isVerified)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.verified,
                                                size: 14,
                                                color: AppColors.success,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Verified',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors.success,
                                                    ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await Navigator.of(
                                    context,
                                  ).pushNamed('/userDetails', arguments: user);
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          // Show loading while reloading if no cached users
          return const Center(child: CircularProgressIndicator());
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// region: Tab 2 – human-in-the-loop review moderation queue
class _ReviewModerationTab extends StatefulWidget {
  const _ReviewModerationTab();

  @override
  State<_ReviewModerationTab> createState() => _ReviewModerationTabState();
}

class _ReviewModerationTabState extends State<_ReviewModerationTab>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter state - related to review features
  bool? _filterFlaggedStatus;
  String? _filterFlagReason;
  double? _filterMinRating;
  double? _filterMaxRating;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  String? _filterVendorName;
  String? _filterUserName;

  bool _hasActiveFilters = false;
  List<AdminReviewEntity> _reviews = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load reviews when tab is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminReviewManagementBloc>().add(
          const LoadFlaggedReviews(),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _filterFlaggedStatus != null ||
          _filterFlagReason != null ||
          _filterMinRating != null ||
          _filterMaxRating != null ||
          _filterDateFrom != null ||
          _filterDateTo != null ||
          _filterVendorName != null ||
          _filterUserName != null ||
          _searchQuery.isNotEmpty;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterFlaggedStatus = null;
      _filterFlagReason = null;
      _filterMinRating = null;
      _filterMaxRating = null;
      _filterDateFrom = null;
      _filterDateTo = null;
      _filterVendorName = null;
      _filterUserName = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  List<AdminReviewEntity> get _filteredReviews {
    var filtered = List<AdminReviewEntity>.from(_reviews);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((review) {
        return (review.comment.toLowerCase().contains(query)) ||
            (review.vendorName?.toLowerCase().contains(query) ?? false) ||
            (review.userName?.toLowerCase().contains(query) ?? false) ||
            (review.flagReason?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Flagged status filter
    if (_filterFlaggedStatus != null) {
      filtered = filtered
          .where((review) => review.flagged == _filterFlaggedStatus)
          .toList();
    }

    // Flag reason filter
    if (_filterFlagReason != null && _filterFlagReason!.isNotEmpty) {
      filtered = filtered
          .where((review) => review.flagReason == _filterFlagReason)
          .toList();
    }

    // Rating filter
    if (_filterMinRating != null) {
      filtered = filtered
          .where((review) => review.rating >= _filterMinRating!)
          .toList();
    }
    if (_filterMaxRating != null) {
      filtered = filtered
          .where((review) => review.rating <= _filterMaxRating!)
          .toList();
    }

    // Date range filter
    if (_filterDateFrom != null) {
      filtered = filtered
          .where(
            (review) =>
                review.createdAt.isAfter(_filterDateFrom!) ||
                review.createdAt.isAtSameMomentAs(_filterDateFrom!),
          )
          .toList();
    }
    if (_filterDateTo != null) {
      filtered = filtered
          .where(
            (review) =>
                review.createdAt.isBefore(_filterDateTo!) ||
                review.createdAt.isAtSameMomentAs(_filterDateTo!),
          )
          .toList();
    }

    // Vendor name filter
    if (_filterVendorName != null && _filterVendorName!.isNotEmpty) {
      filtered = filtered
          .where(
            (review) =>
                review.vendorName?.toLowerCase() ==
                _filterVendorName!.toLowerCase(),
          )
          .toList();
    }

    // User name filter
    if (_filterUserName != null && _filterUserName!.isNotEmpty) {
      filtered = filtered
          .where(
            (review) =>
                review.userName?.toLowerCase() ==
                _filterUserName!.toLowerCase(),
          )
          .toList();
    }

    return filtered;
  }

  void _showFilterDialog(BuildContext context) {
    bool? tempFilterFlaggedStatus = _filterFlaggedStatus;
    String? tempFilterFlagReason = _filterFlagReason;
    double? tempFilterMinRating = _filterMinRating;
    double? tempFilterMaxRating = _filterMaxRating;
    DateTime? tempFilterDateFrom = _filterDateFrom;
    DateTime? tempFilterDateTo = _filterDateTo;
    String? tempFilterVendorName = _filterVendorName;
    String? tempFilterUserName = _filterUserName;

    // Get unique flag reasons from reviews
    final flagReasons = _reviews
        .where((r) => r.flagReason != null && r.flagReason!.isNotEmpty)
        .map((r) => r.flagReason!)
        .toSet()
        .toList();

    // Get unique vendor names
    final vendorNames =
        _reviews
            .where((r) => r.vendorName != null && r.vendorName!.isNotEmpty)
            .map((r) => r.vendorName!)
            .toSet()
            .toList()
          ..sort();

    // Get unique user names
    final userNames =
        _reviews
            .where((r) => r.userName != null && r.userName!.isNotEmpty)
            .map((r) => r.userName!)
            .toSet()
            .toList()
          ..sort();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Reviews'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flagged Status Filter
                Text(
                  'Flagged Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<bool>(
                  value: tempFilterFlaggedStatus,
                  decoration: const InputDecoration(
                    hintText: 'Select flagged status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<bool>(
                      value: null,
                      child: Text('All Reviews'),
                    ),
                    const DropdownMenuItem<bool>(
                      value: true,
                      child: Text('Flagged'),
                    ),
                    const DropdownMenuItem<bool>(
                      value: false,
                      child: Text('Not Flagged'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempFilterFlaggedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Flag Reason Filter
                if (flagReasons.isNotEmpty) ...[
                  Text(
                    'Flag Reason',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempFilterFlagReason,
                    decoration: const InputDecoration(
                      hintText: 'Select flag reason',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Reasons'),
                      ),
                      ...flagReasons.map(
                        (reason) => DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tempFilterFlagReason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Rating Filter
                Text(
                  'Rating Range',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: tempFilterMinRating?.toString() ?? '',
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Min Rating',
                          border: OutlineInputBorder(),
                          hintText: '0.0',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final rating = double.tryParse(value);
                          setState(() {
                            tempFilterMinRating = rating;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: tempFilterMaxRating?.toString() ?? '',
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Max Rating',
                          border: OutlineInputBorder(),
                          hintText: '5.0',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final rating = double.tryParse(value);
                          setState(() {
                            tempFilterMaxRating = rating;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Vendor Name Filter
                if (vendorNames.isNotEmpty) ...[
                  Text(
                    'Vendor',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempFilterVendorName,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Select vendor',
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
                          'All Vendors',
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                      ...vendorNames.map(
                        (name) => DropdownMenuItem<String>(
                          value: name,
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ],
                    selectedItemBuilder: (context) {
                      final names = [null, ...vendorNames];
                      return names.map((n) {
                        final label = n ?? 'All Vendors';
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        );
                      }).toList();
                    },
                    onChanged: (value) {
                      setState(() {
                        tempFilterVendorName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // User Name Filter
                if (userNames.isNotEmpty) ...[
                  Text(
                    'User',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempFilterUserName,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Select user',
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
                          'All Users',
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                      ...userNames.map(
                        (name) => DropdownMenuItem<String>(
                          value: name,
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ],
                    selectedItemBuilder: (context) {
                      final names = [null, ...userNames];
                      return names.map((n) {
                        final label = n ?? 'All Users';
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        );
                      }).toList();
                    },
                    onChanged: (value) {
                      setState(() {
                        tempFilterUserName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Date Range Filter
                Text(
                  'Review Date Range',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempFilterDateFrom ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              tempFilterDateFrom = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          tempFilterDateFrom != null
                              ? '${tempFilterDateFrom!.day}/${tempFilterDateFrom!.month}/${tempFilterDateFrom!.year}'
                              : 'From Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempFilterDateTo ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              tempFilterDateTo = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          tempFilterDateTo != null
                              ? '${tempFilterDateTo!.day}/${tempFilterDateTo!.month}/${tempFilterDateTo!.year}'
                              : 'To Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (tempFilterDateFrom != null || tempFilterDateTo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          tempFilterDateFrom = null;
                          tempFilterDateTo = null;
                        });
                      },
                      child: const Text('Clear Date Range'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempFilterFlaggedStatus = null;
                  tempFilterFlagReason = null;
                  tempFilterMinRating = null;
                  tempFilterMaxRating = null;
                  tempFilterDateFrom = null;
                  tempFilterDateTo = null;
                  tempFilterVendorName = null;
                  tempFilterUserName = null;
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
                  _filterFlaggedStatus = tempFilterFlaggedStatus;
                  _filterFlagReason = tempFilterFlagReason;
                  _filterMinRating = tempFilterMinRating;
                  _filterMaxRating = tempFilterMaxRating;
                  _filterDateFrom = tempFilterDateFrom;
                  _filterDateTo = tempFilterDateTo;
                  _filterVendorName = tempFilterVendorName;
                  _filterUserName = tempFilterUserName;
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        // Update reviews list when loaded
        if (state is ReviewsLoaded) {
          setState(() {
            _reviews = state.reviews;
          });
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

        // Load reviews on initial build
        if (state is AdminReviewManagementInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle ReviewOperationSuccess by keeping cached reviews while reloading
        if (state is ReviewOperationSuccess) {
          // Already handled in listener - just show the cached reviews if available
          if (_reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
        }

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
                        ? Colors.white.withValues(alpha: 0.1)
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
                        hintText: 'Search reviews...',
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
                    tooltip: 'Filter reviews',
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
            // Reviews List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<AdminReviewManagementBloc>().add(
                    const LoadFlaggedReviews(),
                  );
                },
                child: _filteredReviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasActiveFilters || _searchQuery.isNotEmpty
                                  ? Icons.filter_alt_off_rounded
                                  : Icons.rate_review_outlined,
                              size: 64,
                              color: AppColorsExtension.getTextSecondary(
                                context,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingMd),
                            Text(
                              _hasActiveFilters || _searchQuery.isNotEmpty
                                  ? 'No reviews match your filters'
                                  : 'No flagged reviews',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColorsExtension.getTextSecondary(
                                      context,
                                    ),
                                  ),
                            ),
                            if (_hasActiveFilters ||
                                _searchQuery.isNotEmpty) ...[
                              const SizedBox(height: UIConstants.spacingMd),
                              OutlinedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_rounded),
                                label: const Text('Clear filters'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          if (_hasActiveFilters || _searchQuery.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : AppColors.grey50,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: AppColorsExtension.getTextSecondary(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_filteredReviews.length} of ${_reviews.length} reviews',
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
                          Expanded(
                            child: ListView(
                              padding: UIConstants.paddingLg,
                              children: [
                                _buildStatsRow(context, _filteredReviews),
                                const SizedBox(height: UIConstants.spacingLg),
                                ..._filteredReviews.map(
                                  (review) => _buildReviewCard(context, review),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
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
                ? AppColors.error.withValues(alpha: 0.3)
                : AppColors.grey200.withValues(alpha: 0.3),
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
                              .withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isFlagged
                          ? Icons.flag_rounded
                          : Icons.rate_review_rounded,
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
                      ? Colors.white.withValues(alpha: 0.05)
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
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                AdminUtils.formatDate(review.createdAt),
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
                      review.comment,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (review.flagReason != null) ...[
                      const SizedBox(height: UIConstants.spacingSm),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
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
          child: AdminUtils.buildStatCard(
            context,
            'Flagged',
            flaggedCount.toString(),
            Icons.flag_rounded,
            AppColors.error,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: AdminUtils.buildStatCard(
            context,
            'Pending',
            pendingCount.toString(),
            Icons.pending_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: AdminUtils.buildStatCard(
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
}

// region: Tab 3 – ban history + warning issuance workflow
class _BansWarningsTab extends StatefulWidget {
  const _BansWarningsTab();

  @override
  State<_BansWarningsTab> createState() => _BansWarningsTabState();
}

class _BansWarningsTabState extends State<_BansWarningsTab>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _filterType; // 'ban' or 'warning'
  bool? _filterActive;
  String? _filterReason;

  bool _hasActiveFilters = false;
  List<UserBanEntity> _bansWarnings = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load bans/warnings when tab is first created using BLoC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserManagementBloc>().add(const LoadBansAndWarnings());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadBansWarnings() {
    // Reload data from BLoC
    context.read<AdminUserManagementBloc>().add(
      LoadBansAndWarnings(type: _filterType, isActive: _filterActive),
    );
  }

  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _filterType != null ||
          _filterActive != null ||
          _filterReason != null ||
          _searchQuery.isNotEmpty;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterType = null;
      _filterActive = null;
      _filterReason = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  List<UserBanEntity> get _filteredBansWarnings {
    var filtered = List<UserBanEntity>.from(_bansWarnings);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.userName.toLowerCase().contains(query) ||
            item.reason.toLowerCase().contains(query) ||
            (item.userEmail?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Type filter
    if (_filterType != null) {
      filtered = filtered.where((item) => item.type == _filterType).toList();
    }

    // Active status filter
    if (_filterActive != null) {
      filtered = filtered
          .where((item) => item.isActive == _filterActive)
          .toList();
    }

    // Reason filter
    if (_filterReason != null) {
      filtered = filtered
          .where((item) => item.reason == _filterReason)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AdminUserManagementBloc, AdminUserManagementState>(
      listener: (context, state) {
        if (state is AdminUserManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is UserOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload data after successful operation
          _loadBansWarnings();
          // Also refresh the All Users list to reflect latest status
          context.read<AdminUserManagementBloc>().add(const LoadUsers());
        }
      },
      builder: (context, state) {
        // Update local list when bans/warnings are loaded
        if (state is BansAndWarningsLoaded) {
          _bansWarnings = state.bansAndWarnings;
        }

        // Show loading indicator during initial load
        if (state is AdminUserManagementLoading && _bansWarnings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show loading indicator for initial state
        if (state is AdminUserManagementInitial) {
          return const Center(child: CircularProgressIndicator());
        }

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
                        ? Colors.white.withValues(alpha: 0.1)
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
                        hintText: 'Search bans/warnings...',
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
                    tooltip: 'Filter',
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
            // Stats Row
            if (_bansWarnings.isNotEmpty)
              Padding(
                padding: UIConstants.paddingMd,
                child: _buildStatsRow(context),
              ),
            // List
            Expanded(
              child: _filteredBansWarnings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasActiveFilters || _searchQuery.isNotEmpty
                                ? Icons.filter_alt_off_rounded
                                : Icons.block_rounded,
                            size: 64,
                            color: AppColorsExtension.getTextSecondary(context),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          Text(
                            _hasActiveFilters || _searchQuery.isNotEmpty
                                ? 'No results match your filters'
                                : 'No bans or warnings',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColorsExtension.getTextSecondary(
                                    context,
                                  ),
                                ),
                          ),
                          if (_hasActiveFilters || _searchQuery.isNotEmpty) ...[
                            const SizedBox(height: UIConstants.spacingMd),
                            OutlinedButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.clear_rounded),
                              label: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _loadBansWarnings();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: UIConstants.paddingLg,
                        itemCount: _filteredBansWarnings.length,
                        itemBuilder: (context, index) {
                          final item = _filteredBansWarnings[index];
                          return _buildBanWarningCard(context, item);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final activeBans = _bansWarnings.where((b) => b.isBan && b.isActive).length;
    final activeWarnings = _bansWarnings
        .where((b) => b.isWarning && b.isActive)
        .length;
    final expired = _bansWarnings.where((b) => !b.isActive).length;

    return Row(
      children: [
        Expanded(
          child: AdminUtils.buildStatCard(
            context,
            'Active Bans',
            activeBans.toString(),
            Icons.block_rounded,
            AppColors.error,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: AdminUtils.buildStatCard(
            context,
            'Warnings',
            activeWarnings.toString(),
            Icons.warning_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: AdminUtils.buildStatCard(
            context,
            'Expired',
            expired.toString(),
            Icons.check_circle_rounded,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildBanWarningCard(BuildContext context, UserBanEntity item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBan = item.isBan;

    return Card3D(
      child: Container(
        margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
          border: Border.all(
            color: item.isActive
                ? (isBan ? AppColors.error : AppColors.warning).withValues(alpha: 0.3)
                : AppColors.grey300.withValues(alpha: 0.3),
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
                          isBan ? AppColors.error : AppColors.warning,
                          (isBan ? AppColors.error : AppColors.warning)
                              .withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isBan ? Icons.block_rounded : Icons.warning_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.userName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: item.isActive
                                    ? (isBan
                                              ? AppColors.error
                                              : AppColors.warning)
                                          .withValues(alpha: 0.1)
                                    : AppColors.grey300.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isBan ? 'BAN' : 'WARNING',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: item.isActive
                                          ? (isBan
                                                ? AppColors.error
                                                : AppColors.warning)
                                          : AppColors.grey600,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.userEmail ?? 'No email',
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
                  if (!item.isActive)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMd),
              Container(
                padding: UIConstants.paddingSm,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: AppColorsExtension.getTextSecondary(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reason: ${item.reason}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (item.details != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.details!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColorsExtension.getTextSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${AdminUtils.formatDate(item.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColorsExtension.getTextSecondary(
                                  context,
                                ),
                              ),
                        ),
                      ],
                    ),
                    if (item.expiresAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 14,
                            color: item.isExpired
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Builder(
                            builder: (context) {
                              final now = DateTime.now();
                              final expires = item.expiresAt!;
                              final diff = expires.difference(now).inDays;
                              final text = item.isExpired
                                  ? 'Expired: ${AdminUtils.formatDate(expires)}'
                                  : (diff <= 0
                                        ? 'Expires today (${AdminUtils.formatDate(expires)})'
                                        : 'Expires in $diff day${diff == 1 ? '' : 's'} (${AdminUtils.formatDate(expires)})');
                              return Text(
                                text,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: item.isExpired
                                          ? AppColors.success
                                          : AppColors.warning,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.all_inclusive,
                            size: 14,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Permanent',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                    if (item.adminName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: AppColorsExtension.getTextSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'By: ${item.adminName}',
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
                  ],
                ),
              ),
              const SizedBox(height: UIConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Fetch user details and navigate to details page
                        final repo = sl<AdminUserRepository>();
                        final result = await repo.getUserById(item.userId);
                        result.fold(
                          (failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to load user: ${failure.message}',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          },
                          (userEntity) {
                            if (userEntity == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User not found'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context
                                      .read<AdminUserManagementBloc>(),
                                  child: UserDetailsPage(user: userEntity),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.person_rounded, size: 18),
                      label: const Text('View User'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingMd),
                  if (item.isActive)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement lift ban/warning
                          _showLiftDialog(context, item);
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(isBan ? 'Lift Ban' : 'Remove Warning'),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? tempFilterType = _filterType;
    bool? tempFilterActive = _filterActive;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Bans & Warnings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempFilterType,
                decoration: const InputDecoration(
                  hintText: 'Select type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem<String>(value: null, child: Text('All')),
                  DropdownMenuItem<String>(value: 'ban', child: Text('Bans')),
                  DropdownMenuItem<String>(
                    value: 'warning',
                    child: Text('Warnings'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => tempFilterType = value);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Status',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<bool>(
                value: tempFilterActive,
                decoration: const InputDecoration(
                  hintText: 'Select status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem<bool>(value: null, child: Text('All')),
                  DropdownMenuItem<bool>(value: true, child: Text('Active')),
                  DropdownMenuItem<bool>(value: false, child: Text('Expired')),
                ],
                onChanged: (value) {
                  setState(() => tempFilterActive = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempFilterType = null;
                  tempFilterActive = null;
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
                this.setState(() {
                  _filterType = tempFilterType;
                  _filterActive = tempFilterActive;
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

  void _showLiftDialog(BuildContext context, UserBanEntity item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Lift ${item.isBan ? "Ban" : "Warning"}'),
        content: Text(
          'Are you sure you want to lift this ${item.isBan ? "ban" : "warning"} for ${item.userName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Lift ban/warning via BLoC
              context.read<AdminUserManagementBloc>().add(
                LiftBanOrWarning(
                  banId: item.id,
                  reason:
                      'Admin lifted ${item.isBan ? "ban" : "warning"} manually',
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lift'),
          ),
        ],
      ),
    );
  }
}

// region: Tab 4 – support ticket triage dashboard
class _SupportTicketsTab extends StatefulWidget {
  const _SupportTicketsTab();

  @override
  State<_SupportTicketsTab> createState() => _SupportTicketsTabState();
}

class _SupportTicketsTabState extends State<_SupportTicketsTab>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _filterStatus;
  String? _filterPriority;
  String? _filterCategory;

  bool _hasActiveFilters = false;
  List<SupportTicketEntity> _tickets = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load tickets when tab is first created via BLoC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminSupportTicketBloc>().add(const LoadSupportTickets());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    context.read<AdminSupportTicketBloc>().add(
      LoadSupportTickets(
        status: _filterStatus,
        priority: _filterPriority,
        category: _filterCategory,
      ),
    );
  }

  void _updateFilterState() {
    setState(() {
      _hasActiveFilters =
          _filterStatus != null ||
          _filterPriority != null ||
          _filterCategory != null ||
          _searchQuery.isNotEmpty;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterStatus = null;
      _filterPriority = null;
      _filterCategory = null;
      _searchQuery = '';
      _searchController.clear();
      _hasActiveFilters = false;
    });
  }

  List<SupportTicketEntity> get _filteredTickets {
    var filtered = List<SupportTicketEntity>.from(_tickets);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((ticket) {
        return ticket.subject.toLowerCase().contains(query) ||
            ticket.userName.toLowerCase().contains(query) ||
            (ticket.userEmail?.toLowerCase().contains(query) ?? false) ||
            ticket.message.toLowerCase().contains(query);
      }).toList();
    }

    // Status filter
    if (_filterStatus != null) {
      filtered = filtered
          .where((ticket) => ticket.status == _filterStatus)
          .toList();
    }

    // Priority filter
    if (_filterPriority != null) {
      filtered = filtered
          .where((ticket) => ticket.priority == _filterPriority)
          .toList();
    }

    // Category filter
    if (_filterCategory != null) {
      filtered = filtered
          .where((ticket) => ticket.category == _filterCategory)
          .toList();
    }

    return filtered;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.info;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.grey600;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.error;
      case 'in_progress':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.grey600;
      default:
        return AppColors.grey600;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AdminSupportTicketBloc, AdminSupportTicketState>(
      listener: (context, state) {
        if (state is AdminSupportTicketError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AdminSupportTicketsLoaded) {
          setState(() {
            _tickets = state.tickets;
          });
        } else if (state is AdminSupportTicketOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload list to reflect latest status/response
          _loadTickets();
        }
      },
      builder: (context, state) {
        if (state is AdminSupportTicketLoading && _tickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
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
                        ? Colors.white.withValues(alpha: 0.1)
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
                        hintText: 'Search tickets...',
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
                    tooltip: 'Filter',
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
            // Stats Row
            if (_tickets.isNotEmpty)
              Padding(
                padding: UIConstants.paddingMd,
                child: _buildStatsRow(context),
              ),
            // List
            Expanded(
              child: _filteredTickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasActiveFilters || _searchQuery.isNotEmpty
                                ? Icons.filter_alt_off_rounded
                                : Icons.support_agent_rounded,
                            size: 64,
                            color: AppColorsExtension.getTextSecondary(context),
                          ),
                          const SizedBox(height: UIConstants.spacingMd),
                          Text(
                            _hasActiveFilters || _searchQuery.isNotEmpty
                                ? 'No tickets match your filters'
                                : 'No support tickets',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColorsExtension.getTextSecondary(
                                    context,
                                  ),
                                ),
                          ),
                          if (_hasActiveFilters || _searchQuery.isNotEmpty) ...[
                            const SizedBox(height: UIConstants.spacingMd),
                            OutlinedButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.clear_rounded),
                              label: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTickets,
                      child: ListView.builder(
                        padding: UIConstants.paddingLg,
                        itemCount: _filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _filteredTickets[index];
                          return _buildTicketCard(context, ticket);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final openTickets = _tickets.where((t) => t.isOpen).length;
    final inProgress = _tickets.where((t) => t.isInProgress).length;
    final resolved = _tickets.where((t) => t.isResolved).length;

    return Row(
      children: [
        Expanded(
          child: AdminUtils.buildStatCard(
            context,
            'Open',
            openTickets.toString(),
            Icons.mail_rounded,
            AppColors.error,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: AdminUtils.buildStatCard(
            context,
            'In Progress',
            inProgress.toString(),
            Icons.pending_rounded,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Expanded(
          child: AdminUtils.buildStatCard(
            context,
            'Resolved',
            resolved.toString(),
            Icons.check_circle_rounded,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicketEntity ticket) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(ticket.priority);
    final statusColor = _getStatusColor(ticket.status);

    return Card3D(
      child: Container(
        margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
          border: Border.all(color: priorityColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Padding(
          padding: UIConstants.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with priority and status badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
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
                          ticket.subject,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ticket.userName} • ${ticket.userEmail ?? "No email"}',
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
              const SizedBox(height: UIConstants.spacingMd),
              // Badges row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBadge(
                    context,
                    ticket.status.toUpperCase(),
                    statusColor,
                  ),
                  _buildBadge(
                    context,
                    '${ticket.priority.toUpperCase()} PRIORITY',
                    priorityColor,
                  ),
                  _buildBadge(
                    context,
                    ticket.category.toUpperCase(),
                    AppColors.info,
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMd),
              // Message
              Container(
                padding: UIConstants.paddingSm,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColorsExtension.getTextSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AdminUtils.formatDate(ticket.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColorsExtension.getTextSecondary(
                                  context,
                                ),
                              ),
                        ),
                      ],
                    ),
                    if (ticket.assignedAdminName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: AppColorsExtension.getTextSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Assigned to: ${ticket.assignedAdminName}',
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
                  ],
                ),
              ),
              const SizedBox(height: UIConstants.spacingMd),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: View ticket details
                      },
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingMd),
                  if (!ticket.isResolved && !ticket.isClosed)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showRespondDialog(context, ticket);
                        },
                        icon: const Icon(Icons.reply_rounded, size: 18),
                        label: const Text('Respond'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  void _showRespondDialog(BuildContext context, SupportTicketEntity ticket) {
    final responseController = TextEditingController();
    bool markResolved = false;
    final ticketsBloc = context.read<AdminSupportTicketBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Respond to Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subject: ${ticket.subject}'),
              const SizedBox(height: UIConstants.spacingSm),
              Text(
                'From: ${ticket.userName} • ${ticket.userEmail ?? "No email"}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: UIConstants.spacingMd),
              TextField(
                controller: responseController,
                decoration: const InputDecoration(
                  hintText: 'Type your response...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: UIConstants.spacingSm),
              Row(
                children: [
                  Checkbox(
                    value: markResolved,
                    onChanged: (v) => setState(() => markResolved = v ?? false),
                  ),
                  const Text('Mark as resolved'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: responseController.text.trim().isEmpty
                  ? null
                  : () {
                      final auth = sl<FirebaseAuth>();
                      final admin = auth.currentUser;
                      final adminId = admin?.uid ?? 'admin';
                      final adminName = admin?.displayName ?? 'Admin';
                      ticketsBloc.add(
                        RespondToSupportTicket(
                          ticketId: ticket.id,
                          response: responseController.text.trim(),
                          assignedAdminId: adminId,
                          assignedAdminName: adminName,
                          markResolved: markResolved,
                        ),
                      );
                      Navigator.of(dialogContext).pop();
                    },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? tempFilterStatus = _filterStatus;
    String? tempFilterPriority = _filterPriority;
    String? tempFilterCategory = _filterCategory;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Tickets'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempFilterStatus,
                  decoration: const InputDecoration(
                    hintText: 'Select status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (value) =>
                      setState(() => tempFilterStatus = value),
                ),
                const SizedBox(height: 16),
                Text(
                  'Priority',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempFilterPriority,
                  decoration: const InputDecoration(
                    hintText: 'Select priority',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) =>
                      setState(() => tempFilterPriority = value),
                ),
                const SizedBox(height: 16),
                Text(
                  'Category',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempFilterCategory,
                  decoration: const InputDecoration(
                    hintText: 'Select category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(
                      value: 'technical',
                      child: Text('Technical'),
                    ),
                    DropdownMenuItem(value: 'billing', child: Text('Billing')),
                    DropdownMenuItem(value: 'account', child: Text('Account')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) =>
                      setState(() => tempFilterCategory = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tempFilterStatus = null;
                  tempFilterPriority = null;
                  tempFilterCategory = null;
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
                this.setState(() {
                  _filterStatus = tempFilterStatus;
                  _filterPriority = tempFilterPriority;
                  _filterCategory = tempFilterCategory;
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
}

// region: Tab 5 – user behavior analytics & funnel KPIs
class _AnalyticsTab extends StatefulWidget {
  const _AnalyticsTab();

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab>
    with AutomaticKeepAliveClientMixin {

  // Analytics data
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _newUsersToday = 0;
  int _verifiedUsers = 0;
  Map<String, int> _usersByRole = {};
  Map<String, int> _userGrowthWeekly = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminUserAnalyticsBloc>().add(LoadUserAnalytics());
      }
    });
  }

  Future<void> _loadAnalytics() async {
    context.read<AdminUserAnalyticsBloc>().add(LoadUserAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AdminUserAnalyticsBloc, AdminUserAnalyticsState>(
      listener: (context, state) {
        if (state is AdminUserAnalyticsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AdminUserAnalyticsLoaded) {
          final a = state.analytics;
          setState(() {
            _totalUsers = a.totalUsers;
            _activeUsers = a.activeUsers;
            _newUsersToday = a.newUsersToday;
            _verifiedUsers = a.verifiedUsers;
            _usersByRole = a.usersByRole;
            _userGrowthWeekly = a.userGrowthWeekly;
          });
        }
      },
      builder: (context, state) {
        if (state is AdminUserAnalyticsLoading && _totalUsers == 0) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: _loadAnalytics,
          child: ListView(
            padding: UIConstants.paddingLg,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Analytics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColorsExtension.getTextPrimary(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _loadAnalytics,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingLg),

              // Key Metrics Grid
              _buildMetricsGrid(context),
              const SizedBox(height: UIConstants.spacingXl),

              // User Distribution by Role
              _buildSectionTitle(
                context,
                'Users by Role',
                Icons.pie_chart_rounded,
              ),
              const SizedBox(height: UIConstants.spacingMd),
              _buildRoleDistribution(context, isDark),
              const SizedBox(height: UIConstants.spacingXl),

              // Weekly Growth Chart
              _buildSectionTitle(
                context,
                'New Users (Last 7 Days)',
                Icons.show_chart_rounded,
              ),
              const SizedBox(height: UIConstants.spacingMd),
              _buildWeeklyGrowthChart(context, isDark),
              const SizedBox(height: UIConstants.spacingXl),

              // Activity Stats
              _buildSectionTitle(
                context,
                'Activity Overview',
                Icons.analytics_rounded,
              ),
              const SizedBox(height: UIConstants.spacingMd),
              _buildActivityStats(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: UIConstants.spacingMd),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColorsExtension.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: UIConstants.spacingMd,
      mainAxisSpacing: UIConstants.spacingMd,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Slightly taller cards to avoid overflow on smaller screens
      childAspectRatio: 1.15,
      children: [
        _buildMetricCard(
          context,
          'Total Users',
          AdminUtils.formatNumber(_totalUsers),
          Icons.people_rounded,
          AppColors.primary,
          AppColors.primaryGradient,
        ),
        _buildMetricCard(
          context,
          'Active Users',
          AdminUtils.formatNumber(_activeUsers),
          Icons.person_rounded,
          AppColors.success,
          AppColors.successGradient,
        ),
        _buildMetricCard(
          context,
          'New Today',
          AdminUtils.formatNumber(_newUsersToday),
          Icons.person_add_rounded,
          AppColors.info,
          AppColors.infoGradient,
        ),
        _buildMetricCard(
          context,
          'Verified',
          AdminUtils.formatNumber(_verifiedUsers),
          Icons.verified_rounded,
          AppColors.aiPrimary,
          AppColors.aiGradient,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    LinearGradient gradient,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card3D(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Padding(
          padding: UIConstants.paddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: UIConstants.spacingSm),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColorsExtension.getTextSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDistribution(BuildContext context, bool isDark) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.aiPrimary,
    ];

    return Card3D(
      child: Container(
        padding: UIConstants.paddingLg,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
        ),
        child: Column(
          children: _usersByRole.entries.map((entry) {
            final index = _usersByRole.keys.toList().indexOf(entry.key);
            final color = colors[index % colors.length];
            final percentage =
                (_totalUsers > 0 ? (entry.value / _totalUsers * 100) : 0.0)
                    .toStringAsFixed(1);

            return Padding(
              padding: const EdgeInsets.only(bottom: UIConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value} ($percentage%)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _totalUsers > 0 ? entry.value / _totalUsers : 0,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWeeklyGrowthChart(BuildContext context, bool isDark) {
    // Safely compute the max value; handle empty map to avoid 'Bad state: No element'
    double maxValue = 0.0;
    for (final v in _userGrowthWeekly.values) {
      if (v > maxValue) maxValue = v.toDouble();
    }

    return Card3D(
      child: Container(
        padding: UIConstants.paddingLg,
        height: 250,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _userGrowthWeekly.entries.map((entry) {
            final barHeight = maxValue > 0
                ? (entry.value / maxValue * 150)
                : 0.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  entry.value.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityStats(BuildContext context, bool isDark) {
    final activeRate = _totalUsers > 0
        ? (_activeUsers / _totalUsers * 100).toStringAsFixed(1)
        : '0.0';
    final verificationRate = _totalUsers > 0
        ? (_verifiedUsers / _totalUsers * 100).toStringAsFixed(1)
        : '0.0';

    return Card3D(
      child: Container(
        padding: UIConstants.paddingLg,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
        ),
        child: Column(
          children: [
            _buildStatRow(
              context,
              'Active User Rate',
              '$activeRate%',
              Icons.check_circle_rounded,
              AppColors.success,
              double.parse(activeRate) / 100,
            ),
            const SizedBox(height: UIConstants.spacingLg),
            _buildStatRow(
              context,
              'Verification Rate',
              '$verificationRate%',
              Icons.verified_rounded,
              AppColors.info,
              double.parse(verificationRate) / 100,
            ),
            const SizedBox(height: UIConstants.spacingLg),
            _buildStatRow(
              context,
              'New Users Today',
              _newUsersToday.toString(),
              Icons.trending_up_rounded,
              AppColors.primary,
              _newUsersToday / 100, // Arbitrary scale for visualization
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
