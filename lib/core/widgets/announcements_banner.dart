import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:dartz/dartz.dart' hide State;
import 'package:makan_mate/core/errors/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Widget to display active announcements as banners
class AnnouncementsBanner extends StatefulWidget {
  final String? userRole; // 'user', 'vendor', 'admin', or null for 'all'
  final bool showUrgentOnly; // If true, only show urgent announcements

  const AnnouncementsBanner({
    super.key,
    this.userRole,
    this.showUrgentOnly = false,
  });

  @override
  State<AnnouncementsBanner> createState() => _AnnouncementsBannerState();
}

class _AnnouncementsBannerState extends State<AnnouncementsBanner> {
  static const String _dismissedAnnouncementsKey = 'dismissed_announcements';
  Set<String> _dismissedAnnouncements = {};

  @override
  void initState() {
    super.initState();
    _loadDismissedAnnouncements();
  }

  Future<void> _loadDismissedAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedJson = prefs.getString(_dismissedAnnouncementsKey);
      if (dismissedJson != null) {
        final List<dynamic> dismissedList = json.decode(dismissedJson);
        setState(() {
          _dismissedAnnouncements = dismissedList.cast<String>().toSet();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _dismissAnnouncement(String announcementId) async {
    try {
      setState(() {
        _dismissedAnnouncements.add(announcementId);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _dismissedAnnouncementsKey,
        json.encode(_dismissedAnnouncements.toList()),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  List<Map<String, dynamic>> _filterDismissed(
    List<Map<String, dynamic>> announcements,
  ) {
    return announcements.where((announcement) {
      final id = announcement['id']?.toString() ?? '';
      return !_dismissedAnnouncements.contains(id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final repository = di.sl<AdminRepository>();
    final targetAudience = widget.userRole ?? 'all';

    return StreamBuilder<Either<Failure, List<Map<String, dynamic>>>>(
      stream: repository.streamAnnouncements(
        targetAudience: targetAudience,
        activeOnly: true,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return snapshot.data!.fold(
          (failure) => const SizedBox.shrink(), // Hide on error
          (announcements) {
            if (announcements.isEmpty) {
              return const SizedBox.shrink();
            }

            // Filter out dismissed announcements
            final filteredAnnouncements = _filterDismissed(announcements);
            if (filteredAnnouncements.isEmpty) {
              return const SizedBox.shrink();
            }

            return _buildAnnouncements(context, filteredAnnouncements);
          },
        );
      },
    );
  }

  Widget _buildAnnouncements(
    BuildContext context,
    List<Map<String, dynamic>> announcements,
  ) {
    // Filter by priority if needed
    final filteredAnnouncements = widget.showUrgentOnly
        ? announcements.where((a) => 
            a['priority'] == 'urgent' || a['priority'] == 'high')
        .toList()
        : announcements;

    if (filteredAnnouncements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show urgent announcements first
    final urgentAnnouncements = filteredAnnouncements.where((a) => 
      a['priority'] == 'urgent').toList();
    final normalAnnouncements = filteredAnnouncements.where((a) => 
      a['priority'] != 'urgent').toList();

    return Column(
      children: [
        // Show urgent announcements
        ...urgentAnnouncements.map((announcement) => 
          _buildUrgentBanner(context, announcement)),
        // Show normal announcements
        ...normalAnnouncements.take(1).map((announcement) => 
          _buildNormalBanner(context, announcement)),
      ],
    );
  }

  Widget _buildUrgentBanner(
    BuildContext context,
    Map<String, dynamic> announcement,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error,
            AppColors.error.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement['title'] ?? 'Urgent Announcement',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement['message'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () {
              final announcementId = announcement['id']?.toString() ?? '';
              if (announcementId.isNotEmpty) {
                _dismissAnnouncement(announcementId);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalBanner(
    BuildContext context,
    Map<String, dynamic> announcement,
  ) {
    final priority = announcement['priority'] ?? 'medium';
    
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (priority) {
      case 'high':
        backgroundColor = AppColors.warning.withAlpha(26);
        textColor = AppColors.warning;
        icon = Icons.info_rounded;
        break;
      case 'low':
        backgroundColor = AppColors.info.withAlpha(26);
        textColor = AppColors.info;
        icon = Icons.campaign_rounded;
        break;
      default: // medium
        backgroundColor = AppColors.primary.withAlpha(26);
        textColor = AppColors.primary;
        icon = Icons.announcement_rounded;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: UIConstants.borderRadiusMd,
        border: Border.all(
          color: textColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement['title'] ?? 'Announcement',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  announcement['message'] ?? '',
                  style: TextStyle(
                    color: AppColorsExtension.getTextPrimary(context),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: AppColorsExtension.getTextSecondary(context),
              size: 18,
            ),
            onPressed: () {
              final announcementId = announcement['id']?.toString() ?? '';
              if (announcementId.isNotEmpty) {
                _dismissAnnouncement(announcementId);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

