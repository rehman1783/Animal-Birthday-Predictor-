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
  final bool isTwinsSuspected;
  final ValueChanged<bool?>? onToggleTwins;
  final DateTime? twinRescanDate;
  final ValueChanged<DateTime>? onSelectTwinRescanDate;
  final VoidCallback? onCallVet;

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
    this.isTwinsSuspected = false,
    this.onToggleTwins,
    this.twinRescanDate,
    this.onSelectTwinRescanDate,
    this.onCallVet,
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
          color: (scanNumber == 1 && isTwinsSuspected)
              ? const Color(0xFFEF4444)
              : (isConfirmed ? AppColors.primaryGold : AppColors.surface),
          width: (scanNumber == 1 && isTwinsSuspected) || isConfirmed ? 1.5 : 1.0,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${scanNumber == 1 ? "1st" : scanNumber == 2 ? "2nd" : "3rd"} Pregnancy Scan',
                    style: AppTypography.displayHeadline.copyWith(fontSize: 15),
                  ),
                  if (scanNumber == 1 && isTwinsSuspected) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFEF4444), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 11, color: Color(0xFFEF4444)),
                          SizedBox(width: 3),
                          Text(
                            'TWIN ALERT',
                            style: TextStyle(color: Color(0xFFEF4444), fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
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

          // 1st Scan Special: Twin Detection & Re-scan Alert Section
          if (scanNumber == 1) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isTwinsSuspected
                    ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                    : AppColors.inputField,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isTwinsSuspected
                      ? const Color(0xFFEF4444)
                      : AppColors.inputBorder,
                  width: isTwinsSuspected ? 1.2 : 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isTwinsSuspected,
                        onChanged: onToggleTwins,
                        activeColor: const Color(0xFFEF4444),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: isTwinsSuspected ? const Color(0xFFEF4444) : AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: isTwinsSuspected ? const Color(0xFFEF4444) : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Twins Suspected / Detected at 1st Scan',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isTwinsSuspected ? const Color(0xFFEF4444) : AppColors.textPrimary,
                                  fontWeight: isTwinsSuspected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Expanded Warning Banner & Actionable Re-Scan Protocol
                  if (isTwinsSuspected) ...[
                    const Divider(color: Color(0xFFEF4444), thickness: 0.8, height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'CRITICAL EQUINE TWIN ALERT',
                                  style: AppTypography.buttonLabel.copyWith(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Multiple embryonic vesicles carry high risk of spontaneous abortion or maternal loss in mares. Veterinary intervention (manual reduction/pinching) is most effective prior to vesicle fixation at Day 16–17.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.alarm, color: Color(0xFFF59E0B), size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'URGENT RE-SCAN REQUIRED (Day 16-18)',
                                      style: AppTypography.finePrint.copyWith(
                                        color: const Color(0xFFF59E0B),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  twinRescanDate != null
                                      ? 'Re-scan Target Date: ${_formatDate(twinRescanDate)}'
                                      : (dueDate != null
                                          ? 'Recommended Date: ${_formatDate(dueDate!.add(const Duration(days: 2)))}'
                                          : 'Schedule re-scan within 48-72 hours'),
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (onSelectTwinRescanDate != null)
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final initial = twinRescanDate ?? (dueDate?.add(const Duration(days: 2)) ?? DateTime.now().add(const Duration(days: 2)));
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: initial,
                                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                      lastDate: DateTime.now().add(const Duration(days: 120)),
                                      builder: (ctx, child) {
                                        return Theme(
                                          data: ThemeData.dark().copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: AppColors.primaryGold,
                                              surface: AppColors.surface,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      onSelectTwinRescanDate!(picked);
                                    }
                                  },
                                  icon: const Icon(Icons.edit_calendar_rounded, size: 14, color: AppColors.primaryGold),
                                  label: const Text('Set Re-Scan Date', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primaryGold),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                              if (onCallVet != null)
                                OutlinedButton.icon(
                                  onPressed: onCallVet,
                                  icon: const Icon(Icons.phone_in_talk_rounded, size: 14, color: Color(0xFFEF4444)),
                                  label: const Text('Call Vet Immediately', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFEF4444)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

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
