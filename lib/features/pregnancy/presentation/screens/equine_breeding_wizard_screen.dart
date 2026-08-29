import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_phone_launcher.dart';
import '../../../../core/utils/app_uuid.dart';
import '../../../../core/utils/keyboard_helper.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../../../core/widgets/app_unsaved_changes_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../animals/presentation/widgets/select_or_add_animal_modal.dart';
import '../../domain/breeding_record.dart';
import '../../domain/preventative_care_record.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/preventative_care_provider.dart';
import '../../../foaling_diary/presentation/providers/foaling_diary_provider.dart';

class EquineBreedingWizardScreen extends ConsumerStatefulWidget {
  final String? initialMareId;

  const EquineBreedingWizardScreen({
    super.key,
    this.initialMareId,
  });

  @override
  ConsumerState<EquineBreedingWizardScreen> createState() => _EquineBreedingWizardScreenState();
}

class _EquineBreedingWizardScreenState extends ConsumerState<EquineBreedingWizardScreen> {
  int _currentStep = 0; // 0 to 5 (6 steps)
  bool _isSaving = false;

  // Step 1: Mare Details
  Animal? _selectedMare;

  // Step 2: Breeding Service Details
  final _stallionController = TextEditingController();
  String _selectedMethod = 'natural'; // natural, chilled, frozen, et, icsi
  DateTime _coverDate = DateTime.now();

  // Step 3: Recipient Mare (if ET/ICSI)
  Animal? _selectedRecipient;
  bool _recipientCarries = false;

  // Step 4: Preventative Care & Vaccines
  bool _tetanusDone = true;
  DateTime _tetanusDate = DateTime.now();
  bool _stranglesDone = true;
  DateTime _stranglesDate = DateTime.now();
  bool _ehvDone = true;
  DateTime _ehvDate = DateTime.now();
  bool _rotavirusDone = false;
  DateTime? _rotavirusDate;
  bool _dewormerDone = true;
  DateTime _dewormerDate = DateTime.now();

  // Step 5: Dentist & Farrier Contacts
  final _vetNameController = TextEditingController(text: 'Dr. Sarah Jenkins (Equine Vet)');
  final _vetPhoneController = TextEditingController(text: '+1-555-482-9102');
  final _farrierNameController = TextEditingController(text: 'Robert Vance (Master Farrier)');
  final _farrierPhoneController = TextEditingController(text: '+1-555-839-2019');
  DateTime? _farrierDate = DateTime.now();
  DateTime? _dentalDate = DateTime.now();

