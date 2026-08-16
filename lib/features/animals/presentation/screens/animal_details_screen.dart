import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/animal.dart';
import '../providers/animal_provider.dart';

class AnimalDetailsScreen extends ConsumerStatefulWidget {
  final Animal? animal;
  final String species;

  const AnimalDetailsScreen({
    super.key,
    this.animal,
    this.species = 'horse',
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

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _nameController = TextEditingController(text: a?.name ?? '');
    _breedController = TextEditingController(text: a?.breed ?? '');
    _colourController = TextEditingController(text: a?.colour ?? '');
    _brandController = TextEditingController(text: a?.brand ?? '');
    _dnaController = TextEditingController(text: a?.dna ?? '');
    _microchipController = TextEditingController(text: a?.microchipNo ?? '');
    _ownerNameController = TextEditingController(text: a?.ownerClientName ?? '');
    _ownerPhoneController = TextEditingController(text: a?.ownerClientPhone ?? '');
    _dateOfBirth = a?.dateOfBirth;
    _photoUrl = a?.photoUrl;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields (* Name is required).')),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(animalRepositoryProvider);
      final animalId = widget.animal?.id.isNotEmpty == true
          ? widget.animal!.id
          : DateTime.now().millisecondsSinceEpoch.toString();

      final updatedAnimal = Animal(
        id: animalId,
        accountId: widget.animal?.accountId ?? '',
        species: widget.animal?.species ?? widget.species,
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        colour: _colourController.text.trim(),
        dateOfBirth: _dateOfBirth,
        brand: _brandController.text.trim(),
        dna: _dnaController.text.trim(),
        microchipNo: _microchipController.text.trim(),
        ownerClientName: _ownerNameController.text.trim(),
        ownerClientPhone: _ownerPhoneController.text.trim(),
        photoUrl: _photoUrl,
        createdAt: widget.animal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveAnimal(updatedAnimal);
      ref.invalidate(animalsListProvider(updatedAnimal.species));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${saved.name} details saved successfully!')),
        );
        Navigator.pop(context, saved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save animal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.animal != null;
    final animalId = widget.animal?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          isEditing ? 'EDIT ${widget.animal!.name.toUpperCase()}' : 'ANIMAL DETAILS',
          style: AppTypography.sectionLabel,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding,
            vertical: 16.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Photo Capture Header
                AppImagePicker(
                  label: '${widget.species.toUpperCase()} PHOTO',
                  initialImageUrl: _photoUrl,
                  onImageSelected: (url) => setState(() => _photoUrl = url),
                ),
                const SizedBox(height: 24.0),

                // 2. Core Identity Form
                const SectionDividerLabel(label: 'CORE IDENTITY'),
                const SizedBox(height: 16.0),

                CustomTextField(
                  label: 'Animal Name *',
                  hintText: 'e.g. Starlight Eclipse',
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Animal Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 14.0),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Breed',
                        hintText: 'e.g. Thoroughbred',
                        controller: _breedController,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: CustomTextField(
                        label: 'Colour',
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
                    const Text('Date of Birth', style: AppTypography.inputLabel),
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
                            Text(
                              _formatDate(_dateOfBirth),
                              style: TextStyle(
                                color: _dateOfBirth != null ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
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
                        label: 'Microchip No.',
                        hintText: '15-digit ISO microchip',
                        controller: _microchipController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: CustomTextField(
                        label: 'DNA Profile',
                        hintText: 'e.g. DNA-94821',
                        controller: _dnaController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),

                CustomTextField(
                  label: 'Brand / Freeze Mark',
                  hintText: 'e.g. Left Shoulder: Cross & Crescent',
                  controller: _brandController,
                ),
                const SizedBox(height: 24.0),

                // 3. Owner & Client Details
                const SectionDividerLabel(label: 'OWNER & CLIENT MANAGEMENT'),
                const SizedBox(height: 16.0),

                CustomTextField(
                  label: 'Owner / Client Name',
                  hintText: 'e.g. Eleanor Vance',
                  controller: _ownerNameController,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 14.0),

                CustomTextField(
                  label: 'Owner / Client Phone',
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
                          label: Text(
                            'MARKINGS',
                            style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/preventative-care',
                              arguments: {'ownerType': 'animal', 'ownerId': animalId, 'title': widget.animal!.name},
                            );
                          },
                          icon: const Icon(Icons.healing_outlined, color: AppColors.primaryGold, size: 18),
                          label: Text(
                            'HEALTH CARE',
                            style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
