import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../foal/presentation/providers/foal_provider.dart';

class DashboardHomeScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const DashboardHomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userProfile = authState.value;
    final horsesAsync = ref.watch(animalsListProvider('horse'));
    final foalsAsync = ref.watch(foalsListProvider);

    final userName = userProfile?.fullName.isNotEmpty == true
        ? userProfile!.fullName
        : 'Equine Breeder';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding,
            vertical: 16.0,
          ),
          child: ResponsiveBody(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Welcome Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WELCOME TO ABP',
                          style: AppTypography.sectionLabel,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: AppTypography.displayHeadline.copyWith(fontSize: 22),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGold, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: AppColors.primaryGold,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // 2. Overview Stats Cards Grid
              Row(
                children: [
                  Expanded(
                    child: horsesAsync.when(
                      data: (horses) => _StatCard(
                        title: 'Saved Horses',
                        count: '${horses.length}',
                        icon: Icons.pets,
                        accentColor: AppColors.primaryGold,
                        onTap: () => Navigator.pushNamed(context, '/saved-animals'),
                      ),
                      loading: () => const _StatCard(title: 'Saved Horses', count: '...', icon: Icons.pets, accentColor: AppColors.primaryGold),
                      error: (err, stack) => const _StatCard(title: 'Saved Horses', count: '0', icon: Icons.pets, accentColor: AppColors.primaryGold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: foalsAsync.when(
                      data: (foals) => _StatCard(
                        title: 'Foal Records',
                        count: '${foals.length}',
                        icon: Icons.child_care,
                        accentColor: AppColors.primaryGold,
                        onTap: () => onNavigateTab?.call(2),
                      ),
                      loading: () => const _StatCard(title: 'Foal Records', count: '...', icon: Icons.child_care, accentColor: AppColors.primaryGold),
                      error: (err, stack) => const _StatCard(title: 'Foal Records', count: '0', icon: Icons.child_care, accentColor: AppColors.primaryGold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28.0),

              // 3. Primary Quick Actions
              const SectionDividerLabel(label: 'CORE WORKFLOWS'),
              const SizedBox(height: 14.0),

              Row(
                children: [
                  Expanded(
                    child: GradientCtaButton(
                      text: '+ Add Animal',
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/species-select');
                        ref.invalidate(animalsListProvider('horse'));
                        ref.invalidate(animalsListProvider(null));
                        ref.invalidate(foalsListProvider);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientCtaButton(
                      text: '+ Record Breeding',
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/breeding-details');
                        ref.invalidate(animalsListProvider('horse'));
                        ref.invalidate(animalsListProvider(null));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/foal-details');
                        ref.invalidate(foalsListProvider);
                      },
                      icon: const Icon(Icons.child_care, color: AppColors.primaryGold),
                      label: Text(
                        '+ NEW FOAL',
                        style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/saved-animals');
                        ref.invalidate(animalsListProvider('horse'));
                        ref.invalidate(animalsListProvider(null));
                      },
                      icon: const Icon(Icons.list_alt, color: AppColors.primaryGold),
                      label: Text(
                        'SAVED ANIMALS',
                        style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28.0),

              // 4. Species Modules Overview
              const SectionDividerLabel(label: 'AVAILABLE SPECIES MODULES'),
              const SizedBox(height: 14.0),

              _SpeciesModuleCard(
                title: 'Horse / Equine Module',
                subtitle: 'Natural, Chilled, Frozen & ICSI pregnancy tracking with embryo transfer support.',
                icon: Icons.pets_rounded,
                isAvailable: true,
                onTap: () => Navigator.pushNamed(context, '/saved-animals'),
              ),
              const SizedBox(height: 10.0),

              _SpeciesModuleCard(
                title: 'Dog / Canine Module',
                subtitle: 'Canine whelping & ovulation schedule predictor.',
                icon: Icons.bedroom_baby_outlined,
                isAvailable: false,
                onTap: () => Navigator.pushNamed(context, '/species-select'),
              ),
              const SizedBox(height: 10.0),

              _SpeciesModuleCard(
                title: 'Cat / Feline Module',
                subtitle: 'Feline kittening & queen gestation tracker.',
                icon: Icons.catching_pokemon,
                isAvailable: false,
                onTap: () => Navigator.pushNamed(context, '/species-select'),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.surface),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accentColor, size: 22),
                if (onTap != null)
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 12),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              count,
              style: AppTypography.displayHeadline.copyWith(fontSize: 26, color: AppColors.primaryGold),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isAvailable;
  final VoidCallback onTap;

  const _SpeciesModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: isAvailable ? AppColors.primaryGold.withValues(alpha: 0.5) : AppColors.surface),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inputField,
                border: Border.all(color: isAvailable ? AppColors.primaryGold : AppColors.surface),
              ),
              child: Icon(icon, color: isAvailable ? AppColors.primaryGold : AppColors.textMuted, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTypography.displayHeadline.copyWith(fontSize: 15)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable ? AppColors.primaryGold.withValues(alpha: 0.2) : AppColors.inputField,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isAvailable ? 'ACTIVE' : 'NEXT RELEASE',
                          style: TextStyle(
                            color: isAvailable ? AppColors.primaryGold : AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
