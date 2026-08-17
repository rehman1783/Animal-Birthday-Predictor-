import 'dart:io';
import 'package:flutter/foundation.dart';
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

  ImageProvider? _getImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://') || kIsWeb) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider(animal.photoUrl);

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
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageProvider == null
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
                        Flexible(
                          child: Text(
                            animal.breed!,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
