import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_uuid.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_unsaved_changes_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/species_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/animal.dart';
import '../providers/animal_provider.dart';

class AnimalDetailsScreen extends ConsumerStatefulWidget {
  final Animal? animal;
  final String? animalId;
  final String species;
  final String? initialSex;

  const AnimalDetailsScreen({
    super.key,
    this.animal,
    this.animalId,
    this.species = 'horse',
    this.initialSex,
  });

  @override
  ConsumerState<AnimalDetailsScreen> createState() => _AnimalDetailsScreenState();
}

class _AnimalDetailsScreenState extends ConsumerState<AnimalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _colourController;
  late TextEditingController _brandController;
  late TextEditingController _dnaController;
  late TextEditingController _microchipController;
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerPhoneController;
  DateTime? _dateOfBirth;
  String? _photoUrl;
  bool _isSaving = false;
  bool _isLoading = false;
  Object? _loadError;
  Animal? _loadedAnimal;
  late String _currentSpecies;
  late String _selectedSex;

  @override
  void initState() {
    super.initState();
    _loadedAnimal = widget.animal;
    _currentSpecies = Animal.normalizeSpecies(_loadedAnimal?.species ?? widget.species);
    _selectedSex = _loadedAnimal?.sex ?? widget.initialSex ?? (_currentSpecies == 'horse' ? 'mare' : 'female');
    _nameController = TextEditingController(text: _loadedAnimal?.name ?? '');
    _breedController = TextEditingController(text: _loadedAnimal?.breed ?? '');
    _colourController = TextEditingController(text: _loadedAnimal?.colour ?? '');
    _brandController = TextEditingController(text: _loadedAnimal?.brand ?? '');
    _dnaController = TextEditingController(text: _loadedAnimal?.dna ?? '');
    _microchipController = TextEditingController(text: _loadedAnimal?.microchipNo ?? '');
    _ownerNameController = TextEditingController(text: _loadedAnimal?.ownerClientName ?? '');
    _ownerPhoneController = TextEditingController(text: _loadedAnimal?.ownerClientPhone ?? '');
    _dateOfBirth = _loadedAnimal?.dateOfBirth;
    _photoUrl = _loadedAnimal?.photoUrl;

    if (_loadedAnimal == null && widget.animalId != null && widget.animalId!.isNotEmpty) {
      _loadAnimalById(widget.animalId!);
    }
  }

  Future<void> _loadAnimalById(String id) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final repo = ref.read(animalRepositoryProvider);
      final a = await repo.getAnimalById(id);
      if (a != null && mounted) {
        setState(() {
          _loadedAnimal = a;
          _currentSpecies = Animal.normalizeSpecies(a.species);
          _selectedSex = a.sex ?? (_currentSpecies == 'horse' ? 'mare' : 'female');
          _nameController.text = a.name;
          _breedController.text = a.breed ?? '';
          _colourController.text = a.colour ?? '';
          _brandController.text = a.brand ?? '';
          _dnaController.text = a.dna ?? '';
          _microchipController.text = a.microchipNo ?? '';
          _ownerNameController.text = a.ownerClientName ?? '';
          _ownerPhoneController.text = a.ownerClientPhone ?? '';
          _dateOfBirth = a.dateOfBirth;
          _photoUrl = a.photoUrl;
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
    _nameController.dispose();
    _breedController.dispose();
    _colourController.dispose();
    _brandController.dispose();
    _dnaController.dispose();
    _microchipController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
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
      setState(() => _dateOfBirth = picked);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date of Birth';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Required Field',
        error: 'Please enter the registered name before saving.',
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(animalRepositoryProvider);
      final currentAnimal = _loadedAnimal ?? widget.animal;
      final animalId = currentAnimal?.id.isNotEmpty == true && AppUuid.isValid(currentAnimal!.id)
          ? currentAnimal.id
          : AppUuid.generate();

      final updatedAnimal = Animal(
        id: animalId,
        accountId: currentAnimal?.accountId ?? '',
        species: _currentSpecies,
        name: _nameController.text.trim(),
        sex: _selectedSex,
        breed: _breedController.text.trim(),
        colour: _colourController.text.trim(),
        dateOfBirth: _dateOfBirth,
        brand: _brandController.text.trim(),
        dna: _dnaController.text.trim(),
        microchipNo: _microchipController.text.trim(),
        ownerClientName: _ownerNameController.text.trim(),
        ownerClientPhone: _ownerPhoneController.text.trim(),
        photoUrl: _photoUrl,
        createdAt: currentAnimal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveAnimal(updatedAnimal);

      // Invalidate state to immediately reload everywhere in the app
      ref.invalidate(animalsListProvider(_currentSpecies));
      ref.invalidate(animalsListProvider('horse'));
      ref.invalidate(animalsListProvider('dog'));
      ref.invalidate(animalsListProvider('cat'));
      ref.invalidate(animalsListProvider('other'));
      ref.invalidate(animalsListProvider(null));
      ref.invalidate(animalByIdProvider(saved.id));

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Animal Saved',
          message: '${saved.name} details saved to registry successfully!',
        );
        Navigator.pop(context, saved);
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Animal Save Failed',
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDeleteAnimal() async {
    final currentAnimal = _loadedAnimal ?? widget.animal;
    if (currentAnimal == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Animal', style: AppTypography.displayHeadline.copyWith(fontSize: 18)),
        content: Text(
          'Are you sure you want to delete ${currentAnimal.name}? This will remove this animal and all associated breeding, pregnancy, and markings records from your registry.',
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
      final repo = ref.read(animalRepositoryProvider);
      await repo.deleteAnimal(currentAnimal.id);
      ref.invalidate(animalsListProvider(_currentSpecies));
      ref.invalidate(animalsListProvider(currentAnimal.species));
      ref.invalidate(animalsListProvider('horse'));
      ref.invalidate(animalsListProvider('dog'));
      ref.invalidate(animalsListProvider('cat'));
      ref.invalidate(animalsListProvider('other'));
      ref.invalidate(animalsListProvider(null));
      ref.invalidate(animalByIdProvider(currentAnimal.id));

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Animal Deleted',
          message: '${currentAnimal.name} deleted from registry.',
        );
        Navigator.pop(context, true);
      }
    }
  }

  bool get _hasUnsavedChanges {
    final a = _loadedAnimal ?? widget.animal;
    if (a == null) {
      return _nameController.text.trim().isNotEmpty ||
          _breedController.text.trim().isNotEmpty ||
          _colourController.text.trim().isNotEmpty ||
          _brandController.text.trim().isNotEmpty ||
          _dnaController.text.trim().isNotEmpty ||
          _microchipController.text.trim().isNotEmpty ||
          _ownerNameController.text.trim().isNotEmpty ||
          _ownerPhoneController.text.trim().isNotEmpty ||
          _dateOfBirth != null ||
          _photoUrl != null;
    }

    final initialSex = a.sex?.trim().toLowerCase() ?? (_currentSpecies == 'horse' ? 'mare' : 'female');
    final currentSex = _selectedSex.trim().toLowerCase();
    final isDobChanged = (_dateOfBirth == null && a.dateOfBirth != null) ||
        (_dateOfBirth != null && a.dateOfBirth == null) ||
        (_dateOfBirth != null &&
            a.dateOfBirth != null &&
            (_dateOfBirth!.year != a.dateOfBirth!.year ||
                _dateOfBirth!.month != a.dateOfBirth!.month ||
                _dateOfBirth!.day != a.dateOfBirth!.day));

    return _nameController.text.trim() != a.name.trim() ||
        _breedController.text.trim() != (a.breed?.trim() ?? '') ||
        _colourController.text.trim() != (a.colour?.trim() ?? '') ||
        _brandController.text.trim() != (a.brand?.trim() ?? '') ||
        _dnaController.text.trim() != (a.dna?.trim() ?? '') ||
        _microchipController.text.trim() != (a.microchipNo?.trim() ?? '') ||
        _ownerNameController.text.trim() != (a.ownerClientName?.trim() ?? '') ||
        _ownerPhoneController.text.trim() != (a.ownerClientPhone?.trim() ?? '') ||
        isDobChanged ||
        _photoUrl != a.photoUrl ||
        currentSex != initialSex;
  }

  @override
  Widget build(BuildContext context) {
    final currentAnimal = _loadedAnimal ?? widget.animal;
    final isEditing = currentAnimal != null && currentAnimal.name.isNotEmpty;
    final animalId = currentAnimal?.id ?? '';

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
            isEditing ? 'EDIT ${currentAnimal.name.toUpperCase()}' : 'ANIMAL DETAILS',
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
                tooltip: 'Delete Animal',
                onPressed: _confirmDeleteAnimal,
              ),
          ],
        ),
      body: SafeArea(
        child: _isLoading
            ? const AppLoadingView(message: 'Loading animal details...')
            : _loadError != null
                ? AppErrorView(
                    error: _loadError,
                    onRetry: () {
                      if (widget.animalId != null) {
                        _loadAnimalById(widget.animalId!);
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
                  // 1. Photo Capture Header
                  AppImagePicker(
                    label: '${_currentSpecies.toUpperCase()} PHOTO (Optional)',
                    initialImageUrl: _photoUrl,
                    onImageSelected: (url) => setState(() => _photoUrl = url),
                  ),
                  const SizedBox(height: 24.0),

                  // 2. Core Identity Form
                  const SectionDividerLabel(label: 'CORE IDENTITY'),
                  const SizedBox(height: 16.0),

                  // Species Category Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Species Category *', style: AppTypography.inputLabel),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final sp in const [
                            ('horse', 'Horse / Equine', Icons.pets_rounded),
                            ('dog', 'Dog / Canine', Icons.pets),
                            ('cat', 'Cat / Feline', Icons.catching_pokemon),
                            ('other', 'Other', Icons.category_rounded),
                          ])
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _currentSpecies = sp.$1;
                                      if (_currentSpecies == 'horse') {
                                        if (_selectedSex != 'mare' && _selectedSex != 'stallion' && _selectedSex != 'gelding') {
                                          _selectedSex = 'mare';
                                        }
                                      } else {
                                        if (_selectedSex != 'female' && _selectedSex != 'male') {
                                          _selectedSex = (_selectedSex == 'stallion') ? 'male' : 'female';
                                        }
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _currentSpecies == sp.$1
                                          ? AppColors.primaryGold.withValues(alpha: 0.15)
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _currentSpecies == sp.$1 ? AppColors.primaryGold : AppColors.surface,
                                        width: _currentSpecies == sp.$1 ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SpeciesIcon(
                                          species: sp.$1,
                                          size: 18,
                                          color: _currentSpecies == sp.$1 ? AppColors.primaryGold : AppColors.textSecondary,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          sp.$1.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _currentSpecies == sp.$1 ? AppColors.primaryGold : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Horse Classification / Gender Selector
                  if (_currentSpecies == 'horse') ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Horse Classification / Sex *', style: AppTypography.inputLabel),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final hOpt in const [
                              ('mare', 'MARE', 'Female / Dam'),
                              ('stallion', 'STALLION', 'Male / Stud'),
                              ('gelding', 'GELDING', 'Castrated'),
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedSex = hOpt.$1),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: _selectedSex == hOpt.$1
                                            ? AppColors.primaryGold.withValues(alpha: 0.18)
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _selectedSex == hOpt.$1 ? AppColors.primaryGold : AppColors.surface,
                                          width: _selectedSex == hOpt.$1 ? 1.8 : 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          HorseshoeIcon(
                                            size: 18,
                                            color: _selectedSex == hOpt.$1 ? AppColors.primaryGold : AppColors.textSecondary,
                                          ),
                                          const SizedBox(height: 5),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              hOpt.$2,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedSex == hOpt.$1 ? AppColors.primaryGold : AppColors.textPrimary,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              hOpt.$3,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: _selectedSex == hOpt.$1 ? AppColors.primaryGold : AppColors.textMuted,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sex / Gender *', style: AppTypography.inputLabel),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final gOpt in [
                              (
                                'female',
                                _currentSpecies == 'dog' ? 'DAM / BITCH' : 'FEMALE',
                                _currentSpecies == 'dog' ? Icons.pets : Icons.female,
                              ),
                              (
                                'male',
                                _currentSpecies == 'dog' ? 'STUD / DOG' : 'MALE',
                                _currentSpecies == 'dog' ? Icons.pets : Icons.male,
                              ),
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedSex = gOpt.$1),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: _selectedSex == gOpt.$1
                                            ? AppColors.primaryGold.withValues(alpha: 0.18)
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _selectedSex == gOpt.$1 ? AppColors.primaryGold : AppColors.surface,
                                          width: _selectedSex == gOpt.$1 ? 1.8 : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            gOpt.$3,
                                            size: 18,
                                            color: _selectedSex == gOpt.$1 ? AppColors.primaryGold : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              gOpt.$2,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedSex == gOpt.$1 ? AppColors.primaryGold : AppColors.textPrimary,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ],

                  CustomTextField(
                    label: 'Registered Name *',
                    hintText: 'e.g. Silver Oak, Starlight Eclipse...',
                    controller: _nameController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Registered Name is required';
                      return null;
                    },
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
                          label: 'Colour (Optional)',
                          hintText: 'e.g. Bay, Chestnut',
                          controller: _colourController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Date of Birth Selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date of Birth (Optional)', style: AppTypography.inputLabel),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDateOfBirth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.inputField,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(
                              color: _dateOfBirth != null ? AppColors.primaryGold : AppColors.surface,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  _formatDate(_dateOfBirth),
                                  style: TextStyle(
                                    color: _dateOfBirth != null ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryGold),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Microchip No. (Optional)',
                          hintText: '15-digit ISO microchip',
                          controller: _microchipController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: CustomTextField(
                          label: 'DNA Profile (Optional)',
                          hintText: 'e.g. DNA-94821',
                          controller: _dnaController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'Brand / Freeze Mark (Optional)',
                    hintText: 'e.g. Left Shoulder: Cross & Crescent',
                    controller: _brandController,
                  ),
                  const SizedBox(height: 24.0),

                  // 3. Owner & Client Details
                  const SectionDividerLabel(label: 'OWNER & CLIENT MANAGEMENT'),
                  const SizedBox(height: 16.0),

                  CustomTextField(
                    label: 'Owner / Client Name (Optional)',
                    hintText: 'e.g. Eleanor Vance',
                    controller: _ownerNameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14.0),

                  CustomTextField(
                    label: 'Owner / Client Phone (Optional)',
                    hintText: 'e.g. +1 555 019 2831',
                    controller: _ownerPhoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 28.0),

                  // 4. Action Shortcuts (Physical Markings & Preventative Care)
                  if (isEditing && animalId.isNotEmpty) ...[
                    const SectionDividerLabel(label: 'ANIMAL HEALTH & MARKINGS'),
                    const SizedBox(height: 16.0),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/markings',
                                arguments: {'ownerType': 'animal', 'ownerId': animalId},
                              );
                            },
                            icon: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGold, size: 18),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'MARKINGS',
                                style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/preventative-care',
                                arguments: {'ownerType': 'animal', 'ownerId': animalId, 'title': currentAnimal.name},
                              );
                            },
                            icon: const Icon(Icons.healing_outlined, color: AppColors.primaryGold, size: 18),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'HEALTH CARE',
                                style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28.0),
                  ],

                  // 5. Submit CTA
                  GradientCtaButton(
                    text: _isSaving ? 'SAVING DETAILS...' : (isEditing ? 'UPDATE ANIMAL DETAILS' : 'SAVE TO REGISTRY'),
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
