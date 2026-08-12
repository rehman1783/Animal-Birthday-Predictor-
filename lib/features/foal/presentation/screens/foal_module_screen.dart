import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../domain/foal_record.dart';
import '../../../animals/domain/animal_type.dart';
import '../providers/foal_provider.dart';

class FoalModuleScreen extends ConsumerStatefulWidget {
  const FoalModuleScreen({super.key});

  @override
  ConsumerState<FoalModuleScreen> createState() => _FoalModuleScreenState();
}

class _FoalModuleScreenState extends ConsumerState<FoalModuleScreen> {
  void _showAddFoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final damController = TextEditingController();
    final sireController = TextEditingController();
    final weightController = TextEditingController();
    final colorController = TextEditingController();
    final notesController = TextEditingController();
    AnimalType selectedType = AnimalType.horse;
    String selectedGender = 'colt';

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
                          'Log Birth Record (${selectedType.offspringName})',
                          style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: '${selectedType.offspringName} Name',
                      hintText: 'e.g. Solar Flare',
                      leadingIcon: Icons.pets_outlined,
                      controller: nameController,
                    ),
                    const SizedBox(height: 12),

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

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Dam (Mother)',
                            hintText: 'e.g. Celestial Queen',
                            leadingIcon: Icons.female_outlined,
                            controller: damController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Sire (Father)',
                            hintText: 'e.g. Northern Dancer',
                            leadingIcon: Icons.male_outlined,
                            controller: sireController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Birth Weight (kg)',
                            hintText: 'e.g. 48.5',
                            keyboardType: TextInputType.number,
                            leadingIcon: Icons.scale_outlined,
                            controller: weightController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Coat / Color',
                            hintText: 'e.g. Chestnut',
                            leadingIcon: Icons.palette_outlined,
                            controller: colorController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Health & Nursing Notes',
                      hintText: 'e.g. Standing and nursing well. Vitals normal.',
                      leadingIcon: Icons.medical_information_outlined,
                      controller: notesController,
                    ),
                    const SizedBox(height: 20),

                    GradientCtaButton(
                      text: 'Save Birth Record',
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;

                        final newFoal = FoalRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          pregnancyId: 'p_${DateTime.now().millisecondsSinceEpoch}',
                          offspringName: nameController.text.trim(),
                          animalType: selectedType,
                          damName: damController.text.trim().isEmpty ? 'Unknown Dam' : damController.text.trim(),
                          sireName: sireController.text.trim().isEmpty ? 'Unknown Sire' : sireController.text.trim(),
                          birthDate: DateTime.now(),
                          birthWeightKg: double.tryParse(weightController.text.trim()) ?? 45.0,
                          gender: selectedGender,
                          color: colorController.text.trim().isEmpty ? 'Standard' : colorController.text.trim(),
                          healthNotes: notesController.text.trim(),
                          createdAt: DateTime.now(),
                        );

                        await ref.read(foalListProvider.notifier).addFoal(newFoal);
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
    final foalState = ref.watch(foalListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Foal & Birth Log Tracker',
          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGold, size: 28),
            onPressed: () => _showAddFoalDialog(context),
          ),
        ],
      ),
      body: foalState.when(
        data: (foals) {
          if (foals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care_rounded, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('No birth logs recorded yet.', style: AppTypography.body),
                  const SizedBox(height: 16),
                  GradientCtaButton(
                    text: '+ Log New Birth',
                    onPressed: () => _showAddFoalDialog(context),
                  ),
                ],
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
        error: (e, s) => Center(child: Text('Error loading birth logs: $e', style: AppTypography.body)),
      ),
    );
  }
}

class _FoalTile extends StatelessWidget {
  final FoalRecord foal;

  const _FoalTile({required this.foal});

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
                  CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(foal.animalType.icon, color: AppColors.primaryGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(foal.offspringName, style: AppTypography.featureTitle),
                      Text(
                        '${foal.animalType.offspringName} • ${foal.color} (${foal.gender})',
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
                  '${foal.birthWeightKg} kg',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dam: ${foal.damName} • Sire: ${foal.sireName}',
            style: AppTypography.body.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Birth Date: ${foal.birthDate.day}/${foal.birthDate.month}/${foal.birthDate.year}',
            style: AppTypography.body.copyWith(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (foal.healthNotes?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, color: AppColors.primaryGold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      foal.healthNotes!,
                      style: AppTypography.finePrint.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
