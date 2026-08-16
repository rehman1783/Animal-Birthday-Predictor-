import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

class SpeciesSelectCard extends StatelessWidget {
  final String speciesKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SpeciesSelectCard({
    super.key,
    required this.speciesKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.surface,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? AppColors.goldGradient : null,
                color: isSelected ? null : AppColors.inputField,
                border: Border.all(
                  color: isSelected ? AppColors.primaryGold : AppColors.surface,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.background : AppColors.primaryGold,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.displayHeadline.copyWith(
                      fontSize: 18,
                      color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
