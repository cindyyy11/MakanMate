import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/core/widgets/glass_container.dart';
import 'package:intl/intl.dart';

/// Widget for displaying a single activity log entry with glassmorphism
class ActivityLogItem extends StatelessWidget {
  final ActivityLog log;

  const ActivityLogItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      padding: UIConstants.paddingMd,
      borderRadius: UIConstants.borderRadiusMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getActionColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _getActionColor().withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              _getActionIcon(),
              color: _getActionColor(),
              size: UIConstants.iconSizeMd,
            ),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  log.userName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  _formatAction(log.action),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (log.details != null) ...[
                  const SizedBox(height: UIConstants.spacingXs),
                  Text(
                    log.details!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: UIConstants.spacingXs),
                Wrap(
                  spacing: UIConstants.spacingSm,
                  runSpacing: UIConstants.spacingXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: UIConstants.iconSizeSm,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateFormat('MMM dd, HH:mm').format(log.timestamp),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.grey600,
                                  fontSize: UIConstants.fontSizeXs,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (log.deviceInfo != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.devices,
                            size: UIConstants.iconSizeSm,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.deviceInfo!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.grey600,
                                    fontSize: UIConstants.fontSizeXs,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor() {
    if (log.action.contains('login') || log.action.contains('signup')) {
      return AppColors.success;
    } else if (log.action.contains('delete') || log.action.contains('remove')) {
      return AppColors.error;
    } else if (log.action.contains('update') || log.action.contains('edit')) {
      return AppColors.warning;
    }
    return AppColors.info;
  }

  IconData _getActionIcon() {
    if (log.action.contains('login')) {
      return Icons.login;
    } else if (log.action.contains('signup')) {
      return Icons.person_add;
    } else if (log.action.contains('view')) {
      return Icons.visibility;
    } else if (log.action.contains('order')) {
      return Icons.shopping_cart;
    } else if (log.action.contains('review')) {
      return Icons.rate_review;
    }
    return Icons.event;
  }

  String _formatAction(String action) {
    return action
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
