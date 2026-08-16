import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../domain/pregnancy_record.dart';
import '../providers/pregnancy_provider.dart';
import '../widgets/contact_number_block.dart';
import '../widgets/scan_due_block.dart';

class PregnancyDetailsScreen extends ConsumerStatefulWidget {
  final String carrierAnimalId;
  final String? breedingRecordId;
  final String? pregnancyRecordId;

  const PregnancyDetailsScreen({
    super.key,
    required this.carrierAnimalId,
    this.breedingRecordId,
    this.pregnancyRecordId,
  });

  @override
  ConsumerState<PregnancyDetailsScreen> createState() => _PregnancyDetailsScreenState();
}

class _PregnancyDetailsScreenState extends ConsumerState<PregnancyDetailsScreen> {
  final _vetNameController = TextEditingController();
  final _vetNumberController = TextEditingController();

  PregnancyRecord? _record;
  bool _scan1Confirmed = false;
  bool _scan2Confirmed = false;
  bool _scan3Confirmed = false;
  String? _scan1Image;
  String? _scan2Image;
  String? _scan3Image;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPregnancyData();
  }

  Future<void> _loadPregnancyData() async {
    final repo = ref.read(pregnancyRepositoryProvider);
    PregnancyRecord? rec;
    if (widget.pregnancyRecordId != null && widget.pregnancyRecordId!.isNotEmpty) {
      rec = await repo.getPregnancyRecordById(widget.pregnancyRecordId!);
    }
    rec ??= await repo.getPregnancyRecordForCarrier(widget.carrierAnimalId);

    if (rec != null && mounted) {
      final r = rec;
      setState(() {
        _record = r;
        _scan1Confirmed = r.scan1Confirmed;
        _scan2Confirmed = r.scan2Confirmed;
        _scan3Confirmed = r.scan3Confirmed;
        _scan1Image = r.scan1ImageUrl;
        _scan2Image = r.scan2ImageUrl;
        _scan3Image = r.scan3ImageUrl;
        _vetNameController.text = r.vetName ?? '';
        _vetNumberController.text = r.vetNumber ?? '';
        _isLoaded = true;
      });
    } else {
      setState(() => _isLoaded = true);
    }
  }

  @override
  void dispose() {
    _vetNameController.dispose();
    _vetNumberController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _confirmDeleteRecord() async {
    if (_record == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Pregnancy Record', style: AppTypography.displayHeadline.copyWith(fontSize: 18)),
        content: const Text(
          'Are you sure you want to delete this pregnancy record? This will remove all associated scans and due dates.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(pregnancyRepositoryProvider);
      await repo.deletePregnancyRecord(_record!.id);
      ref.invalidate(pregnancyRecordForCarrierProvider(widget.carrierAnimalId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pregnancy record deleted successfully.')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_record == null) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final updated = _record!.copyWith(
        scan1Confirmed: _scan1Confirmed,
        scan1ImageUrl: _scan1Image,
        scan2Confirmed: _scan2Confirmed,
        scan2ImageUrl: _scan2Image,
        scan3Confirmed: _scan3Confirmed,
        scan3ImageUrl: _scan3Image,
        vetName: _vetNameController.text.trim(),
        vetNumber: _vetNumberController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await repo.savePregnancyRecord(updated);
      ref.invalidate(pregnancyRecordForCarrierProvider(widget.carrierAnimalId));

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Pregnancy Details Saved',
          message: 'Ultrasound scans & veterinarian details saved successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Save Failed',
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrierAnimalAsync = ref.watch(animalByIdProvider(widget.carrierAnimalId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('PREGNANCY DETAILS', style: AppTypography.sectionLabel),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Pregnancy Scans Quick View',
            icon: const Icon(Icons.speed_rounded, color: AppColors.primaryGold),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/pregnancy-scans',
                arguments: {'carrierAnimalId': widget.carrierAnimalId, 'pregnancyRecordId': _record?.id},
              );
            },
          ),
          if (_record != null)
            IconButton(
              tooltip: 'Delete Record',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _confirmDeleteRecord,
            ),
        ],
      ),
      body: SafeArea(
        child: !_isLoaded
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                child: ResponsiveBody(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carrier Header Card
                    carrierAnimalAsync.when(
                      data: (carrier) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded, color: AppColors.primaryGold, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    carrier != null ? carrier.name : 'Carrying Mare',
                                    style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Foaling Due: ${_formatDate(_record?.foalingDueDate)}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primaryGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16.0),

                    // Multi-Pregnancy Warning Banner (Section 6.8 requirement)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1E14),
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Early Pregnancy Scan Day 14-16 post cover/insemination. To reduce the risk of multiple pregnancies, it is strongly recommended to have your mare scanned by your veterinarian. Multiple pregnancies are dangerous and early detection is your best chance to safely manage them.',
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFFFDE68A),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // 1st Scan
                    const SectionDividerLabel(label: 'ULTRASOUND SCANS (SYSTEM-CALCULATED)'),
                    const SizedBox(height: 14.0),

                    ScanDueBlock(
                      scanNumber: 1,
                      dueDate: _record?.scan1DueDate,
                      isConfirmed: _scan1Confirmed,
                      imageUrl: _scan1Image,
                      helperGuidance: 'Recommended Day 14-16. Checks for pregnancy & detects dangerous twin pregnancies.',
                      onToggleConfirmed: (val) => setState(() => _scan1Confirmed = val ?? false),
                      onImageSelected: (url) => setState(() => _scan1Image = url),
                    ),

                    // 2nd Scan
                    ScanDueBlock(
                      scanNumber: 2,
                      dueDate: _record?.scan2DueDate,
                      isConfirmed: _scan2Confirmed,
                      imageUrl: _scan2Image,
                      helperGuidance: 'Recommended Day 28-30. Confirms embryo heartbeat and normal development.',
                      onToggleConfirmed: (val) => setState(() => _scan2Confirmed = val ?? false),
                      onImageSelected: (url) => setState(() => _scan2Image = url),
                    ),

                    // 3rd Scan
                    ScanDueBlock(
                      scanNumber: 3,
                      dueDate: _record?.scan3DueDate,
                      isConfirmed: _scan3Confirmed,
                      imageUrl: _scan3Image,
                      helperGuidance: 'Recommended Day 45. Verifies endometrial cup formation & organogenesis completion.',
                      onToggleConfirmed: (val) => setState(() => _scan3Confirmed = val ?? false),
                      onImageSelected: (url) => setState(() => _scan3Image = url),
                    ),
                    const SizedBox(height: 16.0),

                    // Vet Contact Block
                    const SectionDividerLabel(label: 'VETERINARIAN CONTACT'),
                    const SizedBox(height: 14.0),

                    ContactNumberBlock(
                      title: 'Veterinarian',
                      hintText: 'e.g. +1 555 019 3820',
                      controller: _vetNumberController,
                      nameController: _vetNameController,
                      contactRole: 'vet',
                      icon: Icons.medical_services_outlined,
                      onSave: _handleSave,
                    ),
                    const SizedBox(height: 16.0),

                    // Advanced Pregnancy Info Entry Action
                    OutlinedButton.icon(
                      onPressed: () {
                        if (_record != null) {
                          Navigator.pushNamed(
                            context,
                            '/advanced-pregnancy',
                            arguments: _record!.id,
                          );
                        }
                      },
                      icon: const Icon(Icons.science_outlined, color: AppColors.primaryGold),
                      label: Text(
                        'ADVANCED PROCEDURES (CASLICK & FETAL SEXING)',
                        style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Save CTA
                    GradientCtaButton(
                      text: _isSaving ? 'SAVING DETAILS...' : 'SAVE PREGNANCY UPDATES',
                      onPressed: _isSaving ? null : _handleSave,
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
                ),
              ),
      ),
    );
  }
}