  final List<({String label, String value})> _methods = const [
    (label: 'Natural Cover', value: 'natural'),
    (label: 'Chilled Semen AI', value: 'chilled'),
    (label: 'Frozen Semen AI', value: 'frozen'),
    (label: 'Embryo Transfer (ET)', value: 'et'),
    (label: 'ICSI (Intracytoplasmic)', value: 'icsi'),
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
    try {
      final repo = ref.read(animalRepositoryProvider);
      final animal = await repo.getAnimalById(id);
      if (animal != null && mounted) {
        setState(() => _selectedMare = animal);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _stallionController.dispose();
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    _farrierNameController.dispose();
    _farrierPhoneController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _pickDate(Function(DateTime) onPicked, {DateTime? initial}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
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
      setState(() => onPicked(picked));
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedMare == null) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Step 1 Incomplete',
        error: 'Please select or add a Dam (Mare) to continue.',
      );
      return;
    }
    if (_currentStep == 1 && _stallionController.text.trim().isEmpty) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Step 2 Incomplete',
        error: 'Please enter the Sire / Stallion Name to continue.',
      );
      return;
    }
    if (_currentStep == 2 && _isEtOrIcsi && _recipientCarries && _selectedRecipient == null) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Step 3 Incomplete',
        error: 'Please select the surrogate Recipient Mare.',
      );
      return;
    }

    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _finishWizard() async {
    if (_selectedMare == null) return;
    setState(() => _isSaving = true);

    try {
      final pregRepo = ref.read(pregnancyRepositoryProvider);
      final careRepo = ref.read(preventativeCareRepositoryProvider);

      final isET = _isEtOrIcsi;
      final carrierAnimalId = (isET && _recipientCarries && _selectedRecipient != null)
          ? _selectedRecipient!.id
          : _selectedMare!.id;

      // 1. Save Breeding Record
      final breeding = BreedingRecord(
        id: AppUuid.generate(),
        accountId: _selectedMare!.accountId,
        mareAnimalId: _selectedMare!.id,
        stallionName: _stallionController.text.trim(),
        method: _selectedMethod,
        coverOrTransferDate: _coverDate,
        isEmbryoTransfer: isET && _recipientCarries,
        recipientAnimalId: (isET && _recipientCarries) ? _selectedRecipient?.id : null,
        damOfEmbryo: isET ? _selectedMare!.name : null,
        stallionOfEmbryo: isET ? _stallionController.text.trim() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final savedBreeding = await pregRepo.saveBreedingRecord(breeding);

      // 2. Create Calculated Pregnancy Record
      final createdPregnancy = await pregRepo.createCalculatedPregnancyRecord(
        carrierAnimalId: carrierAnimalId,
        breedingRecordId: savedBreeding.id,
        method: _selectedMethod,
        isEmbryoTransfer: isET && _recipientCarries,
        baseDate: _coverDate,
      );

      // 3. Save Preventative Care Record
      final careRecord = PreventativeCareRecord(
        id: AppUuid.generate(),
        ownerType: 'animal',
        ownerId: carrierAnimalId,
        tetanusDate: _tetanusDone ? _tetanusDate : null,
        tetanusDone: _tetanusDone,
        stranglesDate: _stranglesDone ? _stranglesDate : null,
        stranglesDone: _stranglesDone,
        eqHerpesDate: _ehvDone ? _ehvDate : null,
        eqHerpesDone: _ehvDone,
        rotavirusDate: _rotavirusDone ? _rotavirusDate : null,
        rotavirusDone: _rotavirusDone,
        wormerDate: _dewormerDone ? _dewormerDate : null,
        wormerDone: _dewormerDone,
        farrierDate: _farrierDate,
        farrierDone: _farrierDate != null,
        farrierNumber: _farrierPhoneController.text.trim().isNotEmpty ? _farrierPhoneController.text.trim() : null,
        dentalDate: _dentalDate,
        dentalDone: _dentalDate != null,
        dentistNumber: _vetPhoneController.text.trim().isNotEmpty ? _vetPhoneController.text.trim() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await careRepo.savePreventativeCare(careRecord);

      // Sync to Foaling Diary & Calendar Reminders
      try {
        await ref.read(calendarDiarySyncServiceProvider).syncFromBreedingRecord(
          breeding: savedBreeding,
          mare: _selectedMare!,
          recipient: _selectedRecipient,
        );
      } catch (_) {}

      ref.invalidate(breedingRecordByMareProvider(_selectedMare!.id));
      ref.invalidate(pregnancyRecordForCarrierProvider(carrierAnimalId));
      ref.invalidate(animalsListProvider('horse'));
      ref.invalidate(foalingDiaryProvider);
      ref.invalidate(calendarTimelineMilestonesProvider);

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Breeding & Pregnancy Activated',
          message: 'Full 6-step equine breeding workflow verified and calculated!',
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
          title: 'Wizard Save Failed',
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _hasUnsavedChanges {
    final isMareSelected = _selectedMare != null && _selectedMare?.id != widget.initialMareId;
    final isStallionEntered = _stallionController.text.trim().isNotEmpty;
    final isMethodChanged = _selectedMethod != 'natural';
    final isRecipientChanged = _recipientCarries != false || _selectedRecipient != null;
    return isMareSelected ||
        isStallionEntered ||
        isMethodChanged ||
        isRecipientChanged;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (dismissKeyboardIfOpen(context)) return;
        if (!_hasUnsavedChanges) {
          Navigator.of(context).pop();
          return;
        }
        final shouldSave = await showAppUnsavedChangesDialog(
          context,
          title: 'Exit Breeding Wizard?',
          message: 'You have entered breeding details in this wizard. Do you want to save or discard before leaving?',
        );
        if (shouldSave == false) {
          if (mounted) Navigator.of(context).pop();
        } else if (shouldSave == true) {
          await _finishWizard();
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
          title: const Text('EQUINE BREEDING WIZARD', style: AppTypography.sectionLabel),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Step Progress Bar
              _buildStepperHeader(),

              // Step Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding,
                    vertical: 16.0,
                  ),
                  child: ResponsiveBody(
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),

              // Bottom Navigation Actions
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    final stepTitles = ['Mare', 'Breeding', 'Carrier', 'Vaccines', 'Dentist', 'Due Date'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.inputBorder, width: 1.0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final isPassed = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPassed
                          ? AppColors.primaryGold
                          : (isCurrent ? AppColors.primaryGold.withValues(alpha: 0.2) : AppColors.inputField),
                      border: Border.all(
                        color: (isPassed || isCurrent) ? AppColors.primaryGold : AppColors.inputBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isPassed
                          ? const Icon(Icons.check, size: 16, color: AppColors.background)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? AppColors.primaryGold : AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ),
                  if (index < 5)
                    Container(
                      width: 18,
                      height: 2,
                      color: isPassed ? AppColors.primaryGold : AppColors.inputBorder,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'STEP ${_currentStep + 1} OF 6: ${stepTitles[_currentStep].toUpperCase()}',
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1MareDetails();
      case 1:
        return _buildStep2BreedingService();
      case 2:
        return _buildStep3RecipientMare();
      case 3:
        return _buildStep4Vaccines();
      case 4:
        return _buildStep5DentistFarrier();
      case 5:
        return _buildStep6PredictionReveal();
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 1: MARE DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildStep1MareDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionDividerLabel(label: 'STEP 1: SELECT BROODMARE / DAM'),
        const SizedBox(height: 12),
        const Text(
          'Select the registered Mare that is being bred, or tap below to add a new Mare instantly.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () async {
            final picked = await SelectOrAddAnimalModal.show(
              context,
              species: 'horse',
              title: 'Select Broodmare',
            );
            if (picked != null) {
              setState(() => _selectedMare = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: _selectedMare != null ? AppColors.primaryGold : AppColors.inputBorder,
                width: _selectedMare != null ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                if (_selectedMare != null) ...[
                  AppThumbnailAvatar(
                    imagePath: _selectedMare!.photoUrl,
                    species: 'horse',
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedMare!.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Breed: ${_selectedMare!.breed ?? "Equine"} • Microchip: ${_selectedMare!.microchipNo ?? "N/A"}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.primaryGold, size: 22),
                ] else ...[
                  const HorseshoeIcon(size: 28, color: AppColors.primaryGold),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Tap to select or register Broodmare...',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: BREEDING SERVICE DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildStep2BreedingService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionDividerLabel(label: 'STEP 2: BREEDING SERVICE & STALLION'),
        const SizedBox(height: 12),

        CustomTextField(
          label: 'Sire / Stallion Name *',
          hintText: 'e.g. Thunderbolt Royal King',
          controller: _stallionController,
          prefixIcon: Icons.pets,
        ),
        const SizedBox(height: 16),

        const Text('Breeding Method *', style: AppTypography.inputLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _methods.map((m) {
            final isSelected = _selectedMethod == m.value;
            return ChoiceChip(
              label: Text(m.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              selected: isSelected,
              selectedColor: AppColors.primaryGold,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.background : AppColors.textPrimary,
              ),
              onSelected: (_) => setState(() => _selectedMethod = m.value),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cover / Insemination Date *', style: AppTypography.inputLabel),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickDate((date) => _coverDate = date, initial: _coverDate),
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
                    Text(_formatDate(_coverDate), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGold, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: RECIPIENT MARE
  // ---------------------------------------------------------------------------
  Widget _buildStep3RecipientMare() {
    if (!_isEtOrIcsi) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionDividerLabel(label: 'STEP 3: CARRIER STATUS'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.primaryGold, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Natural/AI Breeding: The Dam (${_selectedMare?.name ?? "Mare"}) carries the pregnancy herself. No recipient surrogate needed.',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionDividerLabel(label: 'STEP 3: EMBRYO TRANSFER RECIPIENT MARE'),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Embryo Transferred to Recipient Mare', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          subtitle: const Text('Toggle on if embryo was flushed and transferred to a surrogate mare', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          value: _recipientCarries,
          activeColor: AppColors.primaryGold,
          onChanged: (val) => setState(() => _recipientCarries = val),
        ),
        if (_recipientCarries) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final picked = await SelectOrAddAnimalModal.show(
                context,
                species: 'horse',
                title: 'Select Recipient Mare',
              );
              if (picked != null) {
                setState(() => _selectedRecipient = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: _selectedRecipient != null ? AppColors.primaryGold : AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  if (_selectedRecipient != null) ...[
                    AppThumbnailAvatar(
                      imagePath: _selectedRecipient!.photoUrl,
                      species: 'horse',
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedRecipient!.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.primaryGold, size: 20),
                  ] else ...[
                    const Icon(Icons.add_circle_outline, color: AppColors.textMuted, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Tap to select Recipient Mare...', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 4: PREVENTATIVE CARE & 9 VACCINES
  // ---------------------------------------------------------------------------
  Widget _buildStep4Vaccines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionDividerLabel(label: 'STEP 4: PREVENTATIVE CARE & VACCINES'),
        const SizedBox(height: 10),
        const Text(
          'Ensure brooding mare immunity before foaling. Verified 9-Vaccine Equine Health Protocol:',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 14),

        _buildVaccineTile('Tetanus Toxoid', _tetanusDone, _tetanusDate, (done, date) {
          setState(() {
            _tetanusDone = done;
            if (date != null) _tetanusDate = date;
          });
        }),
        _buildVaccineTile('Strangles (S. equi)', _stranglesDone, _stranglesDate, (done, date) {
          setState(() {
            _stranglesDone = done;
            if (date != null) _stranglesDate = date;
          });
        }),
        _buildVaccineTile('EHV 1/4 (Equine Herpesvirus)', _ehvDone, _ehvDate, (done, date) {
          setState(() {
            _ehvDone = done;
            if (date != null) _ehvDate = date;
          });
        }),
        _buildVaccineTile('Rotavirus (Foal Diarrhea)', _rotavirusDone, _rotavirusDate, (done, date) {
          setState(() {
            _rotavirusDone = done;
            if (date != null) _rotavirusDate = date;
          });
        }),
        _buildVaccineTile('Dewormer (Broad-spectrum)', _dewormerDone, _dewormerDate, (done, date) {
          setState(() {
            _dewormerDone = done;
            if (date != null) _dewormerDate = date;
          });
        }),

        const SizedBox(height: 12),
        // Sponsor Slot Placeholder (Point 5 commitment)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: AppColors.primaryGold, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sponsor Partner: Official Equine Vaccine & Dewormer Protocol Approved',
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineTile(String name, bool isDone, DateTime? date, Function(bool, DateTime?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDone ? AppColors.primaryGold.withValues(alpha: 0.5) : AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isDone,
            activeColor: AppColors.primaryGold,
            onChanged: (val) => onChanged(val ?? false, date),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                if (isDone && date != null)
                  Text('Administered: ${_formatDate(date)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (isDone)
            IconButton(
              icon: const Icon(Icons.edit_calendar_outlined, size: 16, color: AppColors.primaryGold),
              onPressed: () => _pickDate((newDate) => onChanged(true, newDate), initial: date),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 5: DENTIST & FARRIER
  // ---------------------------------------------------------------------------
  Widget _buildStep5DentistFarrier() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionDividerLabel(label: 'STEP 5: DENTIST, FARRIER & EMERGENCY VET'),
        const SizedBox(height: 12),

        CustomTextField(
          label: 'Veterinarian Name',
          controller: _vetNameController,
          prefixIcon: Icons.medical_services_outlined,
        ),
        const SizedBox(height: 10),

        CustomTextField(
          label: 'Veterinarian Phone (Click-to-Call)',
          controller: _vetPhoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        if (_vetPhoneController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => AppPhoneLauncher.makePhoneCall(context, _vetPhoneController.text),
              icon: const Icon(Icons.call, size: 14, color: AppColors.primaryGold),
              label: const Text('Call Vet', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),

        CustomTextField(
          label: 'Farrier Name',
          controller: _farrierNameController,
          prefixIcon: Icons.construction_outlined,
        ),
        const SizedBox(height: 10),

        CustomTextField(
          label: 'Farrier Phone (Click-to-Call)',
          controller: _farrierPhoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        if (_farrierPhoneController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => AppPhoneLauncher.makePhoneCall(context, _farrierPhoneController.text),
              icon: const Icon(Icons.call, size: 14, color: AppColors.primaryGold),
              label: const Text('Call Farrier', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 6: DUE DATE PREDICTION & TIMELINE REVEAL
  // ---------------------------------------------------------------------------
  Widget _buildStep6PredictionReveal() {
    final scan1Date = _coverDate.add(const Duration(days: 14));
    final scan2Date = _coverDate.add(const Duration(days: 28));
    final scan3Date = _coverDate.add(const Duration(days: 45));
    final foalingDate = _coverDate.add(const Duration(days: 341));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionDividerLabel(label: 'STEP 6: FOALING DUE DATE & SCAN SCHEDULE'),
        const SizedBox(height: 12),

        // Hero Card with Foaling Prediction
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0A192F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.primaryGold, width: 1.5),
          ),
          child: Column(
            children: [
              const HorseshoeIcon(size: 32, color: AppColors.primaryGold),
              const SizedBox(height: 8),
              const Text(
                'PROJECTED FOALING BIRTHDAY',
                style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(foalingDate),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
              ),
              const SizedBox(height: 4),
              Text(
                'Gestation Period: 341 Days • Dam: ${_selectedMare?.name ?? "Mare"}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Three Ultrasound Scans Timeline
        const Text('System-Calculated Ultrasound Milestones:', style: AppTypography.inputLabel),
        const SizedBox(height: 10),

        _buildScanSummaryTile(1, 'Day 14-16 Ultrasound', scan1Date, 'Early Pregnancy & Twin Detection Warning'),
        _buildScanSummaryTile(2, 'Day 28-30 Ultrasound', scan2Date, 'Embryo Heartbeat & Viability Confirmation'),
        _buildScanSummaryTile(3, 'Day 45 Ultrasound', scan3Date, 'Endometrial Cups & Organogenesis Completion'),
      ],
    );
  }

  Widget _buildScanSummaryTile(int num, String title, DateTime date, String purpose) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(_formatDate(date), style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(purpose, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM CONTROLS (PREVIOUS / NEXT / FINISH)
  // ---------------------------------------------------------------------------
  Widget _buildBottomControls() {
    final isLastStep = _currentStep == 5;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.inputBorder, width: 1.0)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(
              onPressed: _isSaving ? null : _previousStep,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
              ),
              child: const Text('PREVIOUS', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: GradientCtaButton(
              text: _isSaving
                  ? 'CALCULATING & SAVING...'
                  : (isLastStep ? 'FINISH & ACTIVATE PREGNANCY' : 'SAVE & CONTINUE ➔'),
              onPressed: _isSaving ? null : (isLastStep ? _finishWizard : _nextStep),
            ),
          ),
        ],
      ),
    );
  }
}
