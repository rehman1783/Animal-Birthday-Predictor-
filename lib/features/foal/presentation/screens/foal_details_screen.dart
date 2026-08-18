import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_unsaved_changes_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../animals/presentation/widgets/select_or_add_animal_modal.dart';
import '../../../contacts/presentation/widgets/select_or_add_contact_modal.dart';
import '../../domain/foal_record.dart';
import '../providers/foal_provider.dart';
import '../../../../core/utils/app_uuid.dart';

class FoalDetailsScreen extends ConsumerStatefulWidget {
  final FoalRecord? foal;

  const FoalDetailsScreen({super.key, this.foal});

  @override
  ConsumerState<FoalDetailsScreen> createState() => _FoalDetailsScreenState();
}

class _FoalDetailsScreenState extends ConsumerState<FoalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _stallionController;
  late TextEditingController _breedController;
  late TextEditingController _iggController;
  late TextEditingController _microchipController;
  late TextEditingController _dnaController;
  late TextEditingController _studBookController;
  late TextEditingController _notesController;

  // New Owner / Buyer controllers
  late TextEditingController _buyerNameController;
  late TextEditingController _buyerPhoneController;
  late TextEditingController _buyerAddressController;
  late TextEditingController _salePriceController;
  DateTime? _saleDate;

  Animal? _selectedMare;
  Animal? _selectedRecipient;

  DateTime? _dateOfBirth = DateTime.now();
  String _sex = 'filly'; // 'filly', 'colt'
  bool _gelded = false;
  DateTime? _geldedDate;
  String _status = 'keep'; // 'sold', 'keep', 'transferred'
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final f = widget.foal;
    _nameController = TextEditingController(text: f?.foalName ?? '');
    _stallionController = TextEditingController(text: f?.stallion ?? '');
    _breedController = TextEditingController(text: f?.breed ?? '');
    _iggController = TextEditingController(text: f?.iggValue ?? '');
    _microchipController = TextEditingController(text: f?.foalMicrochipNo ?? '');
    _dnaController = TextEditingController(text: f?.dna ?? '');
    _studBookController = TextEditingController(text: f?.studBookAssociation ?? '');
    _notesController = TextEditingController(text: f?.notes ?? '');

    _buyerNameController = TextEditingController(text: f?.buyerName ?? '');
    _buyerPhoneController = TextEditingController(text: f?.buyerPhone ?? '');
    _buyerAddressController = TextEditingController(text: f?.buyerAddress ?? '');
    _salePriceController = TextEditingController(text: f?.salePrice ?? '');
    _saleDate = f?.saleDate;

    _dateOfBirth = f?.dateOfBirth ?? DateTime.now();
    _sex = f?.sex ?? 'filly';
    _gelded = f?.gelded ?? false;
    _geldedDate = f?.geldedDate;
    _status = f?.status ?? 'keep';
    _photoUrl = f?.photoUrl;

    if (f != null) {
      _loadLinkedAnimals(f);
    }
  }

  Future<void> _loadLinkedAnimals(FoalRecord f) async {
    try {
      final repo = ref.read(animalRepositoryProvider);
      if (f.mareAnimalId.isNotEmpty) {
        final m = await repo.getAnimalById(f.mareAnimalId);
        if (m != null && mounted) setState(() => _selectedMare = m);
      }
      if (f.recipientAnimalId != null && f.recipientAnimalId!.isNotEmpty) {
        final r = await repo.getAnimalById(f.recipientAnimalId!);
        if (r != null && mounted) setState(() => _selectedRecipient = r);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stallionController.dispose();
    _breedController.dispose();
    _iggController.dispose();
    _microchipController.dispose();
    _dnaController.dispose();
    _studBookController.dispose();
    _notesController.dispose();
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    _buyerAddressController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isGelded, bool isSale = false}) async {
    DateTime initial = DateTime.now();
    if (isSale) {
      initial = _saleDate ?? DateTime.now();
    } else if (isGelded) {
      initial = _geldedDate ?? DateTime.now();
    } else {
      initial = _dateOfBirth ?? DateTime.now();
    }

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
        if (isSale) {
          _saleDate = picked;
        } else if (isGelded) {
          _geldedDate = picked;
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
      title: 'Select Buyer / Owner Contact',
      defaultRole: 'buyer',
    );
    if (contact != null) {
      setState(() {
        _buyerNameController.text = contact.name;
        if (contact.phone?.isNotEmpty == true) {
          _buyerPhoneController.text = contact.phone!;
        }
        if (contact.notes?.isNotEmpty == true) {
          _buyerAddressController.text = contact.notes!;
        }
      });
    }
  }

  Future<void> _confirmDeleteFoal() async {
    if (widget.foal == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Foal Record', style: AppTypography.displayHeadline.copyWith(fontSize: 18)),
        content: Text(
          'Are you sure you want to delete the record for ${widget.foal?.foalName ?? "this foal"}? This action cannot be undone.',
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
      final repo = ref.read(foalRepositoryProvider);
      await repo.deleteFoal(widget.foal!.id);
      ref.invalidate(foalsListProvider);
      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Foal Deleted',
          message: '${widget.foal?.foalName ?? "Foal"} record deleted.',
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_selectedMare == null) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Mare Required',
        error: 'Please select or register the Dam Mare (* required).',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(foalRepositoryProvider);
      final foalId = widget.foal?.id.isNotEmpty == true
          ? widget.foal!.id
          : AppUuid.generate();

      final record = FoalRecord(
        id: foalId,
        accountId: widget.foal?.accountId ?? '',
        mareAnimalId: _selectedMare!.id,
        recipientAnimalId: _selectedRecipient?.id,
        foalName: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        stallion: _stallionController.text.trim(),
        breed: _breedController.text.trim(),
        sex: _sex,
        iggValue: _iggController.text.trim(),
        foalMicrochipNo: _microchipController.text.trim(),
        dna: _dnaController.text.trim(),
        gelded: _gelded,
        geldedDate: _gelded ? _geldedDate : null,
        studBookAssociation: _studBookController.text.trim(),
        notes: _notesController.text.trim(),
        status: _status,
        photoUrl: _photoUrl,
        buyerName: _status != 'keep' ? _buyerNameController.text.trim() : null,
        buyerPhone: _status != 'keep' ? _buyerPhoneController.text.trim() : null,
        buyerAddress: _status != 'keep' ? _buyerAddressController.text.trim() : null,
        saleDate: _status != 'keep' ? _saleDate : null,
        salePrice: _status != 'keep' ? _salePriceController.text.trim() : null,
        createdAt: widget.foal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveFoal(record);
      ref.invalidate(foalsListProvider);

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Foal Saved',
          message: '${saved.foalName?.isNotEmpty == true ? saved.foalName! : "Foal"} record saved successfully!',
        );
        Navigator.pop(context, saved);
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Foal Save Failed',
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _hasUnsavedChanges {
    final f = widget.foal;
    if (f == null) {
      return _nameController.text.trim().isNotEmpty ||
          _stallionController.text.trim().isNotEmpty ||
          _breedController.text.trim().isNotEmpty ||
          _selectedMare != null ||
          _photoUrl != null;
    }

    final isDobChanged = (_dateOfBirth == null && f.dateOfBirth != null) ||
        (_dateOfBirth != null && f.dateOfBirth == null) ||
        (_dateOfBirth != null &&
            f.dateOfBirth != null &&
            (_dateOfBirth!.year != f.dateOfBirth!.year ||
                _dateOfBirth!.month != f.dateOfBirth!.month ||
                _dateOfBirth!.day != f.dateOfBirth!.day));

    final isSaleDateChanged = (_saleDate == null && f.saleDate != null) ||
        (_saleDate != null && f.saleDate == null) ||
        (_saleDate != null &&
            f.saleDate != null &&
            (_saleDate!.year != f.saleDate!.year ||
                _saleDate!.month != f.saleDate!.month ||
                _saleDate!.day != f.saleDate!.day));

    final isGeldedDateChanged = (_geldedDate == null && f.geldedDate != null) ||
        (_geldedDate != null && f.geldedDate == null) ||
        (_geldedDate != null &&
            f.geldedDate != null &&
            (_geldedDate!.year != f.geldedDate!.year ||
                _geldedDate!.month != f.geldedDate!.month ||
                _geldedDate!.day != f.geldedDate!.day));

    final initialSex = (f.sex ?? 'filly').trim().toLowerCase();
    final currentSex = _sex.trim().toLowerCase();
    final initialStatus = (f.status ?? 'keep').trim().toLowerCase();
    final currentStatus = _status.trim().toLowerCase();
    final initialGelded = f.gelded ?? false;

    return _nameController.text.trim() != (f.foalName?.trim() ?? '') ||
        _stallionController.text.trim() != (f.stallion?.trim() ?? '') ||
        _breedController.text.trim() != (f.breed?.trim() ?? '') ||
        _iggController.text.trim() != (f.iggValue?.trim() ?? '') ||
        _microchipController.text.trim() != (f.foalMicrochipNo?.trim() ?? '') ||
        _dnaController.text.trim() != (f.dna?.trim() ?? '') ||
        _studBookController.text.trim() != (f.studBookAssociation?.trim() ?? '') ||
        _notesController.text.trim() != (f.notes?.trim() ?? '') ||
        _buyerNameController.text.trim() != (f.buyerName?.trim() ?? '') ||
        _buyerPhoneController.text.trim() != (f.buyerPhone?.trim() ?? '') ||
        _buyerAddressController.text.trim() != (f.buyerAddress?.trim() ?? '') ||
        _salePriceController.text.trim() != (f.salePrice?.trim() ?? '') ||
        isSaleDateChanged ||
        isDobChanged ||
        currentSex != initialSex ||
        _gelded != initialGelded ||
        isGeldedDateChanged ||
        currentStatus != initialStatus ||
        _photoUrl != f.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.foal != null;
    final foalId = widget.foal?.id ?? '';

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
            isEditing ? 'FOAL: ${widget.foal?.foalName ?? "RECORD"}' : 'NEW FOAL REGISTRATION',
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
                tooltip: 'Delete Foal Record',
                onPressed: _confirmDeleteFoal,
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
                  // 1. Foal Photo Header
                  AppImagePicker(
                    label: 'FOAL PHOTO (CAMERA / GALLERY) (Optional)',
                    initialImageUrl: _photoUrl,
                    onImageSelected: (url) => setState(() => _photoUrl = url),
                  ),
                  const SizedBox(height: 24.0),

                  // 2. Core Identity Card
                  const SectionDividerLabel(label: 'FOAL IDENTITY'),
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'Foal Name (Optional)',
                    hintText: 'e.g. Royal Starlight',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 14.0),

                  // Date of Birth
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date of Birth *', style: AppTypography.inputLabel),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickDate(isGelded: false),
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
                  const SizedBox(height: 14.0),

                  // Sex / Gender Switcher (Filly / Colt)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sex *', style: AppTypography.inputLabel),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _sex = 'filly'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _sex == 'filly' ? AppColors.primaryGold : AppColors.inputField,
                                foregroundColor: _sex == 'filly' ? AppColors.background : AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('FILLY (FEMALE)', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _sex = 'colt'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _sex == 'colt' ? AppColors.primaryGold : AppColors.inputField,
                                foregroundColor: _sex == 'colt' ? AppColors.background : AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('COLT (MALE)', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Breed (Optional)',
                          hintText: 'e.g. Thoroughbred',
                          controller: _breedController,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: CustomTextField(
                          label: 'IGG Value (Optional)',
                          hintText: 'e.g. >800 mg/dL (Normal)',
                          controller: _iggController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // 3. Lineage Pickers (Dam Mare & Recipient Mare)
                  const SectionDividerLabel(label: 'PARENTAGE & BREEDING LINEAGE'),
                  const SizedBox(height: 14.0),

                  // Dam Mare Picker (Required)
                  GestureDetector(
                    onTap: () async {
                      final chosen = await SelectOrAddAnimalModal.show(
                        context,
                        title: 'Select Dam (Mother)',
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
                          const Icon(Icons.pets, color: AppColors.primaryGold, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedMare != null ? 'Dam: ${_selectedMare!.name}' : 'Select Dam Mare *',
                                  style: AppTypography.displayHeadline.copyWith(
                                    fontSize: 16,
                                    color: _selectedMare != null ? AppColors.primaryGold : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedMare != null
                                      ? 'Microchip: ${_selectedMare!.microchipNo ?? "N/A"} • ${_selectedMare!.breed ?? "Equine"}'
                                      : 'Tap to select registered mother mare',
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
                    label: 'Sire / Stallion (Father) (Optional)',
                    hintText: 'e.g. Northern Dancer',
                    controller: _stallionController,
                  ),
                  const SizedBox(height: 12.0),

                  // Recipient Mare Picker (Optional if Embryo Transfer)
                  GestureDetector(
                    onTap: () async {
                      final chosen = await SelectOrAddAnimalModal.show(
                        context,
                        title: 'Select Recipient Mare (Optional)',
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
                        border: Border.all(color: AppColors.surface),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_border_rounded, color: AppColors.primaryGold, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedRecipient != null ? 'Recipient: ${_selectedRecipient!.name}' : 'Recipient Mare (Optional)',
                                  style: AppTypography.displayHeadline.copyWith(
                                    fontSize: 15,
                                    color: _selectedRecipient != null ? AppColors.primaryGold : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedRecipient != null
                                      ? 'Microchip: ${_selectedRecipient!.microchipNo ?? "N/A"}'
                                      : 'Only if carried by a surrogate recipient mare',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedRecipient != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                              onPressed: () => setState(() => _selectedRecipient = null),
                            )
                          else
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // 4. Identifiers & Status
                  const SectionDividerLabel(label: 'IDENTIFICATION & BREEDER STATUS'),
                  const SizedBox(height: 14.0),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Foal Microchip No. (Optional)',
                          hintText: '15-digit ISO microchip',
                          controller: _microchipController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: CustomTextField(
                          label: 'DNA Profile (Optional)',
                          hintText: 'e.g. DNA-8921',
                          controller: _dnaController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'Stud Book / Breeding Association (Optional)',
                    hintText: 'e.g. Australian Stud Book / AQHA',
                    controller: _studBookController,
                  ),
                  const SizedBox(height: 14.0),

                  // Gelded Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _gelded,
                              onChanged: (val) => setState(() => _gelded = val ?? false),
                              activeColor: AppColors.primaryGold,
                              checkColor: AppColors.background,
                              side: const BorderSide(color: AppColors.primaryGold),
                            ),
                            const Text('Gelded (Castrated)', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                        if (_gelded) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _pickDate(isGelded: true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.inputField,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Gelded Date: ${_formatDate(_geldedDate)}', style: const TextStyle(color: AppColors.primaryGold)),
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryGold),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14.0),

                  // Status Selector (Sold / Keep / Transferred)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Foal Status *', style: AppTypography.inputLabel),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('KEEP', style: TextStyle(fontWeight: FontWeight.bold)),
                            selected: _status == 'keep',
                            selectedColor: AppColors.primaryGold,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: _status == 'keep' ? AppColors.background : AppColors.textPrimary,
                            ),
                            onSelected: (_) => setState(() => _status = 'keep'),
                          ),
                          ChoiceChip(
                            label: const Text('SOLD', style: TextStyle(fontWeight: FontWeight.bold)),
                            selected: _status == 'sold',
                            selectedColor: AppColors.primaryGold,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: _status == 'sold' ? AppColors.background : AppColors.textPrimary,
                            ),
                            onSelected: (_) => setState(() => _status = 'sold'),
                          ),
                          ChoiceChip(
                            label: const Text('TRANSFERRED', style: TextStyle(fontWeight: FontWeight.bold)),
                            selected: _status == 'transferred',
                            selectedColor: AppColors.primaryGold,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: _status == 'transferred' ? AppColors.background : AppColors.textPrimary,
                            ),
                            onSelected: (_) => setState(() => _status = 'transferred'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Dynamic Buyer / New Owner Section (Only if Sold or Transferred)
                  if (_status == 'sold' || _status == 'transferred') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _status == 'sold' ? 'SOLD TO (OPTIONAL)' : 'TRANSFERRED TO (OPTIONAL)',
                                style: AppTypography.sectionLabel,
                              ),
                              TextButton.icon(
                                onPressed: _pickBuyerFromContacts,
                                icon: const Icon(Icons.contacts_outlined, size: 16, color: AppColors.primaryGold),
                                label: const Text('From Contacts', style: TextStyle(color: AppColors.primaryGold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: 'New Owner / Buyer Name (Optional)',
                            hintText: 'e.g. James & Linda Sterling',
                            controller: _buyerNameController,
                            prefixIcon: Icons.person_outline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14.0),
                  ],

                  CustomTextField(
                    label: 'Breeder Notes (Optional)',
                    hintText: 'Temperament, growth notes, conformation observations...',
                    controller: _notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24.0),

                  // 5. Foal Actions (Markings, Health, Certificate)
                  if (isEditing && foalId.isNotEmpty) ...[
                    const SectionDividerLabel(label: 'FOAL CARE & DOCUMENTS'),
                    const SizedBox(height: 14.0),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/markings',
                                arguments: {'ownerType': 'foal', 'ownerId': foalId},
                              );
                            },
                            icon: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGold, size: 16),
                            label: Text(
                              'MARKINGS',
                              style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/preventative-care',
                                arguments: {
                                  'ownerType': 'foal',
                                  'ownerId': foalId,
                                  'title': widget.foal?.foalName ?? 'Foal',
                                  'damMareId': widget.foal?.mareAnimalId,
                                },
                              );
                            },
                            icon: const Icon(Icons.healing_outlined, color: AppColors.primaryGold, size: 16),
                            label: Text(
                              'HEALTH',
                              style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/certificate',
                                arguments: {'foal': widget.foal, 'dam': _selectedMare},
                              );
                            },
                            icon: const Icon(Icons.card_membership_outlined, color: AppColors.primaryGold, size: 16),
                            label: Text(
                              'CERTIFICATE',
                              style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                    text: _isSaving ? 'SAVING FOAL RECORD...' : (isEditing ? 'UPDATE FOAL RECORD' : 'SAVE FOAL RECORD'),
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
