import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Shows a confirmation dialog when the user attempts to leave an edit screen with unsaved changes.
/// Returns:
/// - `true`: User wants to save changes and exit ("Yes / Save & Exit")
/// - `false`: User wants to discard changes and exit ("No / Discard")
/// - `null`: User cancelled the dialog and wants to stay on the screen ("Cancel")
Future<bool?> showAppUnsavedChangesDialog(
  BuildContext context, {
  String title = 'Unsaved Changes',
  String message = 'You have unsaved changes. Do you want to save your changes before leaving?',
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primaryGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.featureTitle.copyWith(
                color: AppColors.textPrimary,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13.5,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        // 1. Cancel (Stay on screen)
        TextButton(
          onPressed: () => Navigator.pop(ctx, null),
          child: const Text(
            'CANCEL',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),

        // 2. Discard (Exit without saving)
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
          ),
          child: const Text(
            'DISCARD',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),

        // 3. Save & Exit (Save data and proceed)
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'SAVE & EXIT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    ),
  );
}
