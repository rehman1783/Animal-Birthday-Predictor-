import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/dog_preventative_care.dart';
import '../providers/puppy_provider.dart';

class DogPreventativeCareScreen extends ConsumerStatefulWidget {
  final String ownerType; // 'animal' or 'puppy'
  final String ownerId;
  final String title;
  final DateTime? dateOfBirth;

  const DogPreventativeCareScreen({
    super.key,
    required this.ownerType,
    required this.ownerId,
    required this.title,
    this.dateOfBirth,
  });

  @override
  ConsumerState<DogPreventativeCareScreen> createState() => _DogPreventativeCareScreenState();
}

class _DogPreventativeCareScreenState extends ConsumerState<DogPreventativeCareScreen> {
  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _updateItemDate(DogPreventativeCareItem item, bool isDateGiven) async {
    final initial = (isDateGiven ? item.dateGiven : item.dateDue) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final updated = isDateGiven
          ? item.copyWith(dateGiven: picked, isCompleted: true)
          : item.copyWith(dateDue: picked);

      final repo = ref.read(puppyRepositoryProvider);
      await repo.saveDogPreventativeCareItem(updated);
      ref.invalidate(dogPreventativeCareProvider((
        ownerType: widget.ownerType,
        ownerId: widget.ownerId,
        dob: widget.dateOfBirth,
      )));
    }
  }

  Future<void> _toggleCompleted(DogPreventativeCareItem item, bool? val) async {
    final isDone = val ?? false;
    final updated = item.copyWith(
      isCompleted: isDone,
      dateGiven: isDone && item.dateGiven == null ? DateTime.now() : item.dateGiven,
    );
    final repo = ref.read(puppyRepositoryProvider);
    await repo.saveDogPreventativeCareItem(updated);
    ref.invalidate(dogPreventativeCareProvider((
      ownerType: widget.ownerType,
      ownerId: widget.ownerId,
      dob: widget.dateOfBirth,
    )));
  }

  Future<void> _showEditNotesDialog(DogPreventativeCareItem item) async {
    final notesController = TextEditingController(text: item.notes ?? '');
    final adminController = TextEditingController(text: item.administeredBy ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('HEALTH RECORD DETAILS', style: AppTypography.sectionLabel),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppColors.inputField),
              const SizedBox(height: 12),
              Text(item.title, style: AppTypography.displayHeadline.copyWith(fontSize: 16)),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Administered By / Veterinarian (Optional)',
                hintText: 'e.g. Dr. Jennifer Smith / Self',
                controller: adminController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Batch No. / Product Notes / Remarks (Optional)',
                hintText: 'e.g. Drontal Puppy Suspension, batch #98124...',
                controller: notesController,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              GradientCtaButton(
                text: 'SAVE DETAILS',
                onPressed: () async {
                  final updated = item.copyWith(
                    administeredBy: adminController.text.trim(),
                    notes: notesController.text.trim(),
                  );
                  final repo = ref.read(puppyRepositoryProvider);
                  await repo.saveDogPreventativeCareItem(updated);
                  ref.invalidate(dogPreventativeCareProvider((
                    ownerType: widget.ownerType,
                    ownerId: widget.ownerId,
                    dob: widget.dateOfBirth,
                  )));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final careAsync = ref.watch(dogPreventativeCareProvider((
      ownerType: widget.ownerType,
      ownerId: widget.ownerId,
      dob: widget.dateOfBirth,
    )));

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
          'HEALTH & TREATMENTS: ${widget.title.toUpperCase()}',
          style: AppTypography.sectionLabel,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: careAsync.when(
          data: (items) {
            final wormings = items.where((i) => i.treatmentType == 'worming').toList();
            final vaccines = items.where((i) => i.treatmentType == 'vaccination').toList();
            final vetChecks = items.where((i) => i.treatmentType == 'vet_check').toList();
            final others = items.where((i) => i.treatmentType == 'microchip' || i.treatmentType == 'other').toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
              child: ResponsiveBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Notice Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.healing_outlined, color: AppColors.primaryGold, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Canine Health Protocol requires tracking both Date Given and Date Due pairs for full puppy take-home transparency.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Worming Protocols
                    if (wormings.isNotEmpty) ...[
                      const SectionDividerLabel(label: 'WORMING & PARASITE SCHEDULE (DATE GIVEN + DUE)'),
                      const SizedBox(height: 12),
                      ...wormings.map((item) => _buildDualDateItemCard(item)),
                      const SizedBox(height: 24),
                    ],

                    // 2. Vaccinations
                    if (vaccines.isNotEmpty) ...[
                      const SectionDividerLabel(label: 'CANINE VACCINATIONS (C3 / C5 SCHEDULE)'),
                      const SizedBox(height: 12),
                      ...vaccines.map((item) => _buildDualDateItemCard(item)),
                      const SizedBox(height: 24),
                    ],

                    // 3. Veterinary Health Checks
                    if (vetChecks.isNotEmpty) ...[
                      const SectionDividerLabel(label: 'VETERINARY HEALTH EXAMINATIONS'),
                      const SizedBox(height: 12),
                      ...vetChecks.map((item) => _buildDualDateItemCard(item)),
                      const SizedBox(height: 24),
                    ],

                    // 4. Microchip & Others
                    if (others.isNotEmpty) ...[
                      const SectionDividerLabel(label: 'MICROCHIP & OTHER PROCEDURES'),
                      const SizedBox(height: 12),
                      ...others.map((item) => _buildDualDateItemCard(item)),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const AppLoadingView(message: 'Loading health records...'),
          error: (e, _) => AppErrorView(
            error: e,
            onRetry: () => ref.invalidate(dogPreventativeCareProvider((
              ownerType: widget.ownerType,
              ownerId: widget.ownerId,
              dob: widget.dateOfBirth,
            ))),
          ),
        ),
      ),
    );
  }

  Widget _buildDualDateItemCard(DogPreventativeCareItem item) {
    final isOverdue = !item.isCompleted && item.dateDue != null && item.dateDue!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: item.isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : isOverdue
                  ? Colors.amberAccent.withValues(alpha: 0.7)
                  : AppColors.surface,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: item.isCompleted,
                onChanged: (val) => _toggleCompleted(item, val),
                activeColor: AppColors.primaryGold,
                checkColor: AppColors.background,
                side: const BorderSide(color: AppColors.primaryGold),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.displayHeadline.copyWith(
                        fontSize: 15,
                        color: item.isCompleted ? AppColors.primaryGold : AppColors.textPrimary,
                      ),
                    ),
                    if (item.administeredBy?.isNotEmpty == true || item.notes?.isNotEmpty == true)
                      Text(
                        [
                          if (item.administeredBy?.isNotEmpty == true) 'By: ${item.administeredBy}',
                          if (item.notes?.isNotEmpty == true) item.notes!,
                        ].join(' • '),
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                        softWrap: true,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note, color: AppColors.primaryGold, size: 22),
                tooltip: 'Add Notes & Batch Info',
                onPressed: () => _showEditNotesDialog(item),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date Given + Date Due Pair Selectors
          Row(
            children: [
              // Date Given
              Expanded(
                child: GestureDetector(
                  onTap: () => _updateItemDate(item, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.inputField,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.dateGiven != null ? AppColors.primaryGold : AppColors.surface,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DATE GIVEN', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item.dateGiven != null ? _formatDate(item.dateGiven) : 'Not Given',
                                  style: TextStyle(
                                    color: item.dateGiven != null ? AppColors.textPrimary : AppColors.textMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.event_available, size: 13, color: AppColors.primaryGold),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Date Due
              Expanded(
                child: GestureDetector(
                  onTap: () => _updateItemDate(item, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.inputField,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isOverdue ? Colors.amberAccent : AppColors.surface,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('NEXT DUE', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                            if (isOverdue)
                              const Text('DUE NOW', style: TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item.dateDue != null ? _formatDate(item.dateDue) : 'Set Due Date',
                                  style: TextStyle(
                                    color: isOverdue
                                        ? Colors.amberAccent
                                        : item.dateDue != null
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primaryGold),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
