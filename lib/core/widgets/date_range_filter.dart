import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/core/widgets/glass_container.dart';
import 'package:intl/intl.dart';

/// Reusable date range filter widget
/// Can be used across features for filtering data by date range
class DateRangeFilter extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final VoidCallback onClear;

  const DateRangeFilter({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: UIConstants.paddingMd,
      borderRadius: UIConstants.borderRadiusMd,
      child: Row(
        children: [
          Icon(Icons.date_range, color: AppColors.primary, size: 20),
          const SizedBox(width: UIConstants.spacingSm),
          Flexible(
            flex: 2,
            child: GestureDetector(
              onTap: () => _selectStartDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColorsExtension.getGrey100(context),
                  borderRadius: UIConstants.borderRadiusSm,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.grey300,
                  ),
                ),
                child: Text(
                  startDate != null
                      ? DateFormat('MMM dd, yyyy').format(startDate!)
                      : 'Start Date',
                  style: TextStyle(
                    color: startDate != null
                        ? AppColorsExtension.getTextPrimary(context)
                        : AppColorsExtension.getGrey600(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'to',
              style: TextStyle(
                color: AppColorsExtension.getGrey600(context),
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: GestureDetector(
              onTap: () => _selectEndDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColorsExtension.getGrey100(context),
                  borderRadius: UIConstants.borderRadiusSm,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.grey300,
                  ),
                ),
                child: Text(
                  endDate != null
                      ? DateFormat('MMM dd, yyyy').format(endDate!)
                      : 'End Date',
                  style: TextStyle(
                    color: endDate != null
                        ? AppColorsExtension.getTextPrimary(context)
                        : AppColorsExtension.getGrey600(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (startDate != null || endDate != null) ...[
            const SizedBox(width: UIConstants.spacingXs),
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: onClear,
              tooltip: 'Clear filter',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: endDate ?? DateTime.now(),
    );

    if (picked != null) {
      onDateRangeChanged(picked, endDate);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      onDateRangeChanged(startDate, picked);
    }
  }
}

