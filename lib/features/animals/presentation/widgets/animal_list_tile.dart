import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/animal.dart';

class AnimalListTile extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isSelected;

  const AnimalListTile({
    super.key,
    required this.animal,
    required this.onTap,
    this.trailing,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.surface,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail / Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inputField,
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                image: animal.photoUrl != null && animal.photoUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(animal.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: animal.photoUrl == null || animal.photoUrl!.isEmpty
                  ? const Icon(Icons.pets, color: AppColors.primaryGold, size: 24)
                  : null,
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.name,
                    style: AppTypography.displayHeadline.copyWith(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (animal.breed?.isNotEmpty == true) ...[
                        Text(
                          animal.breed!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (animal.microchipNo?.isNotEmpty == true)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.inputField,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Chip: ${animal.microchipNo}',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryGold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
