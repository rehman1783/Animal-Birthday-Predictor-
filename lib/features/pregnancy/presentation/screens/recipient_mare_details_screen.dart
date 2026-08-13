import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../animals/domain/mare.dart';
import '../../../animals/presentation/providers/mare_provider.dart';
import '../providers/pregnancy_provider.dart';

class RecipientMareDetailsScreen extends ConsumerStatefulWidget {
  final String breedingRecordId;

  const RecipientMareDetailsScreen({super.key, required this.breedingRecordId});

  @override
  ConsumerState<RecipientMareDetailsScreen> createState() => _RecipientMareDetailsScreenState();
}

class _RecipientMareDetailsScreenState extends ConsumerState<RecipientMareDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameNoController = TextEditingController();
  final _colourController = TextEditingController();
  final _microchipController = TextEditingController();
  final _damController = TextEditingController();
  final _stallionController = TextEditingController();

  DateTime? _dob;
  DateTime _transferDate = DateTime.now();
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameNoController.dispose();
    _colourController.dispose();
    _microchipController.dispose();
    _damController.dispose();
    _stallionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDob ? (_dob ?? DateTime(2018)) : _transferDate,
      firstDate: DateTime(2000),
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
          _transferDate = picked;
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
        const SnackBar(content: Text('Please select Date of Birth for recipient mare')),
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
      final mareRepo = ref.read(mareRepositoryProvider);
      final pregRepo = ref.read(pregnancyRepositoryProvider);

      final recipId = DateTime.now().millisecondsSinceEpoch.toString();
      final recip = RecipientMare(
        id: recipId,
        accountId: '',
        breedingRecordId: widget.breedingRecordId,
        nameNo: _nameNoController.text.trim(),
        dateOfBirth: _dob,
        colour: _colourController.text.trim(),
        microchipNo: _microchipController.text.trim(),
        damOfEmbryo: _damController.text.trim(),
        stallionOfEmbryo: _stallionController.text.trim(),
        transferDate: _transferDate,
        photoUrl: _photoUrl,
        createdAt: DateTime.now(),
      );

      final savedRecip = await mareRepo.saveRecipientMare(recip);
      ref.invalidate(recipientMaresListProvider);

      // Create calculated pregnancy record for recipient mare
      await pregRepo.createCalculatedPregnancyRecord(
        carrierType: 'recipient_mare',
        carrierId: savedRecip.id,
        breedingRecordId: widget.breedingRecordId,
        method: 'natural', // Recipient transfer calculation rules apply
        baseDate: _transferDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipient mare & pregnancy record created!')),
        );

        Navigator.pushNamed(
          context,
          '/pregnancy-details',
          arguments: {'carrierType': 'recipient_mare', 'carrierId': savedRecip.id},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipient mare: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipId = DateTime.now().millisecondsSinceEpoch.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'RECIPIENT MARE DETAILS',
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
              // Photo Header with AppImagePicker (Camera + Gallery)
              AppImagePicker(
                currentImagePath: _photoUrl,
                label: 'Tap to Capture / Choose Recipient Mare Photo',
                height: 150,
                onImagePicked: (path) => setState(() => _photoUrl = path),
              ),

              const SizedBox(height: AppSpacing.spaceL),
              const SectionDividerLabel(label: 'RECIPIENT MARE IDENTITY', isLeftAligned: true),
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
                      controller: _nameNoController,
                      label: 'Recipient Mare Name / No. *',
                      prefixIcon: Icons.pets,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name or No. is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _colourController,
                      label: 'Colour *',
                      prefixIcon: Icons.palette,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Colour is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _microchipController,
                      label: 'Microchip No. *',
                      prefixIcon: Icons.qr_code,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Microchip number is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _damController,
                      label: 'DAM of Embryo *',
                      prefixIcon: Icons.female,
                      validator: (v) => v == null || v.trim().isEmpty ? 'DAM of embryo is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.spaceM),
                    CustomTextField(
                      controller: _stallionController,
                      label: 'Stallion of Embryo *',
                      prefixIcon: Icons.male,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Stallion of embryo is required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.spaceL),
              const SectionDividerLabel(label: 'DATES', isLeftAligned: true),
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
                    InkWell(
                      onTap: () => _pickDate(true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Date of Birth *', style: AppTypography.bodyMedium),
                          Text(_formatDate(_dob), style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryGold)),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.inputBorder, height: 24),
                    InkWell(
                      onTap: () => _pickDate(false),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Embryo Transfer Date *', style: AppTypography.bodyMedium),
                          Text(_formatDate(_transferDate), style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
                        ],
                      ),
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
                    arguments: {'ownerType': 'recipient_mare', 'ownerId': recipId},
                  );
                },
                icon: const Icon(Icons.palette, color: AppColors.primaryGold),
                label: Text(
                  'RECORD RECIPIENT MARKINGS',
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
                text: 'SAVE RECIPIENT MARE & CALCULATE PREGNANCY',
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
