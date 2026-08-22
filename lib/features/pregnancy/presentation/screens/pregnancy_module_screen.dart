import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../widgets/mare_pregnancy_card.dart';

class PregnancyModuleScreen extends ConsumerWidget {
  const PregnancyModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horsesAsync = ref.watch(animalsListProvider('horse'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('PREGNANCY & BREEDING TRACKER', style: AppTypography.sectionLabel),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header CTA Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Record New Breeding Event', style: AppTypography.displayHeadline.copyWith(fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(
                        'Select a mare, choose the breeding method (Natural, Chilled, Frozen, ICSI), and auto-calculate pregnancy scan due dates.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GradientCtaButton(
                              text: '+ LOG BREEDING',
                              onPressed: () => Navigator.pushNamed(context, '/breeding-details'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/vet-pregnancy-scans'),
                              icon: const Icon(Icons.medical_services_outlined, color: AppColors.primaryGold, size: 16),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('VET & SCANS', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                const SectionDividerLabel(label: 'REGISTERED MARES & PREGNANCY STATUS'),
                const SizedBox(height: 14.0),

                horsesAsync.when(
                  data: (allHorses) {
                    final horses = allHorses
                        .where((h) => h.species.toLowerCase().trim() == 'horse')
                        .toList();

                    if (horses.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const HorseshoeIcon(size: 40, color: AppColors.primaryGold),
                              const SizedBox(height: 12),
                              const Text('No mares/horses registered yet', style: TextStyle(color: AppColors.textPrimary)),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () => Navigator.pushNamed(context, '/species-select'),
                                child: const Text('Register First Mare'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: horses.map((horse) {
                        return MarePregnancyCard(mare: horse);
                      }).toList(),
                    );
                  },
                  loading: () => const AppLoadingView(message: 'Loading registered mares...'),
                  error: (e, _) => AppErrorView(
                    error: e,
                    onRetry: () => ref.invalidate(animalsListProvider('horse')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
