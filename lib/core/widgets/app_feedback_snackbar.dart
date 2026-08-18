import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../utils/error_handler.dart';

class AppFeedbackSnackbar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2818), // Deep rich success green background
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF22C55E),
                ),
                child: const Icon(Icons.check, color: AppColors.background, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: AppTypography.displayHeadline.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF86EFAC),
                        ),
                      ),
                    Text(
                      message,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showError(
    BuildContext context, {
    required dynamic error,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final isNetwork = ErrorHandler.isNetworkError(error);
    final displayTitle = title ?? ErrorHandler.getUserFriendlyTitle(error);
    final displayMessage = ErrorHandler.getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isNetwork
                ? const Color(0xFF2A2000) // Deep amber/gold for network issues
                : const Color(0xFF3B1212), // Deep rich error red background
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isNetwork ? AppColors.primaryGold : const Color(0xFFEF4444),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isNetwork ? AppColors.primaryGold : const Color(0xFFEF4444))
                    .withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNetwork ? AppColors.primaryGold : const Color(0xFFEF4444),
                ),
                child: Icon(
                  isNetwork ? Icons.wifi_off_rounded : Icons.close_rounded,
                  color: isNetwork ? AppColors.background : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: AppTypography.displayHeadline.copyWith(
                        fontSize: 14,
                        color: isNetwork ? AppColors.primaryGold : const Color(0xFFFCA5A5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayMessage,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onRetry();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGold,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'RETRY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
