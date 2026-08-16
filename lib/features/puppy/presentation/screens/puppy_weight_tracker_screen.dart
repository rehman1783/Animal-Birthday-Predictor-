import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_uuid.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../domain/puppy.dart';
import '../../domain/puppy_weight.dart';
import '../providers/puppy_provider.dart';

class PuppyWeightTrackerScreen extends ConsumerStatefulWidget {
  final Puppy puppy;

  const PuppyWeightTrackerScreen({super.key, required this.puppy});

  @override
  ConsumerState<PuppyWeightTrackerScreen> createState() => _PuppyWeightTrackerScreenState();
}

class _PuppyWeightTrackerScreenState extends ConsumerState<PuppyWeightTrackerScreen> {
  Future<void> _showAddWeightDialog() async {
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime entryDate = DateTime.now();

    final dob = widget.puppy.dateOfBirth;
    int calculatedDays = dob != null ? entryDate.difference(dob).inDays : 0;
    if (calculatedDays < 0) calculatedDays = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECORD PUPPY WEIGHT', style: AppTypography.sectionLabel),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppColors.inputField),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Weight (e.g. 450g or 1.2kg) *',
                hintText: 'e.g. 850g',
                controller: weightController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 14),

              // Date & Calculated Age in Days
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: entryDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (picked != null) {
                          setModalState(() {
                            entryDate = picked;
                            if (dob != null) {
                              calculatedDays = entryDate.difference(dob).inDays;
                              if (calculatedDays < 0) calculatedDays = 0;
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputField,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(color: AppColors.surface),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${entryDate.day}/${entryDate.month}/${entryDate.year}',
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryGold),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputField,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Text(
                      'Age: $calculatedDays days',
                      style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Notes (Optional)',
                hintText: 'e.g. Vigorous nursing, daily gain normal...',
                controller: notesController,
              ),
              const SizedBox(height: 20),

              GradientCtaButton(
                text: 'SAVE WEIGHT RECORD',
                onPressed: () async {
                  final text = weightController.text.trim();
                  if (text.isEmpty) return;

                  final repo = ref.read(puppyRepositoryProvider);
                  final weight = PuppyWeight(
                    id: AppUuid.generate(),
                    puppyId: widget.puppy.id,
                    accountId: widget.puppy.accountId,
                    weightDate: entryDate,
                    ageInDays: calculatedDays,
                    weight: text,
                    notes: notesController.text.trim(),
                    createdAt: DateTime.now(),
                  );

                  await repo.savePuppyWeight(weight);
                  ref.invalidate(puppyWeightsProvider(widget.puppy.id));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteWeight(PuppyWeight weight) async {
    final repo = ref.read(puppyRepositoryProvider);
    await repo.deletePuppyWeight(weight.id);
    ref.invalidate(puppyWeightsProvider(widget.puppy.id));
  }

  @override
  Widget build(BuildContext context) {
    final weightsAsync = ref.watch(puppyWeightsProvider(widget.puppy.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'WEIGHT TRACKER: ${widget.puppy.puppyName?.toUpperCase() ?? "PUPPY"}',
          style: AppTypography.sectionLabel,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: Column(
            children: [
              // Summary Banner
              Container(
                margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('BIRTH WEIGHT', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          widget.puppy.birthWeight?.isNotEmpty == true ? widget.puppy.birthWeight! : 'Not Set',
                          style: const TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 36, color: AppColors.inputField),
                    Column(
                      children: [
                        const Text('COLLAR / TAG', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          widget.puppy.collarTagColour?.isNotEmpty == true ? widget.puppy.collarTagColour! : 'None',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 36, color: AppColors.inputField),
                    Column(
                      children: [
                        const Text('BIRTH ORDER', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          widget.puppy.birthOrder != null ? '#${widget.puppy.birthOrder}' : 'N/A',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weight Log Timeline
              Expanded(
                child: weightsAsync.when(
                  data: (weights) {
                    if (weights.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.monitor_weight_outlined, size: 54, color: AppColors.textMuted),
                            const SizedBox(height: 16),
                            Text(
                              'No Ongoing Weights Logged',
                              style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap "+ Log Weight" below to record daily and weekly growth.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: weights.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final w = weights[index];
                        final dt = w.weightDate;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(color: AppColors.surface),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.inputField,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryGold),
                                ),
                                child: const Icon(Icons.scale, color: AppColors.primaryGold, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          w.weight,
                                          style: const TextStyle(
                                            color: AppColors.primaryGold,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (w.ageInDays != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.inputField,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Day ${w.ageInDays}',
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Recorded: ${dt.day}/${dt.month}/${dt.year}${w.notes?.isNotEmpty == true ? " • ${w.notes}" : ""}',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                onPressed: () => _deleteWeight(w),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
                  error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: const Text('Log Weight', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddWeightDialog,
      ),
    );
  }
}
