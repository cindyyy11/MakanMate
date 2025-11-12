import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';
import 'package:makan_mate/core/widgets/glass_container.dart';
import 'package:intl/intl.dart';

/// Widget for displaying admin notification with glassmorphism
class NotificationBadge extends StatelessWidget {
  final AdminNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationBadge({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      padding: UIConstants.paddingMd,
      borderRadius: UIConstants.borderRadiusMd,
      borderColor: notification.isRead
          ? Colors.white.withValues(alpha: 0.1)
          : _getNotificationColor().withValues(alpha: 0.3),
      borderWidth: notification.isRead ? 1.0 : 2.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: UIConstants.borderRadiusMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getNotificationColor().withValues(alpha: 0.25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getNotificationColor().withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                _getNotificationIcon(),
                color: _getNotificationColor(),
                size: UIConstants.iconSizeMd,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: UIConstants.spacingXs),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getNotificationColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getNotificationColor().withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  Text(
                    notification.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(notification.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                      fontSize: UIConstants.fontSizeXs,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: UIConstants.spacingXs),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
                color: AppColors.grey600,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}
