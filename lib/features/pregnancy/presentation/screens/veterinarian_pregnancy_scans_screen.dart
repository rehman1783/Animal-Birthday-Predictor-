import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_phone_launcher.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_unsaved_changes_dialog.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/species_icon.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../domain/pregnancy_record.dart';
import '../providers/pregnancy_provider.dart';
import '../widgets/contact_number_block.dart';
import '../widgets/scan_due_block.dart';

class VeterinarianPregnancyScansScreen extends ConsumerStatefulWidget {
  final String? carrierAnimalId;
  final String? pregnancyRecordId;

  const VeterinarianPregnancyScansScreen({
    super.key,
    this.carrierAnimalId,
    this.pregnancyRecordId,
  });

  @override
  ConsumerState<VeterinarianPregnancyScansScreen> createState() =>
      _VeterinarianPregnancyScansScreenState();
}

class _VeterinarianPregnancyScansScreenState
    extends ConsumerState<VeterinarianPregnancyScansScreen> {
  final _vetNameController = TextEditingController();
  final _vetNumberController = TextEditingController();
  String? _selectedCarrierId;
  PregnancyRecord? _record;
  bool _scan1Confirmed = false;
  bool _scan2Confirmed = false;
  bool _scan3Confirmed = false;
  String? _scan1Image;
  String? _scan2Image;
  String? _scan3Image;
  bool _isSaving = false;
  int? _savingScanNumber;
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _selectedCarrierId = widget.carrierAnimalId;
    _loadData();
  }

  bool get _hasUnsavedChanges {
    if (_record == null) {
      return _scan1Confirmed ||
          _scan2Confirmed ||
          _scan3Confirmed ||
          _scan1Image != null ||
          _scan2Image != null ||
          _scan3Image != null ||
          _vetNameController.text.trim().isNotEmpty ||
          _vetNumberController.text.trim().isNotEmpty;
    }
    final r = _record!;
    return _scan1Confirmed != r.scan1Confirmed ||
        (_scan1Image ?? '') != (r.scan1ImageUrl ?? '') ||
        _scan2Confirmed != r.scan2Confirmed ||
        (_scan2Image ?? '') != (r.scan2ImageUrl ?? '') ||
        _scan3Confirmed != r.scan3Confirmed ||
        (_scan3Image ?? '') != (r.scan3ImageUrl ?? '') ||
        _vetNameController.text.trim() != (r.vetName?.trim() ?? '') ||
        _vetNumberController.text.trim() != (r.vetNumber?.trim() ?? '');
  }

  Future<void> _handleSaveScan(int scanNumber) async {
    if (_record == null &&
        (_selectedCarrierId == null || _selectedCarrierId!.isEmpty)) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Carrier Required',
        error: 'Please select or register a mare carrier record.',
      );
      return;
    }

    setState(() => _savingScanNumber = scanNumber);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final current =
          _record ??
          PregnancyRecord(
            id: '',
            accountId: '',
            carrierAnimalId: _selectedCarrierId ?? '',
            breedingRecordId: '',
            scan1DueDate: DateTime.now().add(const Duration(days: 2)),
            scan2DueDate: DateTime.now().add(const Duration(days: 16)),
            scan3DueDate: DateTime.now().add(const Duration(days: 31)),
            foalingDueDate: DateTime.now().add(const Duration(days: 326)),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      PregnancyRecord updated;
      if (scanNumber == 1) {
        updated = current.copyWith(
          scan1Confirmed: _scan1Confirmed,
          scan1ImageUrl: _scan1Image,
          updatedAt: DateTime.now(),
        );
      } else if (scanNumber == 2) {
        updated = current.copyWith(
          scan2Confirmed: _scan2Confirmed,
          scan2ImageUrl: _scan2Image,
          updatedAt: DateTime.now(),
        );
      } else {
        updated = current.copyWith(
          scan3Confirmed: _scan3Confirmed,
          scan3ImageUrl: _scan3Image,
          updatedAt: DateTime.now(),
        );
      }

      final saved = await repo.savePregnancyRecord(updated);
      if (_selectedCarrierId != null) {
        ref.invalidate(pregnancyRecordForCarrierProvider(_selectedCarrierId!));
      }
      ref.invalidate(pregnancyRecordByIdProvider(saved.id));

      if (mounted) {
        setState(() => _record = saved);
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Scan $scanNumber Saved',
          message:
              'Pregnancy scan $scanNumber confirmation and photo updated successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(context, title: 'Save Failed', error: e);
      }
    } finally {
      if (mounted) setState(() => _savingScanNumber = null);
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      PregnancyRecord? rec;

      if (widget.pregnancyRecordId != null &&
          widget.pregnancyRecordId!.isNotEmpty) {
        rec = await repo.getPregnancyRecordById(widget.pregnancyRecordId!);
        if (rec != null) {
          _selectedCarrierId = rec.carrierAnimalId;
        }
      } else if (_selectedCarrierId != null && _selectedCarrierId!.isNotEmpty) {
        rec = await repo.getPregnancyRecordForCarrier(_selectedCarrierId!);
      }

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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _vetNameController.dispose();
    _vetNumberController.dispose();
    super.dispose();
  }

  Future<void> _callVet() async {
    await AppPhoneLauncher.makePhoneCall(context, _vetNumberController.text);
  }

  Future<void> _handleSave() async {
    if (_record == null &&
        (_selectedCarrierId == null || _selectedCarrierId!.isEmpty)) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Carrier Required',
        error: 'Please select or register a mare carrier record.',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final current =
          _record ??
          PregnancyRecord(
            id: '',
            accountId: '',
            carrierAnimalId: _selectedCarrierId ?? '',
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
      if (_selectedCarrierId != null) {
        ref.invalidate(pregnancyRecordForCarrierProvider(_selectedCarrierId!));
      }
      ref.invalidate(pregnancyRecordByIdProvider(saved.id));

      if (mounted) {
        setState(() => _record = saved);
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Scans & Vet Details Saved',
          message:
              'Ultrasound scan confirmations and veterinarian info updated successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(context, title: 'Save Failed', error: e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int _getCompletedScansCount() {
    int count = 0;
    if (_scan1Confirmed) count++;
    if (_scan2Confirmed) count++;
    if (_scan3Confirmed) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final horsesAsync = ref.watch(animalsListProvider('horse'));
    final completedScans = _getCompletedScansCount();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          Navigator.of(context).pop();
          return;
        }
        final shouldSave = await showAppUnsavedChangesDialog(context);
        if (shouldSave == true) {
          await _handleSave();
          if (mounted) Navigator.of(context).pop();
        } else if (shouldSave == false) {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            'VET CONTACT & SCANS OVERVIEW',
            style: AppTypography.sectionLabel,
          ),
          centerTitle: true,
          actions: [
            TextButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primaryGold,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryGold,
                      size: 18,
                    ),
              label: const Text(
                'SAVE',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      body: SafeArea(
        child: _isLoading
            ? const AppLoadingView(message: 'Loading pregnancy scans & records...')
            : _loadError != null
                ? AppErrorView(
                    error: _loadError,
                    onRetry: _loadData,
                  )
                : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                child: ResponsiveBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Mare / Carrier Selector Header
                      horsesAsync.when(
                        data: (horses) {
                          final horsesList = horses
                              .where(
                                (a) =>
                                    a.species.toLowerCase().trim() == 'horse',
                              )
                              .toList();

                          if (horsesList.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cardRadius,
                              ),
                              border: Border.all(color: AppColors.surface),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SELECTED PREGNANCY CARRIER (MARE)',
                                  style: AppTypography.inputLabel,
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue:
                                      horsesList.any(
                                        (h) => h.id == _selectedCarrierId,
                                      )
                                      ? _selectedCarrierId
                                      : (horsesList.isNotEmpty
                                            ? horsesList.first.id
                                            : null),
                                  dropdownColor: AppColors.surface,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputField,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  items: horsesList.map((h) {
                                    return DropdownMenuItem<String>(
                                      value: h.id,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                           AppThumbnailAvatar(
                                             imagePath: h.photoUrl,
                                             species: h.species,
                                             customFallback: SpeciesIcon(species: h.species, size: 16, color: AppColors.primaryGold),
                                             size: 24,
                                             iconSize: 14,
                                             isCircle: true,
                                           ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${h.name} (${h.breed ?? "Equine"})',
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedCarrierId = val);
                                      _loadData();
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: AppLoadingView(message: 'Loading registered mares...', isCompact: true),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppErrorView(
                            error: err,
                            isCompact: true,
                            onRetry: () => ref.invalidate(animalsListProvider('horse')),
                          ),
                        ),
                      ),

                      // 2. Scans Overview Progress Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'PREGNANCY SCANS PROGRESS',
                                  style: AppTypography.displayHeadline
                                      .copyWith(fontSize: 14),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: completedScans == 3
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : AppColors.primaryGold.withValues(
                                            alpha: 0.2,
                                          ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: completedScans == 3
                                          ? Colors.greenAccent
                                          : AppColors.primaryGold,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '$completedScans / 3 CONFIRMED',
                                      style: TextStyle(
                                        color: completedScans == 3
                                            ? Colors.greenAccent
                                            : AppColors.primaryGold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: completedScans / 3.0,
                                minHeight: 6,
                                backgroundColor: AppColors.inputField,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  completedScans == 3
                                      ? Colors.greenAccent
                                      : AppColors.primaryGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // 3. Veterinarian Contact Details Section
                      const SectionDividerLabel(
                        label: 'VETERINARIAN CONTACT DETAILS',
                      ),
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
                      const SizedBox(height: 12.0),

                      // Quick Call Vet Action
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _callVet,
                              icon: const Icon(
                                Icons.call,
                                color: AppColors.primaryGold,
                                size: 16,
                              ),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'CALL VETERINARIAN NOW',
                                  style: TextStyle(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primaryGold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _handleSave,
                              icon: const Icon(Icons.save_outlined, size: 16),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'SAVE VET INFO',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // 4. Ultrasound Scans Overview
                      const SectionDividerLabel(
                        label: 'ULTRASOUND SCANS OVERVIEW & PROTOCOLS',
                      ),
                      const SizedBox(height: 14.0),

                      // Scan 1
                      ScanDueBlock(
                        scanNumber: 1,
                        dueDate: _record?.scan1DueDate,
                        isConfirmed: _scan1Confirmed,
                        imageUrl: _scan1Image,
                        helperGuidance:
                            'Day 14-16. Checks pregnancy vesicle (98% accuracy) & twin detection prior to fixation at Day 16.',
                        onToggleConfirmed: (val) =>
                            setState(() => _scan1Confirmed = val ?? false),
                        onImageSelected: (url) =>
                            setState(() => _scan1Image = url),
                        onSaveScan: () => _handleSaveScan(1),
                        isSavingScan: _savingScanNumber == 1,
                      ),

                      // Scan 2
                      ScanDueBlock(
                        scanNumber: 2,
                        dueDate: _record?.scan2DueDate,
                        isConfirmed: _scan2Confirmed,
                        imageUrl: _scan2Image,
                        helperGuidance:
                            'Day 28-30. Confirms viable embryonic heartbeat & rules out early embryonic loss.',
                        onToggleConfirmed: (val) =>
                            setState(() => _scan2Confirmed = val ?? false),
                        onImageSelected: (url) =>
                            setState(() => _scan2Image = url),
                        onSaveScan: () => _handleSaveScan(2),
                        isSavingScan: _savingScanNumber == 2,
                      ),

                      // Scan 3
                      ScanDueBlock(
                        scanNumber: 3,
                        dueDate: _record?.scan3DueDate,
                        isConfirmed: _scan3Confirmed,
                        imageUrl: _scan3Image,
                        helperGuidance:
                            'Day 45. Verifies complete organogenesis & endometrial cups formation before wintering.',
                        onToggleConfirmed: (val) =>
                            setState(() => _scan3Confirmed = val ?? false),
                        onImageSelected: (url) =>
                            setState(() => _scan3Image = url),
                        onSaveScan: () => _handleSaveScan(3),
                        isSavingScan: _savingScanNumber == 3,
                      ),
                      const SizedBox(height: 20.0),

                      // Save All Updates CTA
                      GradientCtaButton(
                        text: _isSaving
                            ? 'SAVING SCANS & VET...'
                            : 'SAVE ALL SCAN & VET UPDATES',
                        onPressed: _isSaving ? null : _handleSave,
                      ),
                      const SizedBox(height: 28.0),
                    ],
                  ),
                ),
              ),
      ),
    ),
  );
}
}
