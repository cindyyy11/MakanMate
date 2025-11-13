import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Audit Log Viewer - Shows all admin actions (immutable history)
class AuditLogViewerPage extends StatefulWidget {
  const AuditLogViewerPage({super.key});

  @override
  State<AuditLogViewerPage> createState() => _AuditLogViewerPageState();
}

class _AuditLogViewerPageState extends State<AuditLogViewerPage> {
  String? _selectedAdmin;
  String? _selectedActionType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            _buildFilters(context, isDark),
            Expanded(
              child: _buildLogList(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: UIConstants.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
              : [Colors.white, Colors.white],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.history_rounded, color: Colors.white),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audit Log Viewer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColorsExtension.getTextPrimary(context),
                  ),
                ),
                Text(
                  'Immutable history of all admin actions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              // Export to PDF
            },
            tooltip: 'Export to PDF',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, bool isDark) {
    return Container(
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: _buildFilterDropdown(
                context,
                'Admin',
                _selectedAdmin,
                ['admin@makanmate.com', 'admin2@makanmate.com'],
                (value) => setState(() => _selectedAdmin = value),
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: _buildFilterDropdown(
                context,
                'Action Type',
                _selectedActionType,
                ['approve_vendor', 'remove_review', 'ban_user'],
                (value) => setState(() => _selectedActionType = value),
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: InkWell(
                onTap: () async {
                  final date = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date.start;
                      _endDate = date.end;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: AppColorsExtension.getGrey600(context),
                      ),
                      const SizedBox(width: UIConstants.spacingSm),
                      Flexible(
                        child: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                              : 'Date Range',
                          style: TextStyle(
                            color: AppColorsExtension.getTextPrimary(context),
                            fontSize: UIConstants.fontSizeSm,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(label),
        isExpanded: true,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(value: null, child: Text('All $label')),
          ...options.map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              )),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogList(BuildContext context, bool isDark) {
    // Mock data - replace with actual data from BLoC
    final mockLogs = [
      _MockAuditLog(
        admin: 'admin@makanmate.com',
        action: 'APPROVED',
        entityType: 'vendor',
        entityId: 'abc123',
        reason: 'All checks passed',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _MockAuditLog(
        admin: 'admin@makanmate.com',
        action: 'REMOVED',
        entityType: 'review',
        entityId: 'xyz789',
        reason: 'Toxic content',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];

    return ListView.builder(
      padding: UIConstants.paddingLg,
      itemCount: mockLogs.length,
      itemBuilder: (context, index) {
        final log = mockLogs[index];
        return _buildLogItem(context, log, isDark);
      },
    );
  }

  Widget _buildLogItem(BuildContext context, _MockAuditLog log, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActionColor(log.action).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActionIcon(log.action),
              color: _getActionColor(log.action),
              size: 20,
            ),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: UIConstants.spacingSm,
                  runSpacing: UIConstants.spacingXs,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(log.timestamp),
                      style: TextStyle(
                        color: AppColorsExtension.getGrey600(context),
                        fontSize: UIConstants.fontSizeSm,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.admin,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: UIConstants.fontSizeXs,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  '${log.action} ${log.entityType} ${log.entityId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorsExtension.getTextPrimary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (log.reason != null) ...[
                  const SizedBox(height: UIConstants.spacingXs),
                  Text(
                    'Reason: ${log.reason}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorsExtension.getTextSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'APPROVED':
        return AppColors.success;
      case 'REMOVED':
      case 'REJECTED':
        return AppColors.error;
      case 'WARNED':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_rounded;
      case 'REMOVED':
      case 'REJECTED':
        return Icons.delete_rounded;
      case 'WARNED':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

class _MockAuditLog {
  final String admin;
  final String action;
  final String entityType;
  final String entityId;
  final String? reason;
  final DateTime timestamp;

  _MockAuditLog({
    required this.admin,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.reason,
    required this.timestamp,
  });
}

