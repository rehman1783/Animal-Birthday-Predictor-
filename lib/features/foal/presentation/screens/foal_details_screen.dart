import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/presentation/providers/mare_provider.dart';
import '../../domain/foal_record.dart';
import '../providers/foal_provider.dart';

class FoalDetailsScreen extends ConsumerStatefulWidget {
  final FoalRecord? foal;

  const FoalDetailsScreen({super.key, this.foal});

  @override
  ConsumerState<FoalDetailsScreen> createState() => _FoalDetailsScreenState();
}

class _FoalDetailsScreenState extends ConsumerState<FoalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foalNameController;
  late TextEditingController _stallionController;
  late TextEditingController _breedController;
  late TextEditingController _iggController;
  late TextEditingController _microchipController;
  late TextEditingController _dnaController;
  late TextEditingController _studBookController;
  late TextEditingController _notesController;

  String? _selectedMareId;
  String? _selectedRecipientMareId;
  String _sex = 'filly'; // 'filly', 'colt'
  String _status = 'keep'; // 'sold', 'keep', 'transferred'
  DateTime? _dob;
  bool _gelded = false;
  DateTime? _geldedDate;
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _foalNameController = TextEditingController(text: widget.foal?.foalName ?? '');
    _stallionController = TextEditingController(text: widget.foal?.stallion ?? '');
    _breedController = TextEditingController(text: widget.foal?.breed ?? '');
    _iggController = TextEditingController(text: widget.foal?.iggValue ?? '');
    _microchipController = TextEditingController(text: widget.foal?.foalMicrochipNo ?? '');
    _dnaController = TextEditingController(text: widget.foal?.dna ?? '');
    _studBookController = TextEditingController(text: widget.foal?.studBookAssociation ?? '');
    _notesController = TextEditingController(text: widget.foal?.notes ?? '');

    _selectedMareId = widget.foal?.mareId;
    _selectedRecipientMareId = widget.foal?.recipientMareId;
    _sex = widget.foal?.sex ?? 'filly';
    _status = widget.foal?.status ?? 'keep';
    _dob = widget.foal?.dateOfBirth;
    _gelded = widget.foal?.gelded ?? false;
    _geldedDate = widget.foal?.geldedDate;
    _photoUrl = widget.foal?.photoUrl;
  }

  @override
  void dispose() {
    _foalNameController.dispose();
    _stallionController.dispose();
    _breedController.dispose();
    _iggController.dispose();
    _microchipController.dispose();
    _dnaController.dispose();
    _studBookController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDob ? (_dob ?? DateTime.now()) : (_geldedDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
        if (isDob) {
          _dob = picked;
        } else {
          _geldedDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _handleSave() async {
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date of Birth for the foal')),
      );
      return;
    }

    if (_selectedMareId == null || _selectedMareId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Dam Mare')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields correctly.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(foalRepositoryProvider);
      final foalId = widget.foal?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final record = FoalRecord(
        id: foalId,
        mareId: _selectedMareId!,
        recipientMareId: _selectedRecipientMareId,
        foalName: _foalNameController.text.trim(),
        dateOfBirth: _dob,
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
        createdAt: widget.foal?.createdAt ?? DateTime.now(),
      );

      await repo.saveFoal(record);
      ref.invalidate(foalsListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foal details saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving foal details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maresAsync = ref.watch(maresListProvider);
    final recipientMaresAsync = ref.watch(recipientMaresListProvider);
    final isEdit = widget.foal != null;
    final foalId = widget.foal?.id ?? 'new';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'EDIT FOAL DETAILS' : 'NEW FOAL RECORD',
          style: AppTypography.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.spaceL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Header with AppImagePicker
              AppImagePicker(
                currentImagePath: _photoUrl,
                label: 'Tap to Capture / Choose Foal Photo',
                height: 160,
                onImagePicked: (path) => setState(() => _photoUrl = path),
              ),

              const SizedBox(height: AppSpacing.spaceL),
              const SectionDividerLabel(label: 'FOAL IDENTITY', isLeftAligned: true),
              const SizedBox(height: AppSpacing.spaceM),

              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _foalNameController,
                      label: 'Foal Name *',
                      prefixIcon: Icons.child_care,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Foal name is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    InkWell(
                      onTap: () => _pickDate(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.inputField,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Date of Birth *', style: AppTypography.bodyMedium),
                            Text(_formatDate(_dob), style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _breedController,
                      label: 'Breed *',
                      prefixIcon: Icons.category,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Breed is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sex *', style: AppTypography.bodyMedium),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Filly'),
                              selected: _sex == 'filly',
                              selectedColor: AppColors.primaryGold,
                              onSelected: (v) {
                                if (v) setState(() => _sex = 'filly');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Colt'),
                              selected: _sex == 'colt',
                              selectedColor: AppColors.primaryGold,
                              onSelected: (v) {
                                if (v) setState(() => _sex = 'colt');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spaceL),
              const SectionDividerLabel(label: 'LINKED PARENTS', isLeftAligned: true),
              const SizedBox(height: AppSpacing.spaceM),

              // Mare & Recipient Mare Pickers
              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dam Mare *', style: AppTypography.inputLabel),
                    const SizedBox(height: 6),
                    maresAsync.when(
                      loading: () => const LinearProgressIndicator(color: AppColors.primaryGold),
                      error: (e, s) => Text('Error loading mares: $e'),
                      data: (maresList) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedMareId,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputField,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusM)),
                          ),
                          items: maresList.map((m) {
                            return DropdownMenuItem<String>(
                              value: m.id,
                              child: Text('${m.name} (${m.microchipNo ?? "No Microchip"})', style: AppTypography.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedMareId = val),
                          validator: (v) => v == null || v.isEmpty ? 'Please select Dam Mare' : null,
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.spaceM),

                    Text('Recipient Mare (If Applicable)', style: AppTypography.inputLabel),
                    const SizedBox(height: 6),
                    recipientMaresAsync.when(
                      loading: () => const LinearProgressIndicator(color: AppColors.primaryGold),
                      error: (e, s) => Text('Error loading recipient mares: $e'),
                      data: (recipList) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedRecipientMareId,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputField,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusM)),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('None (Natural Mare Carried)', style: TextStyle(color: AppColors.textMuted)),
                            ),
                            ...recipList.map((r) {
                              return DropdownMenuItem<String>(
                                value: r.id,
                                child: Text('${r.nameNo} (${r.microchipNo ?? "No Microchip"})', style: AppTypography.bodyMedium),
                              );
                            }),
                          ],
                          onChanged: (val) => setState(() => _selectedRecipientMareId = val),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _stallionController,
                      label: 'Stallion (Sire) *',
                      prefixIcon: Icons.male,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Stallion (Sire) is required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spaceL),
              const SectionDividerLabel(label: 'HEALTH & REGISTRATION', isLeftAligned: true),
              const SizedBox(height: AppSpacing.spaceM),

              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _iggController,
                      label: 'IGG Value *',
                      prefixIcon: Icons.health_and_safety,
                      validator: (v) => v == null || v.trim().isEmpty ? 'IGG Value is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _microchipController,
                      label: 'Foal Microchip No. *',
                      prefixIcon: Icons.qr_code,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Microchip number is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _dnaController,
                      label: 'DNA Registration *',
                      prefixIcon: Icons.fingerprint,
                      validator: (v) => v == null || v.trim().isEmpty ? 'DNA registration is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Gelded', style: AppTypography.bodyMedium),
                        Switch(
                          value: _gelded,
                          activeThumbColor: AppColors.primaryGold,
                          onChanged: (v) => setState(() => _gelded = v),
                        ),
                      ],
                    ),
                    if (_gelded) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickDate(false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.inputField,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Gelded Date', style: AppTypography.bodySmall),
                              Text(_formatDate(_geldedDate), style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _studBookController,
                      label: 'Stud Book / Breeding Association *',
                      prefixIcon: Icons.menu_book,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Stud Book / Association is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status *', style: AppTypography.bodyMedium),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Keep'),
                              selected: _status == 'keep',
                              selectedColor: AppColors.primaryGold,
                              onSelected: (v) {
                                if (v) setState(() => _status = 'keep');
                              },
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text('Sold'),
                              selected: _status == 'sold',
                              selectedColor: AppColors.primaryGold,
                              onSelected: (v) {
                                if (v) setState(() => _status = 'sold');
                              },
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text('Transferred'),
                              selected: _status == 'transferred',
                              selectedColor: AppColors.primaryGold,
                              onSelected: (v) {
                                if (v) setState(() => _status = 'transferred');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _notesController,
                      label: 'Notes *',
                      prefixIcon: Icons.notes,
                      maxLines: 2,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Notes are required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spaceL),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/markings',
                    arguments: {'ownerType': 'foal', 'ownerId': foalId},
                  );
                },
                icon: const Icon(Icons.palette, color: AppColors.primaryGold),
                label: Text(
                  'RECORD FOAL MARKINGS',
                  style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGold),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.spaceXL),

              GradientCtaButton(
                text: isEdit ? 'UPDATE FOAL DETAILS' : 'SAVE FOAL DETAILS',
                onPressed: _handleSave,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
