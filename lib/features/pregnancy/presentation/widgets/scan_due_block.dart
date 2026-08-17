import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';

class ScanDueBlock extends StatelessWidget {
  final int scanNumber;
  final DateTime? dueDate;
  final bool isConfirmed;
  final String? imageUrl;
  final ValueChanged<bool?> onToggleConfirmed;
  final ValueChanged<String?> onImageSelected;
  final String helperGuidance;

  const ScanDueBlock({
    super.key,
    required this.scanNumber,
    required this.dueDate,
    required this.isConfirmed,
    required this.imageUrl,
    required this.onToggleConfirmed,
    required this.onImageSelected,
    required this.helperGuidance,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Calculated on breeding save';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isConfirmed ? AppColors.primaryGold : AppColors.surface,
          width: isConfirmed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Scan Name & Due Date Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${scanNumber == 1 ? "1st" : scanNumber == 2 ? "2nd" : "3rd"} Pregnancy Scan',
                  style: AppTypography.displayHeadline.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputField,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event, size: 12, color: AppColors.primaryGold),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDate(dueDate)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            helperGuidance,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
          ),

          const SizedBox(height: 12),

          // Pregnancy Confirmed Checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.inputField,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isConfirmed,
                  onChanged: onToggleConfirmed,
                  activeColor: AppColors.primaryGold,
                  checkColor: AppColors.background,
                  side: const BorderSide(color: AppColors.primaryGold),
                ),
                Expanded(
                  child: Text(
                    'Pregnancy Confirmed at Scan $scanNumber',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isConfirmed ? AppColors.primaryGold : AppColors.textPrimary,
                      fontWeight: isConfirmed ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Scan Photo Upload
          AppImagePicker(
            label: 'Ultrasound Scan $scanNumber Photo',
            initialImageUrl: imageUrl,
            onImageSelected: onImageSelected,
          ),
        ],
      ),
    );
  }
}
