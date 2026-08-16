import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../providers/foal_provider.dart';

class FoalModuleScreen extends ConsumerWidget {
  const FoalModuleScreen({super.key});

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foalsAsync = ref.watch(foalsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('FOAL BIRTH LOG & REGISTRY', style: AppTypography.sectionLabel),
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
                    Text('Register Newborn Foal', style: AppTypography.displayHeadline.copyWith(fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(
                      'Record foal identity, auto-link to Dam & Recipient mares, track preventative health, and generate official certificates.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    GradientCtaButton(
                      text: '+ REGISTER NEW FOAL',
                      onPressed: () => Navigator.pushNamed(context, '/foal-details'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              const SectionDividerLabel(label: 'SAVED FOAL RECORDS'),
              const SizedBox(height: 14.0),

              foalsAsync.when(
                data: (foals) {
                  if (foals.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(Icons.child_care, size: 48, color: AppColors.primaryGold),
                            const SizedBox(height: 12),
                            Text(
                              'No Foal Records Yet',
                              style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'When a pregnancy finishes or a new foal is born, register it here.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: foals.map((foal) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
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
                                  foal.foalName?.isNotEmpty == true ? foal.foalName! : 'Unnamed Foal',
                                  style: AppTypography.displayHeadline.copyWith(
                                    fontSize: 16,
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputField,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    (foal.status ?? 'keep').toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'DOB: ${_formatDate(foal.dateOfBirth)} • ${foal.sex == "colt" ? "Colt" : "Filly"} • ${foal.breed ?? "Equine"}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            if (foal.foalMicrochipNo?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Microchip: ${foal.foalMicrochipNo}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/foal-details', arguments: foal);
                                    },
                                    child: const Text('Edit Details'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/certificate',
                                        arguments: {'foal': foal},
                                      );
                                    },
                                    icon: const Icon(Icons.card_membership, size: 16),
                                    label: const Text('Certificate'),
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
                error: (e, _) => Text('Error loading foals: $e', style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
