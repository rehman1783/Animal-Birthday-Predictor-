import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/mare_provider.dart';

class PregnancyModuleScreen extends ConsumerWidget {
  const PregnancyModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maresAsync = ref.watch(maresListProvider);
    final recipAsync = ref.watch(recipientMaresListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'PREGNANCY & BREEDING TRACKER',
          style: AppTypography.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionDividerLabel(label: 'DONOR MARES', isLeftAligned: true),
            const SizedBox(height: AppSpacing.spaceM),

            maresAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
              error: (e, s) => Text('Error loading mares: $e', style: AppTypography.body),
              data: (mares) {
                if (mares.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Column(
                      children: [
                        const Text('No donor mares registered yet.', style: AppTypography.body),
                        const SizedBox(height: 12),
                        GradientCtaButton(
                          text: '+ Add Donor Mare',
                          onPressed: () => Navigator.pushNamed(context, '/mare-details'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: mares.map((mare) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.spaceM),
                      padding: const EdgeInsets.all(AppSpacing.spaceM),
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
                              Text(mare.name, style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
                              Text(mare.breed ?? 'Horse', style: AppTypography.finePrint),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Microchip: ${mare.microchipNo ?? "N/A"}', style: AppTypography.caption),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/breeding-details', arguments: mare.id);
                                  },
                                  child: const Text('Log Breeding'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/pregnancy-details',
                                      arguments: {'carrierType': 'mare', 'carrierId': mare.id},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                                  child: const Text('Scans', style: TextStyle(color: AppColors.background)),
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
            ),

            const SizedBox(height: AppSpacing.spaceL),
            const SectionDividerLabel(label: 'RECIPIENT MARES', isLeftAligned: true),
            const SizedBox(height: AppSpacing.spaceM),

            recipAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
              error: (e, s) => Text('Error loading recipient mares: $e', style: AppTypography.body),
              data: (recips) {
                if (recips.isEmpty) {
                  return Text('No recipient mares logged.', style: AppTypography.finePrint);
                }

                return Column(
                  children: recips.map((recip) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.spaceM),
                      padding: const EdgeInsets.all(AppSpacing.spaceM),
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
                              Text(recip.nameNo, style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
                              Text('Recipient Mare', style: AppTypography.finePrint),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Dam of Embryo: ${recip.damOfEmbryo ?? "N/A"}', style: AppTypography.caption),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/pregnancy-details',
                                arguments: {'carrierType': 'recipient_mare', 'carrierId': recip.id},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text('View Recipient Scans', style: TextStyle(color: AppColors.background)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
