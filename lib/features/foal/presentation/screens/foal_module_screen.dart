import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../domain/foal_record.dart';
import '../providers/foal_provider.dart';

class FoalModuleScreen extends ConsumerWidget {
  const FoalModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foalsAsync = ref.watch(foalsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'FOAL & BIRTH LOGS',
          style: AppTypography.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGold, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/foal-details');
            },
          ),
        ],
      ),
      body: foalsAsync.when(
        data: (foals) {
          if (foals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.child_care_rounded, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('No foal records found.', style: AppTypography.body),
                    const SizedBox(height: 16),
                    GradientCtaButton(
                      text: '+ Add New Foal Record',
                      onPressed: () {
                        Navigator.pushNamed(context, '/foal-details');
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
            itemCount: foals.length,
            itemBuilder: (context, index) {
              final foal = foals[index];
              return _FoalTile(foal: foal);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
        error: (e, s) => Center(child: Text('Error loading foal records: $e', style: AppTypography.body)),
      ),
    );
  }
}

class _FoalTile extends StatelessWidget {
  final FoalRecord foal;

  const _FoalTile({required this.foal});

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(Icons.child_care, color: AppColors.primaryGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(foal.foalName ?? 'Unnamed Foal', style: AppTypography.featureTitle),
                      Text(
                        '${foal.sex?.toUpperCase() ?? "UNKNOWN"} • Status: ${foal.status ?? "Keep"}',
                        style: AppTypography.finePrint,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputField,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  foal.breed ?? 'Horse',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sire: ${foal.stallion ?? "N/A"} • Microchip: ${foal.foalMicrochipNo ?? "N/A"}',
            style: AppTypography.body.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Birth Date: ${_formatDate(foal.dateOfBirth)}',
            style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
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
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/foal-preventative-care',
                      arguments: {'foalId': foal.id, 'damMareId': foal.mareId},
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                  child: const Text('Care Logs', style: TextStyle(color: AppColors.background)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
