import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/species_icon.dart';
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
            // Thumbnail / Avatar (with exact SpeciesIcon fallback)
            AppThumbnailAvatar(
              imagePath: animal.photoUrl,
              species: animal.species,
              size: 50,
              iconSize: 24,
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
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: animal.isStallion || animal.isStudOrDog
                              ? Colors.blueAccent.withValues(alpha: 0.15)
                              : AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: animal.isStallion || animal.isStudOrDog
                                ? Colors.blueAccent.withValues(alpha: 0.6)
                                : AppColors.primaryGold.withValues(alpha: 0.6),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SpeciesIcon(
                              species: animal.species,
                              size: 11,
                              color: animal.isStallion || animal.isStudOrDog
                                  ? Colors.lightBlueAccent
                                  : AppColors.primaryGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              animal.displaySex.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: animal.isStallion || animal.isStudOrDog
                                    ? Colors.lightBlueAccent
                                    : AppColors.primaryGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (animal.breed?.isNotEmpty == true)
                        Text(
                          animal.breed!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      if (animal.microchipNo?.isNotEmpty == true)
                        Container(
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
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing widget or arrow
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}
