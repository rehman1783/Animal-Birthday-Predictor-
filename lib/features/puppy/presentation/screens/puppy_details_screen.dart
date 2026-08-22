import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_uuid.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_unsaved_changes_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../animals/presentation/widgets/select_or_add_animal_modal.dart';
import '../../../contacts/presentation/widgets/select_or_add_contact_modal.dart';
import '../../domain/puppy.dart';
import '../providers/puppy_provider.dart';
import 'dog_preventative_care_screen.dart';
import 'puppy_weight_tracker_screen.dart';

class PuppyDetailsScreen extends ConsumerStatefulWidget {
  final Puppy? puppy;

  const PuppyDetailsScreen({super.key, this.puppy});

  @override
  ConsumerState<PuppyDetailsScreen> createState() => _PuppyDetailsScreenState();
}

class _PuppyDetailsScreenState extends ConsumerState<PuppyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _collarController;
  late TextEditingController _colourController;
  late TextEditingController _birthOrderController;
  late TextEditingController _birthWeightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _microchipController;
  late TextEditingController _dnaController;
  late TextEditingController _sireNameController;
  late TextEditingController _newOwnerNameController;
  late TextEditingController _newOwnerPhoneController;
  late TextEditingController _newOwnerAddressController;
  late TextEditingController _generalNotesController;

  Animal? _selectedDam;
  DateTime? _dateOfBirth = DateTime.now();
  DateTime? _dateGoingHome;
  String _sex = 'male'; // 'male', 'female'
  String _status = 'available'; // 'available', 'reserved', 'sold', 'keep', 'transferred'
  String? _photoUrl;
  bool _isSaving = false;

  final List<String> _collarColors = const [
    'Red', 'Blue', 'Green', 'Yellow', 'Pink', 'Purple', 'Orange', 'Black', 'White', 'Brown'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.puppy;
    _nameController = TextEditingController(text: p?.puppyName ?? '');
    _collarController = TextEditingController(text: p?.collarTagColour ?? '');
    _colourController = TextEditingController(text: p?.colour ?? '');
    _birthOrderController = TextEditingController(text: p?.birthOrder?.toString() ?? '');
    _birthWeightController = TextEditingController(text: p?.birthWeight ?? '');
    _currentWeightController = TextEditingController(text: p?.currentWeight ?? '');
    _microchipController = TextEditingController(text: p?.microchipNo ?? '');
    _dnaController = TextEditingController(text: p?.dna ?? '');
    _sireNameController = TextEditingController(text: p?.sireName ?? '');
    _newOwnerNameController = TextEditingController(text: p?.newOwnerName ?? '');
    _newOwnerPhoneController = TextEditingController(text: p?.newOwnerPhone ?? '');
    _newOwnerAddressController = TextEditingController(text: p?.newOwnerAddress ?? '');
    _generalNotesController = TextEditingController(text: p?.generalNotes ?? '');

    _dateOfBirth = p?.dateOfBirth ?? DateTime.now();
    _dateGoingHome = p?.dateGoingHome;
    _sex = p?.sex ?? 'male';
    _status = p?.status ?? 'available';
    _photoUrl = p?.photoUrl;

    if (p != null && p.damAnimalId?.isNotEmpty == true) {
      _loadDamAnimal(p.damAnimalId!);
    }
  }

  Future<void> _loadDamAnimal(String damId) async {
    try {
      final repo = ref.read(animalRepositoryProvider);
      final dam = await repo.getAnimalById(damId);
      if (dam != null && mounted) {
        setState(() => _selectedDam = dam);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collarController.dispose();
    _colourController.dispose();
    _birthOrderController.dispose();
    _birthWeightController.dispose();
    _currentWeightController.dispose();
    _microchipController.dispose();
    _dnaController.dispose();
    _sireNameController.dispose();
    _newOwnerNameController.dispose();
    _newOwnerPhoneController.dispose();
    _newOwnerAddressController.dispose();
    _generalNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isGoingHome}) async {
    final initial = (isGoingHome ? _dateGoingHome : _dateOfBirth) ?? DateTime.now();
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
      setState(() {
        if (isGoingHome) {
          _dateGoingHome = picked;
        } else {
          _dateOfBirth = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _pickBuyerFromContacts() async {
    final contact = await SelectOrAddContactModal.show(
      context,
      title: 'Select New Owner Contact',
      defaultRole: 'buyer',
    );
    if (contact != null) {
      setState(() {
        _newOwnerNameController.text = contact.name;
        if (contact.phone?.isNotEmpty == true) {
          _newOwnerPhoneController.text = contact.phone!;
        }
        if (contact.notes?.isNotEmpty == true) {
          _newOwnerAddressController.text = contact.notes!;
        }
      });
    }
  }

  Future<void> _confirmDeletePuppy() async {
    if (widget.puppy == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Puppy Record', style: AppTypography.displayHeadline.copyWith(fontSize: 18)),
        content: Text(
          'Are you sure you want to delete ${widget.puppy?.puppyName ?? "this puppy"}? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
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
      final repo = ref.read(puppyRepositoryProvider);
      await repo.deletePuppy(widget.puppy!.id);
      ref.invalidate(puppiesListProvider(null));
      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Puppy Deleted',
          message: '${widget.puppy?.puppyName ?? "Puppy"} record deleted.',
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(puppyRepositoryProvider);
      final puppyId = widget.puppy?.id.isNotEmpty == true
          ? widget.puppy!.id
          : AppUuid.generate();

      final puppy = Puppy(
        id: puppyId,
        accountId: widget.puppy?.accountId ?? '',
        damAnimalId: _selectedDam?.id,
        sireName: _sireNameController.text.trim(),
        puppyName: _nameController.text.trim(),
        collarTagColour: _collarController.text.trim(),
        sex: _sex,
        colour: _colourController.text.trim(),
        birthOrder: int.tryParse(_birthOrderController.text.trim()),
        dateOfBirth: _dateOfBirth,
        birthWeight: _birthWeightController.text.trim(),
        currentWeight: _currentWeightController.text.trim(),
        microchipNo: _microchipController.text.trim(),
        dna: _dnaController.text.trim(),
        status: _status,
        dateGoingHome: _dateGoingHome,
        newOwnerName: _newOwnerNameController.text.trim(),
        newOwnerPhone: _newOwnerPhoneController.text.trim(),
        newOwnerAddress: _newOwnerAddressController.text.trim(),
        generalNotes: _generalNotesController.text.trim(),
        photoUrl: _photoUrl,
        createdAt: widget.puppy?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.savePuppy(puppy);
      ref.invalidate(puppiesListProvider(null));
      ref.invalidate(puppyByIdProvider(saved.id));

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Puppy Saved',
          message: '${saved.puppyName?.isNotEmpty == true ? saved.puppyName! : "Puppy"} details saved successfully!',
        );
        Navigator.pop(context, saved);
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Puppy Save Failed',
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _hasUnsavedChanges {
    final p = widget.puppy;
    if (p == null) {
      return _nameController.text.trim().isNotEmpty ||
          _collarController.text.trim().isNotEmpty ||
          _colourController.text.trim().isNotEmpty ||
          _selectedDam != null ||
          _photoUrl != null;
    }

    final isDobChanged = (_dateOfBirth == null && p.dateOfBirth != null) ||
        (_dateOfBirth != null && p.dateOfBirth == null) ||
        (_dateOfBirth != null &&
            p.dateOfBirth != null &&
            (_dateOfBirth!.year != p.dateOfBirth!.year ||
                _dateOfBirth!.month != p.dateOfBirth!.month ||
                _dateOfBirth!.day != p.dateOfBirth!.day));

    final isGoingHomeChanged = (_dateGoingHome == null && p.dateGoingHome != null) ||
        (_dateGoingHome != null && p.dateGoingHome == null) ||
        (_dateGoingHome != null &&
            p.dateGoingHome != null &&
            (_dateGoingHome!.year != p.dateGoingHome!.year ||
                _dateGoingHome!.month != p.dateGoingHome!.month ||
                _dateGoingHome!.day != p.dateGoingHome!.day));

    final initialSex = (p.sex ?? 'male').trim().toLowerCase();
    final currentSex = _sex.trim().toLowerCase();
    final initialStatus = (p.status ?? 'available').trim().toLowerCase();
    final currentStatus = _status.trim().toLowerCase();

    return _nameController.text.trim() != (p.puppyName?.trim() ?? '') ||
        _collarController.text.trim() != (p.collarTagColour?.trim() ?? '') ||
        _colourController.text.trim() != (p.colour?.trim() ?? '') ||
        _birthOrderController.text.trim() != (p.birthOrder?.toString() ?? '') ||
        _birthWeightController.text.trim() != (p.birthWeight?.trim() ?? '') ||
        _currentWeightController.text.trim() != (p.currentWeight?.trim() ?? '') ||
        _microchipController.text.trim() != (p.microchipNo?.trim() ?? '') ||
        _dnaController.text.trim() != (p.dna?.trim() ?? '') ||
        _sireNameController.text.trim() != (p.sireName?.trim() ?? '') ||
        _newOwnerNameController.text.trim() != (p.newOwnerName?.trim() ?? '') ||
        _newOwnerPhoneController.text.trim() != (p.newOwnerPhone?.trim() ?? '') ||
        _newOwnerAddressController.text.trim() != (p.newOwnerAddress?.trim() ?? '') ||
        _generalNotesController.text.trim() != (p.generalNotes?.trim() ?? '') ||
        isDobChanged ||
        isGoingHomeChanged ||
        currentSex != initialSex ||
        currentStatus != initialStatus ||
        _photoUrl != p.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.puppy != null;
    final puppyId = widget.puppy?.id ?? '';

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
          title: Text(
            isEditing ? 'PUPPY: ${widget.puppy?.puppyName ?? "RECORD"}' : 'NEW PUPPY REGISTRATION',
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
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryGold),
                    )
                  : const Icon(Icons.check_rounded, color: AppColors.primaryGold, size: 18),
              label: Text(
                isEditing ? 'UPDATE' : 'SAVE',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete Puppy Record',
                onPressed: _confirmDeletePuppy,
              ),
          ],
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
                  // 1. Puppy Photo
                  AppImagePicker(
                    label: 'PUPPY PHOTO (CAMERA / GALLERY) (Optional)',
                    initialImageUrl: _photoUrl,
                    onImageSelected: (url) => setState(() => _photoUrl = url),
                  ),
                  const SizedBox(height: 24.0),

                  // 2. Puppy Identification
                  const SectionDividerLabel(label: 'PUPPY IDENTIFICATION'),
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'Puppy Name / ID *',
                    hintText: 'e.g. Max (Red Collar)',
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Puppy Name/ID is required' : null,
                  ),
                  const SizedBox(height: 14.0),

                  // Collar / Tag Colour Selector & Custom text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Collar / Tag Colour (Optional)', style: AppTypography.inputLabel),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _collarColors.map((color) {
                            final isSelected = _collarController.text.toLowerCase() == color.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(color),
                                selected: isSelected,
                                selectedColor: AppColors.primaryGold,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.background : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) => setState(() => _collarController.text = color),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        label: 'Or Custom Collar/Band Name (Optional)',
                        hintText: 'e.g. Teal with Stars, Neon Green...',
                        controller: _collarController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Sex & Birth Order
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sex *', style: AppTypography.inputLabel),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => setState(() => _sex = 'male'),
                                    icon: Icon(
                                      Icons.pets,
                                      size: 14,
                                      color: _sex == 'male' ? AppColors.background : AppColors.primaryGold,
                                    ),
                                    label: const Text('MALE', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _sex == 'male' ? AppColors.primaryGold : AppColors.inputField,
                                      foregroundColor: _sex == 'male' ? AppColors.background : AppColors.textPrimary,
                                      side: const BorderSide(color: AppColors.primaryGold),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => setState(() => _sex = 'female'),
                                    icon: Icon(
                                      Icons.pets,
                                      size: 14,
                                      color: _sex == 'female' ? AppColors.background : AppColors.primaryGold,
                                    ),
                                    label: const Text('FEMALE', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _sex == 'female' ? AppColors.primaryGold : AppColors.inputField,
                                      foregroundColor: _sex == 'female' ? AppColors.background : AppColors.textPrimary,
                                      side: const BorderSide(color: AppColors.primaryGold),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: CustomTextField(
                          label: 'Birth Order (Optional)',
                          hintText: 'e.g. 1',
                          controller: _birthOrderController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Coat Colour / Pattern (Optional)',
                          hintText: 'e.g. Golden, Tricolour',
                          controller: _colourController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Microchip No. (Optional)',
                          hintText: '15-digit ISO chip',
                          controller: _microchipController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Date of Birth
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date of Birth *', style: AppTypography.inputLabel),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickDate(isGoingHome: false),
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
                                _formatDate(_dateOfBirth),
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

                  // 3. Parentage / Breeding Lineage
                  const SectionDividerLabel(label: 'DAM & SIRE (PARENTS)'),
                  const SizedBox(height: 14.0),

                  GestureDetector(
                    onTap: () async {
                      final chosen = await SelectOrAddAnimalModal.show(
                        context,
                        title: 'Select Mother (Dam Dog)',
                        species: 'dog',
                        currentSelectedId: _selectedDam?.id,
                      );
                      if (chosen != null) setState(() => _selectedDam = chosen);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(
                          color: _selectedDam != null ? AppColors.primaryGold : AppColors.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          AppThumbnailAvatar(
                            imagePath: _selectedDam?.photoUrl,
                            species: 'dog',
                            customFallback: const Icon(Icons.pets, size: 24, color: AppColors.primaryGold),
                            size: 40,
                            iconSize: 20,
                            isCircle: true,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedDam != null ? 'Mother: ${_selectedDam!.name}' : 'Select Mother (Dam Dog)',
                                  style: AppTypography.displayHeadline.copyWith(
                                    fontSize: 16,
                                    color: _selectedDam != null ? AppColors.primaryGold : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedDam != null
                                      ? 'Breed: ${_selectedDam!.breed ?? "Canine"} • Chip: ${_selectedDam!.microchipNo ?? "N/A"}'
                                      : 'Tap to select registered mother dog',
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
                  const SizedBox(height: 12.0),

                  CustomTextField(
                    label: 'Father / Sire Name (Optional)',
                    hintText: 'e.g. Champion Duke of Windsor',
                    controller: _sireNameController,
                  ),
                  const SizedBox(height: 24.0),

                  // 4. Weights & Growth
                  const SectionDividerLabel(label: 'WEIGHT & GROWTH TRACKING'),
                  const SizedBox(height: 14.0),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Birth Weight (Optional)',
                          hintText: 'e.g. 420g',
                          controller: _birthWeightController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Current / Exit Weight (Optional)',
                          hintText: 'e.g. 3.4kg',
                          controller: _currentWeightController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // 5. Status & Going Home Information
                  const SectionDividerLabel(label: 'STATUS & GOING HOME DETAILS'),
                  const SizedBox(height: 14.0),

                  // Status Chips
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Availability / Status *', style: AppTypography.inputLabel),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['available', 'reserved', 'sold', 'keep', 'transferred'].map((st) {
                            final isSel = _status == st;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(st.toUpperCase()),
                                selected: isSel,
                                selectedColor: AppColors.primaryGold,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  color: isSel ? AppColors.background : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) => setState(() => _status = st),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Date Going Home
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date Going Home (Optional)', style: AppTypography.inputLabel),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickDate(isGoingHome: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.inputField,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(color: AppColors.surface),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_dateGoingHome),
                                style: TextStyle(
                                  color: _dateGoingHome != null ? AppColors.textPrimary : AppColors.textMuted,
                                ),
                              ),
                              const Icon(Icons.home_outlined, size: 18, color: AppColors.primaryGold),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // New Owner Details
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('NEW OWNER / HOME', style: AppTypography.sectionLabel),
                            TextButton.icon(
                              onPressed: _pickBuyerFromContacts,
                              icon: const Icon(Icons.contacts_outlined, size: 16, color: AppColors.primaryGold),
                              label: const Text('From Contacts', style: TextStyle(color: AppColors.primaryGold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'New Owner Name (Optional)',
                          hintText: 'e.g. Robert & Clara Williams',
                          controller: _newOwnerNameController,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'Contact Phone Number (Optional)',
                          hintText: 'e.g. +1 (555) 349-1029',
                          controller: _newOwnerPhoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'New Address / Property (Optional)',
                          hintText: 'e.g. 21 Oak Street, Springfield',
                          controller: _newOwnerAddressController,
                          prefixIcon: Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'General Notes & Observations (Optional)',
                    hintText: 'Temperament, socialization progress, training notes...',
                    controller: _generalNotesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24.0),

                  // 6. Care & Documents Shortcuts
                  if (isEditing && puppyId.isNotEmpty) ...[
                    const SectionDividerLabel(label: 'PUPPY CARE & CERTIFICATE'),
                    const SizedBox(height: 14.0),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DogPreventativeCareScreen(
                                    ownerType: 'puppy',
                                    ownerId: puppyId,
                                    title: widget.puppy?.puppyName ?? 'Puppy',
                                    dateOfBirth: _dateOfBirth,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.healing_outlined, color: AppColors.primaryGold, size: 15),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'HEALTH',
                                style: TextStyle(color: AppColors.primaryGold, fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PuppyWeightTrackerScreen(puppy: widget.puppy!),
                                ),
                              );
                            },
                            icon: const Icon(Icons.monitor_weight_outlined, color: AppColors.primaryGold, size: 15),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'WEIGHTS',
                                style: TextStyle(color: AppColors.primaryGold, fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/certificate',
                                arguments: {'puppy': widget.puppy, 'dam': _selectedDam},
                              );
                            },
                            icon: const Icon(Icons.card_membership_outlined, color: AppColors.primaryGold, size: 15),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CERTIFICATE',
                                style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                  ],

                  // Save CTA
                  GradientCtaButton(
                    text: _isSaving ? 'SAVING DETAILS...' : (isEditing ? 'UPDATE PUPPY DETAILS' : 'SAVE PUPPY TO REGISTRY'),
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
