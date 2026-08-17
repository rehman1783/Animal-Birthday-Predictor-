import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/pregnancy_record.dart';
import '../providers/pregnancy_provider.dart';
import '../widgets/contact_number_block.dart';
import '../widgets/scan_due_block.dart';

class PregnancyScansScreen extends ConsumerStatefulWidget {
  final String carrierAnimalId;
  final String? pregnancyRecordId;

  const PregnancyScansScreen({
    super.key,
    required this.carrierAnimalId,
    this.pregnancyRecordId,
  });

  @override
  ConsumerState<PregnancyScansScreen> createState() => _PregnancyScansScreenState();
}

class _PregnancyScansScreenState extends ConsumerState<PregnancyScansScreen> {
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
    _loadData();
  }

  Future<void> _loadData() async {
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

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final current = _record ??
          PregnancyRecord(
            id: '',
            accountId: '',
            carrierAnimalId: widget.carrierAnimalId,
            breedingRecordId: '',
            scan1DueDate: DateTime.now().add(const Duration(days: 2)),
            scan2DueDate: DateTime.now().add(const Duration(days: 16)),
            scan3DueDate: DateTime.now().add(const Duration(days: 31)),
            foalingDueDate: DateTime.now().add(const Duration(days: 326)),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      final updated = current.copyWith(
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

      final saved = await repo.savePregnancyRecord(updated);
      ref.invalidate(pregnancyRecordForCarrierProvider(widget.carrierAnimalId));
      ref.invalidate(pregnancyRecordByIdProvider(saved.id));

      if (mounted) {
        setState(() => _record = saved);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ultrasound scans & vet info saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save scans: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('PREGNANCY SCANS', style: AppTypography.sectionLabel),
        centerTitle: true,
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
                    const SectionDividerLabel(label: 'ULTRASOUND SCANS CONFIRMATION'),
                    const SizedBox(height: 14.0),

                    // Scan 1
                    ScanDueBlock(
                      scanNumber: 1,
                      dueDate: _record?.scan1DueDate,
                      isConfirmed: _scan1Confirmed,
                      imageUrl: _scan1Image,
                      helperGuidance: 'Day 14-16. Checks pregnancy & twin detection.',
                      onToggleConfirmed: (val) => setState(() => _scan1Confirmed = val ?? false),
                      onImageSelected: (url) => setState(() => _scan1Image = url),
                    ),

                    // Scan 2
                    ScanDueBlock(
                      scanNumber: 2,
                      dueDate: _record?.scan2DueDate,
                      isConfirmed: _scan2Confirmed,
                      imageUrl: _scan2Image,
                      helperGuidance: 'Day 28-30. Confirms heartbeat.',
                      onToggleConfirmed: (val) => setState(() => _scan2Confirmed = val ?? false),
                      onImageSelected: (url) => setState(() => _scan2Image = url),
                    ),

                    // Scan 3
                    ScanDueBlock(
                      scanNumber: 3,
                      dueDate: _record?.scan3DueDate,
                      isConfirmed: _scan3Confirmed,
                      imageUrl: _scan3Image,
                      helperGuidance: 'Day 45. Verifies organogenesis & endometrial cups.',
                      onToggleConfirmed: (val) => setState(() => _scan3Confirmed = val ?? false),
                      onImageSelected: (url) => setState(() => _scan3Image = url),
                    ),
                    const SizedBox(height: 20.0),

                    const SectionDividerLabel(label: 'VETERINARIAN CONTACT'),
                    const SizedBox(height: 14.0),

                    // Quick Vet Contact (Name and Contact Phone)
                    ContactNumberBlock(
                      title: 'Veterinarian',
                      hintText: 'e.g. +1 555 019 3820',
                      controller: _vetNumberController,
                      nameController: _vetNameController,
                      contactRole: 'vet',
                      icon: Icons.medical_services_outlined,
                      onSave: _handleSave,
                    ),
                    const SizedBox(height: 20.0),

                    GradientCtaButton(
                      text: _isSaving ? 'SAVING SCANS...' : 'SAVE SCAN STATUS',
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
