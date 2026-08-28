import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_phone_launcher.dart';
import '../../../../core/utils/keyboard_helper.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_unsaved_changes_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/domain/markings.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../animals/presentation/providers/mare_provider.dart';
import '../../../animals/presentation/widgets/select_or_add_animal_modal.dart';
import '../../../contacts/presentation/widgets/select_or_add_contact_modal.dart';
import '../../domain/foal_record.dart';
import '../providers/foal_provider.dart';
import '../../../../core/utils/app_uuid.dart';

class FoalDetailsScreen extends ConsumerStatefulWidget {
  final FoalRecord? foal;
  final String? initialMareId;
  final String? initialStallion;

  const FoalDetailsScreen({
    super.key,
    this.foal,
    this.initialMareId,
    this.initialStallion,
  });

  @override
  ConsumerState<FoalDetailsScreen> createState() => _FoalDetailsScreenState();
}

class _FoalDetailsScreenState extends ConsumerState<FoalDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Clinical & Identity Controllers
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

  // Markings Controllers
  final _headNotesController = TextEditingController();
  String? _existingMarkingsId;
  String? _headViewImage;
  String? _leftSideImage;
  String? _rightSideImage;
  Markings? _initialMarkings;

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
    _tabController = TabController(length: 2, vsync: this);

    final f = widget.foal;
    _nameController = TextEditingController(text: f?.foalName ?? '');
    _stallionController = TextEditingController(text: f?.stallion ?? widget.initialStallion ?? '');
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
      _loadMarkings(f.id);
    } else if (widget.initialMareId != null && widget.initialMareId!.isNotEmpty) {
      _loadInitialMare(widget.initialMareId!);
    }
  }

  Future<void> _loadInitialMare(String mareId) async {
    try {
      final repo = ref.read(animalRepositoryProvider);
      final m = await repo.getAnimalById(mareId);
      if (m != null && mounted) {
        setState(() {
          _selectedMare = m;
          if (_breedController.text.isEmpty && m.breed != null) {
            _breedController.text = m.breed!;
          }
        });
      }
    } catch (_) {}
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

  Future<void> _loadMarkings(String foalId) async {
    try {
      final repo = ref.read(mareRepositoryProvider);
      final m = await repo.getMarkings('foal', foalId);
      if (m != null && mounted) {
        setState(() {
          _initialMarkings = m;
          _existingMarkingsId = m.id;
          _headViewImage = m.headViewImageUrl;
          _leftSideImage = m.leftSideImageUrl;
          _rightSideImage = m.rightSideImageUrl;
          _headNotesController.text = m.headViewNotes ?? '';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    _headNotesController.dispose();
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
      _tabController.animateTo(0);
      AppFeedbackSnackbar.showError(
        context,
        title: 'Dam (Mare) Required',
        error: 'Please select the Mother / Dam (Mare) before saving the foal record.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(foalRepositoryProvider);
      final mareRepo = ref.read(mareRepositoryProvider);

      final record = FoalRecord(
        id: widget.foal?.id ?? AppUuid.generate(),
        accountId: widget.foal?.accountId ?? '',
        mareAnimalId: _selectedMare!.id,
        recipientAnimalId: _selectedRecipient?.id,
        foalName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        dateOfBirth: _dateOfBirth,
        stallion: _stallionController.text.trim().isNotEmpty ? _stallionController.text.trim() : null,
        breed: _breedController.text.trim().isNotEmpty ? _breedController.text.trim() : null,
        sex: _sex,
        iggValue: _iggController.text.trim().isNotEmpty ? _iggController.text.trim() : null,
        foalMicrochipNo: _microchipController.text.trim().isNotEmpty ? _microchipController.text.trim() : null,
        dna: _dnaController.text.trim().isNotEmpty ? _dnaController.text.trim() : null,
        gelded: _gelded,
        geldedDate: _gelded ? _geldedDate : null,
        studBookAssociation: _studBookController.text.trim().isNotEmpty ? _studBookController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        status: _status,
        photoUrl: _photoUrl,
        buyerName: _status != 'keep' && _buyerNameController.text.trim().isNotEmpty ? _buyerNameController.text.trim() : null,
        buyerPhone: _status != 'keep' && _buyerPhoneController.text.trim().isNotEmpty ? _buyerPhoneController.text.trim() : null,
        buyerAddress: _status != 'keep' && _buyerAddressController.text.trim().isNotEmpty ? _buyerAddressController.text.trim() : null,
        saleDate: _status != 'keep' ? _saleDate : null,
        salePrice: _status != 'keep' && _salePriceController.text.trim().isNotEmpty ? _salePriceController.text.trim() : null,
        createdAt: widget.foal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveFoal(record);

      // Persist Markings if any image or note is provided
      if (_headViewImage != null || _leftSideImage != null || _rightSideImage != null || _headNotesController.text.trim().isNotEmpty) {
        final markings = Markings(
          id: _existingMarkingsId ?? AppUuid.generate(),
          ownerType: 'foal',
          ownerId: saved.id,
          leftSideImageUrl: _leftSideImage,
          rightSideImageUrl: _rightSideImage,
          headViewImageUrl: _headViewImage,
          headViewNotes: _headNotesController.text.trim().isNotEmpty ? _headNotesController.text.trim() : null,
          createdAt: _initialMarkings?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final savedMarkings = await mareRepo.saveMarkings(markings);
        _initialMarkings = savedMarkings;
        _existingMarkingsId = savedMarkings.id;
        ref.invalidate(markingsForOwnerProvider((ownerType: 'foal', ownerId: saved.id)));
      }

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
    final m = _initialMarkings;

    final markingsChanged = _headViewImage != m?.headViewImageUrl ||
        _leftSideImage != m?.leftSideImageUrl ||
        _rightSideImage != m?.rightSideImageUrl ||
        _headNotesController.text.trim() != (m?.headViewNotes?.trim() ?? '');

    if (f == null) {
      return _nameController.text.trim().isNotEmpty ||
          _stallionController.text.trim().isNotEmpty ||
          _breedController.text.trim().isNotEmpty ||
          _selectedMare?.id != widget.initialMareId ||
          _photoUrl != null ||
          markingsChanged;
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
        _photoUrl != f.photoUrl ||
        markingsChanged;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.foal != null;
    final foalId = widget.foal?.id ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (dismissKeyboardIfOpen(context)) return;
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
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isEditing ? 'FOAL: ${widget.foal?.foalName ?? "RECORD"}' : 'NEW FOAL REGISTRATION',
              style: AppTypography.sectionLabel,
            ),
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryGold,
            indicatorWeight: 3.0,
            labelColor: AppColors.primaryGold,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            tabs: const [
              Tab(
                icon: Icon(Icons.medical_information_outlined, size: 20),
                text: 'CLINICAL BIRTH LOG',
              ),
              Tab(
                icon: Icon(Icons.photo_camera_back_outlined, size: 20),
                text: 'VISUAL MARKINGS REGISTRY',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: CLINICAL BIRTH LOG & IDENTITY
                _buildClinicalBirthLogTab(isEditing: isEditing, foalId: foalId),

                // TAB 2: VISUAL MARKINGS REGISTRY (3-POINT MARKINGS)
                _buildVisualMarkingsRegistryTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: CLINICAL BIRTH LOG & IDENTITY
  // ---------------------------------------------------------------------------
  Widget _buildClinicalBirthLogTab({required bool isEditing, required String foalId}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: 16.0,
      ),
      child: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Foal Photo Header
            AppImagePicker(
              label: 'FOAL PROFILE PHOTO (CAMERA / GALLERY)',
              initialImageUrl: _photoUrl,
              onImageSelected: (url) => setState(() => _photoUrl = url),
            ),
            const SizedBox(height: 20.0),

            // 2. Core Identity Card
            const SectionDividerLabel(label: 'FOAL IDENTITY'),
            const SizedBox(height: 12.0),

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
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        ),
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGold, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),

            // Sex Selection (Filly / Colt)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sex / Gender *', style: AppTypography.inputLabel),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _sex = 'filly'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: _sex == 'filly' ? AppColors.primaryGold.withValues(alpha: 0.15) : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(
                              color: _sex == 'filly' ? AppColors.primaryGold : AppColors.surface,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.female,
                                color: _sex == 'filly' ? AppColors.primaryGold : AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'FILLY (FEMALE)',
                                    style: TextStyle(
                                      color: _sex == 'filly' ? AppColors.primaryGold : AppColors.textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _sex = 'colt'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: _sex == 'colt' ? AppColors.primaryGold.withValues(alpha: 0.15) : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(
                              color: _sex == 'colt' ? AppColors.primaryGold : AppColors.surface,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.male,
                                color: _sex == 'colt' ? AppColors.primaryGold : AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'COLT (MALE)',
                                    style: TextStyle(
                                      color: _sex == 'colt' ? AppColors.primaryGold : AppColors.textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
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
            const SizedBox(height: 20.0),

            // Parentage & Lineage Card
            const SectionDividerLabel(label: 'PARENTAGE & BREEDING LINEAGE'),
            const SizedBox(height: 12.0),

            // Select Dam (Mare)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mother / Dam (Mare) *', style: AppTypography.inputLabel),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await SelectOrAddAnimalModal.show(
                      context,
                      species: 'horse',
                      title: 'Select Dam (Mare)',
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedMare = picked;
                        if (_breedController.text.isEmpty && picked.breed != null) {
                          _breedController.text = picked.breed!;
                        }
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                        color: _selectedMare != null ? AppColors.primaryGold : AppColors.inputBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_selectedMare != null) ...[
                          AppThumbnailAvatar(
                            imagePath: _selectedMare!.photoUrl,
                            species: 'horse',
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedMare!.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (_selectedMare!.breed?.isNotEmpty == true)
                                  Text(
                                    _selectedMare!.breed!,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_outlined, color: AppColors.primaryGold, size: 18),
                        ] else ...[
                          const HorseshoeIcon(size: 20, color: AppColors.primaryGold),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Tap to select Dam (Mare)...',
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
            ),
            const SizedBox(height: 14.0),

            // Select Recipient Mare (Optional ET)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recipient Mare (If Embryo Transfer)', style: AppTypography.inputLabel),
                const SizedBox(height: 6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      children: [
                        if (_selectedRecipient != null) ...[
                          AppThumbnailAvatar(
                            imagePath: _selectedRecipient!.photoUrl,
                            species: 'horse',
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedRecipient!.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  'Surrogate Carrier',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () => setState(() => _selectedRecipient = null),
                          ),
                        ] else ...[
                          const Icon(Icons.add_circle_outline, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'None (Natural / Donor Mare Carried)',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),

            CustomTextField(
              label: 'Father / Sire (Stallion)',
              hintText: 'e.g. Thunderbolt Pegasus',
              controller: _stallionController,
            ),
            const SizedBox(height: 14.0),

            CustomTextField(
              label: 'Breed',
              hintText: 'e.g. Warmblood / Arabian Cross',
              controller: _breedController,
            ),
            const SizedBox(height: 24.0),

            // 3. Clinical & Registration Log Card
            const SectionDividerLabel(label: 'CLINICAL & GENETIC REGISTRY'),
            const SizedBox(height: 12.0),

            CustomTextField(
              label: 'IgG Antibody Test Result (mg/dL)',
              hintText: 'e.g. Pass (>800 mg/dL)',
              controller: _iggController,
              prefixIcon: Icons.biotech_outlined,
            ),
            const SizedBox(height: 14.0),

            CustomTextField(
              label: 'Foal Microchip Number (Optional)',
              hintText: 'e.g. 985141002938472',
              controller: _microchipController,
              prefixIcon: Icons.qr_code_scanner_rounded,
            ),
            const SizedBox(height: 14.0),

            CustomTextField(
              label: 'DNA Test / Profile Number (Optional)',
              hintText: 'e.g. DNA-FL-88219',
              controller: _dnaController,
              prefixIcon: Icons.fingerprint,
            ),
            const SizedBox(height: 14.0),

            CustomTextField(
              label: 'Stud Book Association / Reg # (Optional)',
              hintText: 'e.g. AHSA-2026-9921 / KWPN',
              controller: _studBookController,
              prefixIcon: Icons.verified_outlined,
            ),
            const SizedBox(height: 16.0),

            // Gelded (castrated) Toggle & Date
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(
                  color: _gelded ? AppColors.primaryGold : AppColors.inputBorder,
                  width: _gelded ? 1.2 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gelded (castrated)',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Indicate if this colt has been gelded',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _gelded,
                        activeColor: AppColors.primaryGold,
                        onChanged: (val) {
                          setState(() {
                            _gelded = val;
                            if (_gelded && _geldedDate == null) {
                              _geldedDate = DateTime.now();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_gelded) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _pickDate(isGelded: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.inputField,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Gelded Date: ${_formatDate(_geldedDate)}',
                                style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryGold),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // 4. Status Selector & Ownership
            const SectionDividerLabel(label: 'OFFSPRING STATUS & OWNERSHIP'),
            const SizedBox(height: 12.0),

            const Text('Foal Status', style: AppTypography.inputLabel),
            const SizedBox(height: 8.0),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Healthy / Retained', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  selected: _status == 'keep',
                  selectedColor: AppColors.primaryGold,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: _status == 'keep' ? AppColors.background : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _status = 'keep'),
                ),
                ChoiceChip(
                  label: const Text('Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  selected: _status == 'available',
                  selectedColor: AppColors.primaryGold,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: _status == 'available' ? AppColors.background : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _status = 'available'),
                ),
                ChoiceChip(
                  label: const Text('Reserved', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  selected: _status == 'reserved',
                  selectedColor: AppColors.primaryGold,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: _status == 'reserved' ? AppColors.background : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _status = 'reserved'),
                ),
                ChoiceChip(
                  label: const Text('Sold', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  selected: _status == 'sold',
                  selectedColor: AppColors.primaryGold,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: _status == 'sold' ? AppColors.background : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _status = 'sold'),
                ),
                ChoiceChip(
                  label: const Text('Transferred', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
            const SizedBox(height: 14.0),

            // Dynamic Buyer / New Owner Section (If Sold or Transferred)
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
                          _status == 'sold' ? 'BUYER RECORDS' : 'TRANSFER RECORDS',
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
                      label: 'Buyer / New Owner Name',
                      hintText: 'e.g. James & Linda Sterling',
                      controller: _buyerNameController,
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Buyer Phone Number',
                      hintText: 'e.g. +44 7700 900123',
                      controller: _buyerPhoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    if (_buyerPhoneController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => AppPhoneLauncher.makePhoneCall(context, _buyerPhoneController.text),
                          icon: const Icon(Icons.call, size: 14, color: AppColors.primaryGold),
                          label: const Text('Call Buyer', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
            ],

            CustomTextField(
              label: 'Breeder Observations & Notes (Optional)',
              hintText: 'Temperament, conformation notes, milk consumption...',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),

            // Action Shortcuts (Preventative Care & PDF Certificate)
            if (isEditing && foalId.isNotEmpty) ...[
              const SectionDividerLabel(label: 'DOCUMENTS & CARE'),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/preventative-care',
                          arguments: {
                            'ownerType': 'foal',
                            'ownerId': foalId,
                            'title': '${_nameController.text.isNotEmpty ? _nameController.text : "Foal"} - Preventative Care',
                          },
                        );
                      },
                      icon: const Icon(Icons.health_and_safety_outlined, size: 16, color: AppColors.primaryGold),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('VACCINES & CARE', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/certificate',
                          arguments: {
                            'animalName': _nameController.text.isNotEmpty ? _nameController.text : 'Foal',
                            'damName': _selectedMare?.name,
                            'sireName': _stallionController.text.isNotEmpty ? _stallionController.text : null,
                            'breed': _breedController.text.isNotEmpty ? _breedController.text : null,
                            'dateOfBirth': _dateOfBirth,
                            'sex': _sex,
                            'microchipNo': _microchipController.text.isNotEmpty ? _microchipController.text : null,
                            'dna': _dnaController.text.isNotEmpty ? _dnaController.text : null,
                            'studBook': _studBookController.text.isNotEmpty ? _studBookController.text : null,
                            'photoUrl': _photoUrl,
                          },
                        );
                      },
                      icon: const Icon(Icons.workspace_premium_outlined, size: 16, color: AppColors.primaryGold),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('PDF CERTIFICATE', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
            ],

            // Save CTA
            GradientCtaButton(
              text: _isSaving ? 'SAVING RECORD...' : (isEditing ? 'UPDATE FOAL RECORD' : 'SAVE NEW FOAL RECORD'),
              onPressed: _isSaving ? null : _handleSave,
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: VISUAL MARKINGS REGISTRY (3-POINT VISUAL PHOTO REGISTRY)
  // ---------------------------------------------------------------------------
  Widget _buildVisualMarkingsRegistryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: 16.0,
      ),
      child: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.camera_alt_outlined, color: AppColors.primaryGold, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3-POINT VISUAL MARKINGS REGISTRY',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Standard equine visual identification: Head View (star, strip, snip), Left Profile, and Right Profile.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // 1. Head View (Face & Markings)
            const SectionDividerLabel(label: '1. HEAD VIEW (FACE, STAR, STRIP, SNIP)'),
            const SizedBox(height: 10.0),
            AppImagePicker(
              label: 'UPLOAD HEAD VIEW PHOTO',
              initialImageUrl: _headViewImage,
              onImageSelected: (url) => setState(() => _headViewImage = url),
            ),
            const SizedBox(height: 20.0),

            // 2. Left Side View
            const SectionDividerLabel(label: '2. LEFT SIDE PROFILE (SOCKS & BODY)'),
            const SizedBox(height: 10.0),
            AppImagePicker(
              label: 'UPLOAD LEFT SIDE PHOTO',
              initialImageUrl: _leftSideImage,
              onImageSelected: (url) => setState(() => _leftSideImage = url),
            ),
            const SizedBox(height: 20.0),

            // 3. Right Side View
            const SectionDividerLabel(label: '3. RIGHT SIDE PROFILE (SOCKS & BODY)'),
            const SizedBox(height: 10.0),
            AppImagePicker(
              label: 'UPLOAD RIGHT SIDE PHOTO',
              initialImageUrl: _rightSideImage,
              onImageSelected: (url) => setState(() => _rightSideImage = url),
            ),
            const SizedBox(height: 20.0),

            // Facial & Body Markings Detailed Description
            const SectionDividerLabel(label: 'MARKINGS DESCRIPTION & NOTES'),
            const SizedBox(height: 10.0),
            CustomTextField(
              label: 'Facial & Leg Markings Description',
              hintText: 'e.g. Star on forehead, white sock on near-hind, blaze extending to left nostril...',
              controller: _headNotesController,
              maxLines: 4,
            ),
            const SizedBox(height: 24.0),

            // Save CTA
            GradientCtaButton(
              text: _isSaving ? 'SAVING MARKINGS...' : 'SAVE MARKINGS REGISTRY',
              onPressed: _isSaving ? null : _handleSave,
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
