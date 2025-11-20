import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/domain/usecases/create_announcement_usecase.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/admin/presentation/widgets/3d_card.dart';
import 'package:intl/intl.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _priority = 'medium';
  String _targetAudience = 'all';
  DateTime? _expiresAt;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final useCase = di.sl<CreateAnnouncementUseCase>();
      final result = await useCase(
        CreateAnnouncementParams(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          priority: _priority,
          targetAudience: _targetAudience,
          expiresAt: _expiresAt,
        ),
      );

      setState(() => _isLoading = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (announcementId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        },
      );
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _expiresAt = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
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
          ),
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
                Icons.campaign_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            const Text('Create Announcement'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: UIConstants.paddingLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card3D(
                child: Container(
                  padding: UIConstants.paddingLg,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: UIConstants.borderRadiusLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.announcement_rounded,
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
                                  'System Announcement',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create a system-wide announcement',
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
                      const SizedBox(height: UIConstants.spacingXl),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title_rounded),
                          border: OutlineInputBorder(
                            borderRadius: UIConstants.borderRadiusMd,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          prefixIcon: const Icon(Icons.message_rounded),
                          border: OutlineInputBorder(
                            borderRadius: UIConstants.borderRadiusMd,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      // Priority Selection with Visual Indicators
                      Container(
                        padding: UIConstants.paddingMd,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : AppColors.grey50,
                          borderRadius: UIConstants.borderRadiusMd,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : AppColors.grey200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.priority_high_rounded,
                                  size: 20,
                                  color: AppColorsExtension.getTextPrimary(
                                    context,
                                  ),
                                ),
                                const SizedBox(width: UIConstants.spacingSm),
                                Text(
                                  'Priority Level',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: UIConstants.spacingMd),
                            Wrap(
                              spacing: UIConstants.spacingSm,
                              runSpacing: UIConstants.spacingSm,
                              children: [
                                _buildPriorityChip(
                                  'low',
                                  'Low',
                                  Icons.info_outline_rounded,
                                  AppColors.info,
                                ),
                                _buildPriorityChip(
                                  'medium',
                                  'Medium',
                                  Icons.check_circle_outline_rounded,
                                  AppColors.primary,
                                ),
                                _buildPriorityChip(
                                  'high',
                                  'High',
                                  Icons.warning_amber_rounded,
                                  AppColors.warning,
                                ),
                                _buildPriorityChip(
                                  'urgent',
                                  'Urgent',
                                  Icons.error_outline_rounded,
                                  AppColors.error,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      // Target Audience Selection with Visual Indicators
                      Container(
                        padding: UIConstants.paddingMd,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : AppColors.grey50,
                          borderRadius: UIConstants.borderRadiusMd,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : AppColors.grey200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: 20,
                                  color: AppColorsExtension.getTextPrimary(
                                    context,
                                  ),
                                ),
                                const SizedBox(width: UIConstants.spacingSm),
                                Text(
                                  'Target Audience',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: UIConstants.spacingMd),
                            Wrap(
                              spacing: UIConstants.spacingSm,
                              runSpacing: UIConstants.spacingSm,
                              children: [
                                _buildAudienceChip(
                                  'all',
                                  'All Users',
                                  Icons.public_rounded,
                                  AppColors.primary,
                                ),
                                _buildAudienceChip(
                                  'users',
                                  'Users',
                                  Icons.person_rounded,
                                  AppColors.info,
                                ),
                                _buildAudienceChip(
                                  'vendors',
                                  'Vendors',
                                  Icons.store_rounded,
                                  AppColors.secondary,
                                ),
                                _buildAudienceChip(
                                  'admins',
                                  'Admins',
                                  Icons.admin_panel_settings_rounded,
                                  AppColors.warning,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      // Expiry Date Selection
                      InkWell(
                        onTap: _selectExpiryDate,
                        borderRadius: UIConstants.borderRadiusMd,
                        child: Container(
                          padding: UIConstants.paddingMd,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : AppColors.grey50,
                            borderRadius: UIConstants.borderRadiusMd,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : AppColors.grey200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: AppColorsExtension.getTextPrimary(
                                  context,
                                ),
                                size: 20,
                              ),
                              const SizedBox(width: UIConstants.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expires At (Optional)',
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
                                    const SizedBox(height: 4),
                                    Text(
                                      _expiresAt != null
                                          ? DateFormat(
                                              'MMM dd, yyyy • HH:mm',
                                            ).format(_expiresAt!)
                                          : 'No expiry date set',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _expiresAt != null
                                                ? AppColorsExtension.getTextPrimary(
                                                    context,
                                                  )
                                                : AppColorsExtension.getTextSecondary(
                                                    context,
                                                  ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_expiresAt != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() => _expiresAt = null);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Remove expiry date',
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingXl),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: UIConstants.spacingMd,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: UIConstants.borderRadiusMd,
                                ),
                                side: BorderSide(
                                  color: AppColorsExtension.getTextSecondary(
                                    context,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColorsExtension.getTextPrimary(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: UIConstants.spacingMd),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: UIConstants.spacingMd,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: UIConstants.borderRadiusMd,
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.send_rounded,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                          width: UIConstants.spacingSm,
                                        ),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: const Text(
                                              'Create Announcement',
                                              style: TextStyle(fontSize: 16),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _priority == value;
    return InkWell(
      onTap: () => setState(() => _priority = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingMd,
          vertical: UIConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? color
                  : AppColorsExtension.getTextSecondary(context),
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : AppColorsExtension.getTextSecondary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: UIConstants.spacingSm),
              Icon(Icons.check_circle_rounded, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _targetAudience == value;
    return InkWell(
      onTap: () => setState(() => _targetAudience = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingMd,
          vertical: UIConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? color
                  : AppColorsExtension.getTextSecondary(context),
            ),
            const SizedBox(width: UIConstants.spacingSm),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : AppColorsExtension.getTextSecondary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: UIConstants.spacingSm),
              Icon(Icons.check_circle_rounded, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
