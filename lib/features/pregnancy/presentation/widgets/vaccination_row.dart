import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

class VaccinationRow extends StatelessWidget {
  final String label;
  final String interval;
  final DateTime? date;
  final bool done;
  final VoidCallback onPickDate;
  final ValueChanged<bool?> onToggleDone;
  final String? mareReferenceNote; // Shown on Foal screen if mare record exists

  const VaccinationRow({
    super.key,
    required this.label,
    required this.interval,
    required this.date,
    required this.done,
    required this.onPickDate,
    required this.onToggleDone,
    this.mareReferenceNote,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: done ? AppColors.primaryGold.withValues(alpha: 0.8) : AppColors.surface,
          width: done ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox Done
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: done,
                  onChanged: onToggleDone,
                  activeColor: AppColors.primaryGold,
                  checkColor: AppColors.background,
                  side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 8),

              // Title and Interval Helper text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.displayHeadline.copyWith(
                        fontSize: 15,
                        color: done ? AppColors.primaryGold : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      interval,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Date Picker Button
              GestureDetector(
                onTap: onPickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.inputField,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: date != null ? AppColors.primaryGold : AppColors.surface,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: date != null ? AppColors.primaryGold : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(date),
                        style: AppTypography.bodySmall.copyWith(
                          color: date != null ? AppColors.primaryGold : AppColors.textMuted,
                          fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Optional Dam Mare reference note
          if (mareReferenceNote != null && mareReferenceNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 12, color: AppColors.primaryGold),
                  const SizedBox(width: 4),
                  Text(
                    mareReferenceNote!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryGold.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
