import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_unsaved_changes_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/species_icon.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../../core/utils/app_uuid.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../animals/presentation/widgets/select_or_add_animal_modal.dart';
import '../../domain/breeding_record.dart';
import '../providers/pregnancy_provider.dart';

class BreedingDetailsScreen extends ConsumerStatefulWidget {
  final String? initialMareId;

  const BreedingDetailsScreen({super.key, this.initialMareId});

  @override
  ConsumerState<BreedingDetailsScreen> createState() => _BreedingDetailsScreenState();
}

class _BreedingDetailsScreenState extends ConsumerState<BreedingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  Animal? _selectedMare;
  Animal? _selectedRecipient;
  Animal? _initialMare;
  Animal? _initialRecipient;
  BreedingRecord? _initialBreedingRecord;

  final _stallionController = TextEditingController();
  final _damOfEmbryoController = TextEditingController();
  final _stallionOfEmbryoController = TextEditingController();

  String _selectedMethod = 'natural'; // 'natural', 'chilled', 'frozen', 'et', 'icsi'
  bool _recipientCarries = false; // true if ET / ICSI embryo is transferred to a recipient mare
  DateTime _coverDate = DateTime.now();
  DateTime _transferDate = DateTime.now().add(const Duration(days: 7)); // Default 7 days after cover
  bool _isSaving = false;
  bool _isLoading = false;
  Object? _loadError;

  final List<({String label, String value})> _methods = const [
    (label: 'Natural', value: 'natural'),
    (label: 'Chilled', value: 'chilled'),
    (label: 'Frozen', value: 'frozen'),
    (label: 'ET (Embryo Transfer)', value: 'et'),
    (label: 'ICSI', value: 'icsi'),
  ];

  bool get _isEtOrIcsi => _selectedMethod == 'et' || _selectedMethod == 'icsi';

  @override
  void initState() {
    super.initState();
    if (widget.initialMareId != null && widget.initialMareId!.isNotEmpty) {
      _loadInitialMare(widget.initialMareId!);
    }
  }

  Future<void> _loadInitialMare(String id) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final animalRepo = ref.read(animalRepositoryProvider);
      final pregRepo = ref.read(pregnancyRepositoryProvider);

      final animal = await animalRepo.getAnimalById(id);
      if (animal != null && mounted) {
        setState(() {
          _selectedMare = animal;
          _initialMare = animal;
          if (_damOfEmbryoController.text.isEmpty) {
            _damOfEmbryoController.text = animal.name;
          }
        });
      }

      final existingBreeding = await pregRepo.getBreedingRecordByMare(id);
      if (existingBreeding != null && mounted) {
        setState(() {
          _initialBreedingRecord = existingBreeding;
          if (existingBreeding.stallionName?.isNotEmpty == true) {
            _stallionController.text = existingBreeding.stallionName!;
            _stallionOfEmbryoController.text = existingBreeding.stallionName!;
          }
          _selectedMethod = existingBreeding.method;
          _recipientCarries = existingBreeding.isEmbryoTransfer && existingBreeding.recipientAnimalId != null;
          if (existingBreeding.coverOrTransferDate != null) {
            _coverDate = existingBreeding.coverOrTransferDate!;
            _transferDate = existingBreeding.coverOrTransferDate!.add(const Duration(days: 7));
          }
          if (existingBreeding.damOfEmbryo?.isNotEmpty == true) {
            _damOfEmbryoController.text = existingBreeding.damOfEmbryo!;
          }
          if (existingBreeding.stallionOfEmbryo?.isNotEmpty == true) {
            _stallionOfEmbryoController.text = existingBreeding.stallionOfEmbryo!;
          }
        });

        if (existingBreeding.recipientAnimalId != null && existingBreeding.recipientAnimalId!.isNotEmpty) {
          final recipient = await animalRepo.getAnimalById(existingBreeding.recipientAnimalId!);
          if (recipient != null && mounted) {
            setState(() {
              _selectedRecipient = recipient;
              _initialRecipient = recipient;
            });
          }
        }
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
    _stallionController.dispose();
    _damOfEmbryoController.dispose();
    _stallionOfEmbryoController.dispose();
    super.dispose();
  }

  void _onCoverDatePicked(DateTime picked) {
    setState(() {
      _coverDate = picked;
      // Auto-set transfer date to 7 days later
      _transferDate = picked.add(const Duration(days: 7));
    });
  }

  Future<void> _pickDate(bool isTransfer) async {
    final current = isTransfer ? _transferDate : _coverDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
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
      if (isTransfer) {
        setState(() => _transferDate = picked);
      } else {
        _onCoverDatePicked(picked);
      }
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _handleSave() async {
    if (_selectedMare == null) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Mare Required',
        error: 'Please select or register the donor mare.',
      );
      return;
    }

    if (_isEtOrIcsi && _recipientCarries && _selectedRecipient == null) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Recipient Required',
        error: 'Please select or register the recipient mare who will carry the pregnancy.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final existingBreeding = await repo.getBreedingRecordByMare(_selectedMare!.id);
      final breedingId = existingBreeding?.id ?? AppUuid.generate();

      final isET = _isEtOrIcsi;
      final damEmbryoName = _selectedMare!.name;
      final stallionEmbryoName = _stallionController.text.trim();

      final breedingRecord = BreedingRecord(
        id: breedingId,
        accountId: '',
        mareAnimalId: _selectedMare!.id,
        stallionName: stallionEmbryoName,
        method: _selectedMethod,
        coverOrTransferDate: _coverDate,
        isEmbryoTransfer: isET,
        recipientAnimalId: (isET && _recipientCarries) ? _selectedRecipient?.id : null,
        damOfEmbryo: isET ? damEmbryoName : null,
        stallionOfEmbryo: isET ? stallionEmbryoName : null,
        createdAt: existingBreeding?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedBreeding = await repo.saveBreedingRecord(breedingRecord);

      // Case 1: Recipient carries embryo (ET or ICSI with recipient)
      if (isET && _recipientCarries && _selectedRecipient != null) {
        final carrierAnimalId = _selectedRecipient!.id;
        final baseDate = _transferDate; // 7 days post cover date

        final createdPregnancy = await repo.createCalculatedPregnancyRecord(
          carrierAnimalId: carrierAnimalId,
          breedingRecordId: savedBreeding.id,
          method: _selectedMethod,
          isEmbryoTransfer: true,
          baseDate: baseDate,
        );

        ref.invalidate(breedingRecordByMareProvider(_selectedMare!.id));
        ref.invalidate(pregnancyRecordForCarrierProvider(carrierAnimalId));
        ref.invalidate(pregnancyRecordForCarrierProvider(_selectedMare!.id));

        if (mounted) {
          AppFeedbackSnackbar.showSuccess(
            context,
            title: 'ET Pregnancy Calculated',
            message: 'Embryo transferred to ${_selectedRecipient!.name} (7d post cover). Pregnancy & scans calculated!',
          );

          Navigator.pushReplacementNamed(
            context,
            '/pregnancy-details',
            arguments: {
              'carrierAnimalId': carrierAnimalId,
              'breedingRecordId': savedBreeding.id,
              'pregnancyRecordId': createdPregnancy.id,
            },
          );
        }
        return;
      }

      // Case 2: Vitrified / Stored Embryo (No recipient carrying at this time)
      if (isET && !_recipientCarries) {
        ref.invalidate(breedingRecordByMareProvider(_selectedMare!.id));

        if (mounted) {
          AppFeedbackSnackbar.showSuccess(
            context,
            title: 'Embryo Vitrification Logged',
            message: 'Embryo from ${_selectedMare!.name} x $stallionEmbryoName recorded as vitrified/stored.',
          );
          Navigator.pop(context, savedBreeding);
        }
        return;
      }

      // Case 3: Natural / Chilled / Frozen (Donor mare carries herself)
      final carrierAnimalId = _selectedMare!.id;
      final baseDate = _coverDate;

      final createdPregnancy = await repo.createCalculatedPregnancyRecord(
        carrierAnimalId: carrierAnimalId,
        breedingRecordId: savedBreeding.id,
        method: _selectedMethod,
        isEmbryoTransfer: false,
        baseDate: baseDate,
      );

      ref.invalidate(breedingRecordByMareProvider(_selectedMare!.id));
      ref.invalidate(pregnancyRecordForCarrierProvider(carrierAnimalId));

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Breeding Recorded',
          message: 'Breeding details and pregnancy scan timeline calculated successfully!',
        );

        Navigator.pushReplacementNamed(
          context,
          '/pregnancy-details',
          arguments: {
            'carrierAnimalId': carrierAnimalId,
            'breedingRecordId': savedBreeding.id,
            'pregnancyRecordId': createdPregnancy.id,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Breeding Save Failed',
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _hasUnsavedChanges {
    if (_initialBreedingRecord == null && _initialMare == null) {
      return _selectedMare != null ||
          _stallionController.text.trim().isNotEmpty ||
          _selectedRecipient != null;
    }
    final b = _initialBreedingRecord;
    return _selectedMare?.id != _initialMare?.id ||
        _selectedRecipient?.id != _initialRecipient?.id ||
        _stallionController.text.trim() != (b?.stallionName ?? '') ||
        _selectedMethod != (b?.method ?? 'natural') ||
        _recipientCarries != (b?.isEmbryoTransfer ?? false) ||
        _coverDate != (b?.coverOrTransferDate ?? _coverDate);
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text('BREEDING DETAILS', style: AppTypography.sectionLabel),
          centerTitle: true,
          actions: [
            TextButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryGold),
                    )
                  : const Icon(Icons.check_rounded, color: AppColors.primaryGold, size: 18),
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
              ? const AppLoadingView(message: 'Loading breeding records...')
              : _loadError != null
                  ? AppErrorView(
                      error: _loadError,
                      onRetry: () {
                        if (widget.initialMareId != null) {
                          _loadInitialMare(widget.initialMareId!);
                        }
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPadding,
                        vertical: 16.0,
                      ),
                      child: ResponsiveBody(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Donor Mare (Mother)
                              const SectionDividerLabel(label: 'DONOR MARE (MOTHER)'),
                              const SizedBox(height: 12.0),

                              GestureDetector(
                                onTap: () async {
                                  final chosen = await SelectOrAddAnimalModal.show(
                                    context,
                                    title: 'Select Donor Mare',
                                    species: 'horse',
                                    requiredSex: 'mare',
                                    currentSelectedId: _selectedMare?.id,
                                  );
                                  if (chosen != null) _loadInitialMare(chosen.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                                    border: Border.all(
                                      color: _selectedMare != null ? AppColors.primaryGold : AppColors.surface,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      AppThumbnailAvatar(
                                        imagePath: _selectedMare?.photoUrl,
                                        species: _selectedMare?.species ?? 'horse',
                                        customFallback: SpeciesIcon(
                                          species: _selectedMare?.species ?? 'horse',
                                          size: 24,
                                          color: AppColors.primaryGold,
                                        ),
                                        size: 48,
                                        iconSize: 24,
                                        isCircle: true,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedMare != null ? _selectedMare!.name : 'Select or Add Donor Mare',
                                              style: AppTypography.displayHeadline.copyWith(
                                                fontSize: 16,
                                                color: _selectedMare != null ? AppColors.primaryGold : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _selectedMare != null
                                                  ? '${_selectedMare!.breed ?? "Equine"} • Chip: ${_selectedMare!.microchipNo ?? "N/A"}'
                                                  : 'Tap to choose from saved horses or add new',
                                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryGold, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24.0),

                              // 2. Stallion (Father)
                              const SectionDividerLabel(label: 'STALLION (FATHER)'),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Stallion Information', style: AppTypography.inputLabel),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final chosen = await SelectOrAddAnimalModal.show(
                                        context,
                                        title: 'Select Stallion (Father)',
                                        species: 'horse',
                                        requiredSex: 'stallion',
                                      );
                                      if (chosen != null) {
                                        setState(() => _stallionController.text = chosen.name);
                                      }
                                    },
                                    icon: const HorseshoeIcon(size: 14, color: AppColors.primaryGold),
                                    label: const Text('Pick Saved Stallion', style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6.0),

                              CustomTextField(
                                label: 'Stallion / Stud Name (Optional)',
                                hintText: 'e.g. Acres Destiny, Northern Dancer...',
                                controller: _stallionController,
                              ),
                              const SizedBox(height: 24.0),

                              // 3. How Was Your Mare Bred? (Breeding Method)
                              const SectionDividerLabel(label: 'HOW WAS YOUR MARE BRED?'),
                              const SizedBox(height: 12.0),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _methods.map((m) {
                                  final isSelected = _selectedMethod == m.value;
                                  return ChoiceChip(
                                    label: Text(
                                      m.label,
                                      style: AppTypography.buttonLabel.copyWith(
                                        color: isSelected ? AppColors.background : AppColors.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppColors.primaryGold,
                                    backgroundColor: AppColors.surface,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primaryGold : AppColors.surface,
                                      ),
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(() {
                                          _selectedMethod = m.value;
                                          if (_isEtOrIcsi && !_recipientCarries) {
                                            _recipientCarries = true;
                                          }
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24.0),

                              // 4. Base Breeding / Insemination Date
                              const SectionDividerLabel(label: 'BREEDING / COVER DATE'),
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () => _pickDate(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputField,
                                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                                    border: Border.all(color: AppColors.primaryGold),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryGold),
                                          const SizedBox(width: 10),
                                          Text(
                                            _formatDate(_coverDate),
                                            style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      const Text('Tap to change', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24.0),

                              // 5. ET / ICSI Recipient Decision Section
                              if (_isEtOrIcsi) ...[
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
                                      Text(
                                        'Is the embryo carried by a recipient mare?',
                                        style: AppTypography.displayHeadline.copyWith(fontSize: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'If NO, the embryo is vitrified/stored for later. If YES, the surrogate recipient mare carries the pregnancy.',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => setState(() => _recipientCarries = false),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: !_recipientCarries ? AppColors.primaryGold : AppColors.inputField,
                                                foregroundColor: !_recipientCarries ? AppColors.background : AppColors.textPrimary,
                                                side: const BorderSide(color: AppColors.primaryGold),
                                                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              child: const FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text('NO (Vitrified / Stored)', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => setState(() => _recipientCarries = true),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: _recipientCarries ? AppColors.primaryGold : AppColors.inputField,
                                                foregroundColor: _recipientCarries ? AppColors.background : AppColors.textPrimary,
                                                side: const BorderSide(color: AppColors.primaryGold),
                                                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              child: const FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text('YES (Recipient Carries)', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24.0),

                                // 6. If Recipient Carries: Recipient Details & Auto-filled Breeding Info
                                if (_recipientCarries) ...[
                                  const SectionDividerLabel(label: 'RECIPIENT SURROGATE MARE DETAILS'),
                                  const SizedBox(height: 12.0),

                                  GestureDetector(
                                    onTap: () async {
                                      final chosen = await SelectOrAddAnimalModal.show(
                                        context,
                                        title: 'Select Recipient Mare',
                                        species: 'horse',
                                        requiredSex: 'mare',
                                        currentSelectedId: _selectedRecipient?.id,
                                      );
                                      if (chosen != null) setState(() => _selectedRecipient = chosen);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                                        border: Border.all(
                                          color: _selectedRecipient != null ? AppColors.primaryGold : AppColors.surface,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          AppThumbnailAvatar(
                                            imagePath: _selectedRecipient?.photoUrl,
                                            species: _selectedRecipient?.species ?? 'horse',
                                            customFallback: SpeciesIcon(
                                              species: _selectedRecipient?.species ?? 'horse',
                                              size: 24,
                                              color: AppColors.primaryGold,
                                            ),
                                            size: 48,
                                            iconSize: 24,
                                            isCircle: true,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _selectedRecipient != null ? _selectedRecipient!.name : 'Select / Add Recipient Mare *',
                                                  style: AppTypography.displayHeadline.copyWith(
                                                    fontSize: 16,
                                                    color: _selectedRecipient != null ? AppColors.primaryGold : AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _selectedRecipient != null
                                                      ? '${_selectedRecipient!.breed ?? "Equine"} • Chip/No: ${_selectedRecipient!.microchipNo ?? "N/A"}'
                                                      : 'The surrogate mare carrying this pregnancy',
                                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryGold, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Auto-filled Breeding Lineage Banner
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputField,
                                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryGold),
                                            const SizedBox(width: 6),
                                            Text(
                                              'AUTO-LINKED GENETIC LINEAGE',
                                              style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '• Genetic Dam (Mother): ${_selectedMare?.name ?? "Selected Mare"}\n• Genetic Sire (Stallion): ${_stallionController.text.isNotEmpty ? _stallionController.text : "Selected Stallion"}\n• Cover / Breeding Date: ${_formatDate(_coverDate)}',
                                          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Embryo Transfer Date Picker (Auto-calculated as Cover Date + 7 days)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Embryo Transfer Date *', style: AppTypography.inputLabel),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryGold.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Auto-set to +7 days', style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () => _pickDate(true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: AppColors.inputField,
                                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                                            border: Border.all(color: AppColors.primaryGold),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.event_available, size: 18, color: AppColors.primaryGold),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    _formatDate(_transferDate),
                                                    style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                              const Text('Tap to adjust', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24.0),
                                ],
                              ],

                              // 7. Submit CTA
                              GradientCtaButton(
                                text: _isSaving
                                    ? 'CALCULATING PREGNANCY...'
                                    : (_isEtOrIcsi && !_recipientCarries
                                        ? 'LOG VITRIFIED EMBRYO'
                                        : 'SAVE & CALCULATE PREGNANCY'),
                                onPressed: _isSaving ? null : _handleSave,
                              ),
                              const SizedBox(height: 24.0),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
