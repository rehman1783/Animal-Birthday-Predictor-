import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/animal_provider.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header CTA
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
                    GradientCtaButton(
                      text: '+ RECORD BREEDING EVENT',
                      onPressed: () => Navigator.pushNamed(context, '/breeding-details'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              const SectionDividerLabel(label: 'REGISTERED MARES & CARRIERS'),
              const SizedBox(height: 14.0),

              horsesAsync.when(
                data: (horses) {
                  if (horses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.pets, size: 40, color: AppColors.primaryGold),
                            const SizedBox(height: 12),
                            const Text('No horses registered yet', style: TextStyle(color: AppColors.textPrimary)),
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
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
                                Text(
                                  horse.name,
                                  style: AppTypography.displayHeadline.copyWith(
                                    fontSize: 16,
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                                Text(
                                  horse.breed ?? 'Equine',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chip: ${horse.microchipNo ?? "N/A"} • DNA: ${horse.dna ?? "N/A"}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/breeding-details',
                                        arguments: horse.id,
                                      );
                                    },
                                    icon: const Icon(Icons.favorite_outline, size: 16, color: AppColors.primaryGold),
                                    label: const Text('Log Breeding'),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primaryGold),
                                      foregroundColor: AppColors.primaryGold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/pregnancy-details',
                                        arguments: {'carrierAnimalId': horse.id},
                                      );
                                    },
                                    icon: const Icon(Icons.monitor_heart, size: 16),
                                    label: const Text('Scans / Preg'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGold,
                                      foregroundColor: AppColors.background,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
                error: (e, _) => Text('Error loading horses: $e', style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
