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
  final VoidCallback? onSaveScan;
  final bool isSavingScan;

  const ScanDueBlock({
    super.key,
    required this.scanNumber,
    required this.dueDate,
    required this.isConfirmed,
    required this.imageUrl,
    required this.onToggleConfirmed,
    required this.onImageSelected,
    required this.helperGuidance,
    this.onSaveScan,
    this.isSavingScan = false,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Calculated on breeding save';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasImg = imageUrl != null && imageUrl!.trim().isNotEmpty;

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
          // Header: Scan Name & Due Date Badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                '${scanNumber == 1 ? "1st" : scanNumber == 2 ? "2nd" : "3rd"} Pregnancy Scan',
                style: AppTypography.displayHeadline.copyWith(fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                constraints: const BoxConstraints(maxWidth: 220),
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
                    Flexible(
                      child: Text(
                        'Due: ${_formatDate(dueDate)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                        softWrap: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.inputField,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                if (hasImg)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primaryGold, width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image, size: 11, color: AppColors.primaryGold),
                          SizedBox(width: 3),
                          Text(
                            'PHOTO ATTACHED',
                            style: TextStyle(color: AppColors.primaryGold, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Scan Photo Upload
          AppImagePicker(
            key: ValueKey('scan-$scanNumber-${imageUrl?.hashCode ?? 0}'),
            label: 'Ultrasound Scan $scanNumber Photo (Optional)',
            initialImageUrl: imageUrl,
            currentImagePath: imageUrl,
            onImageSelected: onImageSelected,
            onImagePicked: onImageSelected,
          ),

          if (onSaveScan != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSavingScan ? null : onSaveScan,
                icon: isSavingScan
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 16),
                label: Text(
                  'SAVE SCAN $scanNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
