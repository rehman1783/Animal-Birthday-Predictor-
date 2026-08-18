import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../utils/error_handler.dart';

class AppErrorView extends StatefulWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? title;
  final String? message;
  final bool isCompact;

  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
    this.message,
    this.isCompact = false,
  });

  @override
  State<AppErrorView> createState() => _AppErrorViewState();
}

class _AppErrorViewState extends State<AppErrorView> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _isRetrying) return;
    setState(() => _isRetrying = true);
    try {
      widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = ErrorHandler.isNetworkError(widget.error);
    final displayTitle = widget.title ?? ErrorHandler.getUserFriendlyTitle(widget.error);
    final displayMessage = widget.message ?? ErrorHandler.getUserFriendlyMessage(widget.error);

    if (widget.isCompact) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isNetwork
              ? AppColors.primaryGold.withValues(alpha: 0.08)
              : AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isNetwork
                ? AppColors.primaryGold.withValues(alpha: 0.4)
                : AppColors.error.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              color: isNetwork ? AppColors.primaryGold : AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayTitle,
                    style: AppTypography.featureTitle.copyWith(
                      fontSize: 13,
                      color: isNetwork ? AppColors.primaryGold : AppColors.error,
                    ),
                  ),
                  Text(
                    displayMessage,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: _isRetrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGold,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: AppColors.primaryGold, size: 20),
                onPressed: _handleRetry,
                tooltip: 'Try Again',
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing Icon Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNetwork
                    ? AppColors.primaryGold.withValues(alpha: 0.12)
                    : AppColors.error.withValues(alpha: 0.12),
                border: Border.all(
                  color: isNetwork ? AppColors.primaryGold : AppColors.error,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isNetwork
                        ? AppColors.primaryGold.withValues(alpha: 0.25)
                        : AppColors.error.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                color: isNetwork ? AppColors.primaryGold : AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: AppTypography.displayHeadline.copyWith(
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Try Again CTA Button
            if (widget.onRetry != null)
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _isRetrying ? null : _handleRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.background,
                    elevation: 4,
                    shadowColor: AppColors.primaryGold.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                  icon: _isRetrying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.background,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 20, color: AppColors.background),
                  label: Text(
                    _isRetrying ? 'RETRIEVING...' : 'TRY AGAIN',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
