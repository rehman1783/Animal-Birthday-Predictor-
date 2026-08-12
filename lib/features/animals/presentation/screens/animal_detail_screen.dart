import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/animal_provider.dart';
import '../../domain/animal_type.dart';

class AnimalDetailScreen extends ConsumerWidget {
  const AnimalDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animal = ref.watch(selectedAnimalProvider);

    if (animal == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background),
        body: const Center(child: Text('No animal selected', style: AppTypography.body)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(animal.name, style: AppTypography.displayHeadline.copyWith(fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal Hero Avatar Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.primaryGold, width: 1.5),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.background,
                    child: Icon(animal.type.icon, size: 40, color: AppColors.primaryGold),
                  ),
                  const SizedBox(height: 12),
                  Text(animal.name, style: AppTypography.displayHeadline.copyWith(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    '${animal.type.displayName} • ${animal.breed}',
                    style: AppTypography.body.copyWith(color: AppColors.primaryGold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pedigree & Lineage Details
            _DetailCard(
              title: 'Pedigree & Lineage',
              items: [
                _DetailRow(label: 'Registration #', value: animal.registrationNumber ?? 'Unregistered'),
                _DetailRow(label: 'Gender', value: animal.gender == 'female' ? animal.type.femaleTerm : animal.type.maleTerm),
                _DetailRow(label: 'Dam (Mother)', value: animal.damName ?? 'Not specified'),
                _DetailRow(label: 'Sire (Father)', value: animal.sireName ?? 'Not specified'),
              ],
            ),

            const SizedBox(height: 16),

            // Gestation Rules Overview for this Animal's Species
            _DetailCard(
              title: '${animal.type.shortName} Gestation Guidelines',
              items: [
                _DetailRow(label: 'Average Gestation', value: '${animal.type.averageGestationDays} days'),
                _DetailRow(label: 'Gestation Range', value: '${animal.type.minGestationDays} - ${animal.type.maxGestationDays} days'),
                _DetailRow(label: 'Birth Term', value: animal.type.birthTerm),
                _DetailRow(label: 'Offspring Name', value: animal.type.offspringName),
              ],
            ),

            const SizedBox(height: 16),

            // Breeder Notes
            if (animal.notes?.isNotEmpty == true)
              _DetailCard(
                title: 'Breeder Notes',
                items: [
                  _DetailRow(label: 'Notes', value: animal.notes!),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailRow> items;

  const _DetailCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.featureTitle),
          const Divider(color: AppColors.inputBorder, height: 20),
          ...items,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTypography.inputText.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
