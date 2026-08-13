import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/mare_provider.dart';
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
    final maresAsync = ref.watch(maresListProvider);
    final foalsAsync = ref.watch(foalsListProvider);

    final userName = userProfile?.fullName.isNotEmpty == true
        ? userProfile!.fullName
        : 'Celestial Breeder';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Welcome Greeting Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WELCOME BACK',
                          style: AppTypography.sectionLabel,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: AppTypography.displayHeadline,
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
                    child: maresAsync.when(
                      data: (mares) => _StatCard(
                        title: 'Donor Mares',
                        count: '${mares.length}',
                        icon: Icons.pets,
                        accentColor: AppColors.primaryGold,
                      ),
                      loading: () => const _StatCard(title: 'Donor Mares', count: '...', icon: Icons.pets, accentColor: AppColors.primaryGold),
                      error: (e, s) => const _StatCard(title: 'Donor Mares', count: '0', icon: Icons.pets, accentColor: AppColors.primaryGold),
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
                      ),
                      loading: () => const _StatCard(title: 'Foal Records', count: '...', icon: Icons.child_care, accentColor: AppColors.primaryGold),
                      error: (e, s) => const _StatCard(title: 'Foal Records', count: '0', icon: Icons.child_care, accentColor: AppColors.primaryGold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28.0),

              // 3. Quick Actions Section
              const SectionDividerLabel(label: 'QUICK ACTIONS'),
              const SizedBox(height: 16.0),

              Row(
                children: [
                  Expanded(
                    child: GradientCtaButton(
                      text: '+ Donor Mare',
                      onPressed: () => Navigator.pushNamed(context, '/mare-details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientCtaButton(
                      text: '+ New Foal',
                      onPressed: () => Navigator.pushNamed(context, '/foal-details'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28.0),

              // 4. Quick Nav Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onNavigateTab?.call(1),
                      icon: const Icon(Icons.pets, color: AppColors.primaryGold),
                      label: Text(
                        'MY MARES',
                        style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onNavigateTab?.call(2),
                      icon: const Icon(Icons.medical_services_outlined, color: AppColors.primaryGold),
                      label: Text(
                        'PREGNANCY LOG',
                        style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32.0),
            ],
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

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor, size: 22),
              Text(
                count,
                style: AppTypography.displayHeadline.copyWith(
                  fontSize: 24,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
