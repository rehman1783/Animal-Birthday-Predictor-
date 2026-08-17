import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
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

  final _stallionController = TextEditingController();
  final _damOfEmbryoController = TextEditingController();
  final _stallionOfEmbryoController = TextEditingController();

  String? _selectedMethod = 'natural'; // 'natural', 'chilled', 'frozen', 'icsi'
  bool _isEmbryoTransfer = false;
  DateTime _coverDate = DateTime.now();
  DateTime _transferDate = DateTime.now();
  String? _photoUrl;
  bool _isSaving = false;

  final List<({String label, String value})> _methods = const [
    (label: 'Natural', value: 'natural'),
    (label: 'Chilled', value: 'chilled'),
    (label: 'Frozen', value: 'frozen'),
    (label: 'ICSI', value: 'icsi'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMareId != null && widget.initialMareId!.isNotEmpty) {
      _loadInitialMare(widget.initialMareId!);
    }
  }

  Future<void> _loadInitialMare(String id) async {
    final repo = ref.read(animalRepositoryProvider);
    final animal = await repo.getAnimalById(id);
    if (animal != null && mounted) {
      setState(() => _selectedMare = animal);
    }
  }

  @override
  void dispose() {
    _stallionController.dispose();
    _damOfEmbryoController.dispose();
    _stallionOfEmbryoController.dispose();
    super.dispose();
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
      setState(() {
        if (isTransfer) {
          _transferDate = picked;
        } else {
          _coverDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _handleSave() async {
    if (_selectedMare == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or register the donor mare.')),
      );
      return;
    }

    if (_isEmbryoTransfer && _selectedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or register the recipient mare carrying the embryo.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final breedingId = DateTime.now().millisecondsSinceEpoch.toString();

      final breedingRecord = BreedingRecord(
        id: breedingId,
        accountId: '',
        mareAnimalId: _selectedMare!.id,
        stallionName: _stallionController.text.trim(),
        method: _selectedMethod ?? 'natural',
        coverOrTransferDate: _coverDate,
        isEmbryoTransfer: _isEmbryoTransfer,
        recipientAnimalId: _isEmbryoTransfer ? _selectedRecipient?.id : null,
        damOfEmbryo: _isEmbryoTransfer ? _damOfEmbryoController.text.trim() : null,
        stallionOfEmbryo: _isEmbryoTransfer ? _stallionOfEmbryoController.text.trim() : null,
        photoUrl: _photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedBreeding = await repo.saveBreedingRecord(breedingRecord);

      // Automatically compute pregnancy dates and insert pregnancy record
      final carrierAnimalId = _isEmbryoTransfer ? _selectedRecipient!.id : _selectedMare!.id;
      final baseDate = _isEmbryoTransfer ? _transferDate : _coverDate;

      final createdPregnancy = await repo.createCalculatedPregnancyRecord(
        carrierAnimalId: carrierAnimalId,
        breedingRecordId: savedBreeding.id,
        method: _selectedMethod ?? 'natural',
        isEmbryoTransfer: _isEmbryoTransfer,
        baseDate: baseDate,
      );

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Breeding Recorded',
          message: 'Pregnancy scans and foaling due date calculated successfully!',
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
        title: const Text('BREEDING DETAILS', style: AppTypography.sectionLabel),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                // 1. Mare Picker Card
                const SectionDividerLabel(label: 'DONOR MARE (MOTHER)'),
                const SizedBox(height: 12.0),

                GestureDetector(
                  onTap: () async {
                    final chosen = await SelectOrAddAnimalModal.show(
                      context,
                      title: 'Select Donor Mare',
                      species: 'horse',
                      currentSelectedId: _selectedMare?.id,
                    );
                    if (chosen != null) setState(() => _selectedMare = chosen);
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
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.inputField,
                            border: Border.all(color: AppColors.primaryGold),
                          ),
                          child: const Icon(Icons.pets, color: AppColors.primaryGold, size: 24),
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

                // 2. Sire / Stallion Field
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
                        );
                        if (chosen != null) {
                          setState(() => _stallionController.text = chosen.name);
                        }
                      },
                      icon: const Icon(Icons.pets, size: 14, color: AppColors.primaryGold),
                      label: const Text('Pick Saved', style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),

                CustomTextField(
                  label: 'Stallion Name / Stud (Optional)',
                  hintText: 'e.g. Northern Dancer (External Stud or Saved)',
                  controller: _stallionController,
                  prefixIcon: Icons.pets_outlined,
                ),
                const SizedBox(height: 24.0),

                // 3. Breeding Method Selector Chips
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
                        if (val) setState(() => _selectedMethod = m.value);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24.0),

                // 4. Embryo Transfer Question
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Was the resulting embryo transferred to a recipient mare?',
                        style: AppTypography.displayHeadline.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Embryo transfer flushes the fertilized embryo to be carried to term by a surrogate recipient mare.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _isEmbryoTransfer = false),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: !_isEmbryoTransfer ? AppColors.primaryGold : AppColors.inputField,
                                foregroundColor: !_isEmbryoTransfer ? AppColors.background : AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('NO (Donor Mare Carries)', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _isEmbryoTransfer = true),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _isEmbryoTransfer ? AppColors.primaryGold : AppColors.inputField,
                                foregroundColor: _isEmbryoTransfer ? AppColors.background : AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('YES (Recipient Carries)', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // 5. If Embryo Transfer: Recipient & Genetic Origin Fields
                if (_isEmbryoTransfer) ...[
                  const SectionDividerLabel(label: 'RECIPIENT MARE & EMBRYO GENETICS'),
                  const SizedBox(height: 12.0),

                  GestureDetector(
                    onTap: () async {
                      final chosen = await SelectOrAddAnimalModal.show(
                        context,
                        title: 'Select Recipient Mare',
                        species: 'horse',
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
                          const Icon(Icons.favorite_border_rounded, color: AppColors.primaryGold, size: 24),
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
                                      ? 'Chip: ${_selectedRecipient!.microchipNo ?? "N/A"}'
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
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'DAM of Embryo (Genetic Mother) (Optional)',
                    hintText: 'e.g. Celestial Queen',
                    controller: _damOfEmbryoController,
                  ),
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'Stallion of Embryo (Genetic Father) (Optional)',
                    hintText: 'e.g. Storm Chaser',
                    controller: _stallionOfEmbryoController,
                  ),
                  const SizedBox(height: 14.0),

                  // Transfer Date Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Embryo Transfer Date *', style: AppTypography.inputLabel),
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
                              Text(
                                _formatDate(_transferDate),
                                style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryGold),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                ],

                // 6. Cover / Insemination Date (if not ET)
                if (!_isEmbryoTransfer) ...[
                  const SectionDividerLabel(label: 'COVER / INSEMINATION DATE'),
                  const SizedBox(height: 12.0),

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
                          Text(
                            _formatDate(_coverDate),
                            style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryGold),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],

                // 7. Photo Upload (Straws / Certificate)
                const SectionDividerLabel(label: 'BREEDING PHOTO / INSEMINATION STRAWS'),
                const SizedBox(height: 12.0),

                AppImagePicker(
                  label: 'Insemination Straws / Cover Photo (Optional)',
                  initialImageUrl: _photoUrl,
                  onImageSelected: (url) => setState(() => _photoUrl = url),
                ),
                const SizedBox(height: 32.0),

                // 8. Submit CTA
                GradientCtaButton(
                  text: _isSaving ? 'CALCULATING PREGNANCY...' : 'SAVE & CALCULATE PREGNANCY',
                  onPressed: _isSaving ? null : _handleSave,
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
