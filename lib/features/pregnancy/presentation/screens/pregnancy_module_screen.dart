import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../domain/pregnancy_record.dart';
import '../../../animals/domain/animal_type.dart';
import '../providers/pregnancy_provider.dart';

class PregnancyModuleScreen extends ConsumerStatefulWidget {
  const PregnancyModuleScreen({super.key});

  @override
  ConsumerState<PregnancyModuleScreen> createState() => _PregnancyModuleScreenState();
}

class _PregnancyModuleScreenState extends ConsumerState<PregnancyModuleScreen> {
  void _showAddBreedingDialog(BuildContext context) {
    final damController = TextEditingController();
    final sireController = TextEditingController();
    final notesController = TextEditingController();
    AnimalType selectedType = AnimalType.horse;
    DateTime selectedBreedingDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final calculatedDueDate = selectedType.calculateDueDate(selectedBreedingDate);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Breeding Record',
                          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Species Selector
                    Text('Species', style: AppTypography.inputLabel),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.inputField,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AnimalType>(
                          value: selectedType,
                          dropdownColor: AppColors.surface,
                          isExpanded: true,
                          items: AnimalType.values.map((type) {
                            return DropdownMenuItem<AnimalType>(
                              value: type,
                              child: Text(type.displayName, style: AppTypography.inputText),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Dam Name (Mother)',
                      hintText: 'e.g. Starlight Eclipse',
                      leadingIcon: Icons.female_outlined,
                      controller: damController,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Sire Name (Father)',
                      hintText: 'e.g. Thunderbolt Fury',
                      leadingIcon: Icons.male_outlined,
                      controller: sireController,
                    ),
                    const SizedBox(height: 12),

                    // Breeding Date Picker
                    Text('Breeding Date', style: AppTypography.inputLabel),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedBreedingDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => selectedBreedingDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.inputField,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedBreedingDate.day}/${selectedBreedingDate.month}/${selectedBreedingDate.year}',
                              style: AppTypography.inputText,
                            ),
                            const Icon(Icons.calendar_today, color: AppColors.primaryGold, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Due Date Calculation Result Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PREDICTED ${selectedType.birthTerm.toUpperCase()} DATE',
                                  style: AppTypography.sectionLabel.copyWith(fontSize: 10),
                                ),
                                Text(
                                  '${calculatedDueDate.day}/${calculatedDueDate.month}/${calculatedDueDate.year}',
                                  style: AppTypography.featureTitle.copyWith(color: AppColors.primaryGold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Notes / Veterinary Ultrasound Remarks',
                      hintText: 'e.g. Ultrasound confirmed, twin check clear',
                      leadingIcon: Icons.notes_outlined,
                      controller: notesController,
                    ),
                    const SizedBox(height: 20),

                    GradientCtaButton(
                      text: 'Save Breeding Record',
                      onPressed: () async {
                        if (damController.text.trim().isEmpty || sireController.text.trim().isEmpty) return;

                        final newRecord = PregnancyRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          damName: damController.text.trim(),
                          sireName: sireController.text.trim(),
                          animalType: selectedType,
                          breedingDate: selectedBreedingDate,
                          expectedDueDate: calculatedDueDate,
                          confirmedPregnancy: true,
                          status: PregnancyStatus.active,
                          notes: notesController.text.trim(),
                          createdAt: DateTime.now(),
                        );

                        await ref.read(pregnancyListProvider.notifier).addPregnancy(newRecord);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pregnancyState = ref.watch(pregnancyListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Pregnancy Module & Predictor',
          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGold, size: 28),
            onPressed: () => _showAddBreedingDialog(context),
          ),
        ],
      ),
      body: pregnancyState.when(
        data: (pregnancies) {
          if (pregnancies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monitor_heart_outlined, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('No pregnancy records logged yet.', style: AppTypography.body),
                  const SizedBox(height: 16),
                  GradientCtaButton(
                    text: '+ Add Breeding Record',
                    onPressed: () => _showAddBreedingDialog(context),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
            itemCount: pregnancies.length,
            itemBuilder: (context, index) {
              final record = pregnancies[index];
              return _PregnancyCard(record: record);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
        error: (e, s) => Center(child: Text('Error loading records: $e', style: AppTypography.body)),
      ),
    );
  }
}

class _PregnancyCard extends StatelessWidget {
  final PregnancyRecord record;

  const _PregnancyCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final progress = record.progressPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: record.isDueSoon ? AppColors.primaryGold : AppColors.inputBorder,
          width: record.isDueSoon ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(record.animalType.icon, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(record.damName, style: AppTypography.featureTitle),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: record.isDueSoon ? AppColors.primaryGold : AppColors.inputField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.status == PregnancyStatus.delivered
                      ? 'Delivered'
                      : (record.isDueSoon ? '${record.daysRemaining} Days Left!' : 'Active'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: record.isDueSoon ? AppColors.background : AppColors.primaryGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sire: ${record.sireName} • Bred: ${record.breedingDate.day}/${record.breedingDate.month}/${record.breedingDate.year}',
            style: AppTypography.body.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Expected ${record.animalType.birthTerm}: ${record.expectedDueDate.day}/${record.expectedDueDate.month}/${record.expectedDueDate.year}',
            style: AppTypography.body.copyWith(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestation Progress: ${(progress * 100).toInt()}% (${record.elapsedDays}/${record.animalType.averageGestationDays} days)',
                style: AppTypography.finePrint,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.inputField,
              valueColor: AlwaysStoppedAnimation<Color>(
                record.isDueSoon ? AppColors.primaryGold : AppColors.goldGradientStart,
              ),
            ),
          ),

          if (record.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Note: ${record.notes!}',
                style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
