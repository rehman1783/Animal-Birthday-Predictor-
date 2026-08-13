import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/mare.dart';
import '../providers/mare_provider.dart';

class MareDetailsScreen extends ConsumerStatefulWidget {
  final Mare? mare;

  const MareDetailsScreen({super.key, this.mare});

  @override
  ConsumerState<MareDetailsScreen> createState() => _MareDetailsScreenState();
}

class _MareDetailsScreenState extends ConsumerState<MareDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _brandController;
  late TextEditingController _dnaController;
  late TextEditingController _microchipController;
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerPhoneController;
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mare?.name ?? '');
    _breedController = TextEditingController(text: widget.mare?.breed ?? '');
    _brandController = TextEditingController(text: widget.mare?.brand ?? '');
    _dnaController = TextEditingController(text: widget.mare?.dna ?? '');
    _microchipController = TextEditingController(text: widget.mare?.microchipNo ?? '');
    _ownerNameController = TextEditingController(text: widget.mare?.ownerClientName ?? '');
    _ownerPhoneController = TextEditingController(text: widget.mare?.ownerClientPhone ?? '');
    _photoUrl = widget.mare?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _brandController.dispose();
    _dnaController.dispose();
    _microchipController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields correctly.')),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(mareRepositoryProvider);
      final mareId = widget.mare?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final updatedMare = Mare(
        id: mareId,
        accountId: widget.mare?.accountId ?? '',
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        brand: _brandController.text.trim(),
        dna: _dnaController.text.trim(),
        microchipNo: _microchipController.text.trim(),
        ownerClientName: _ownerNameController.text.trim(),
        ownerClientPhone: _ownerPhoneController.text.trim(),
        photoUrl: _photoUrl,
        createdAt: widget.mare?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveMare(updatedMare);
      ref.invalidate(maresListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mare details saved successfully!')),
        );
        Navigator.pushNamed(context, '/breeding-details', arguments: saved.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mare: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mare != null;
    final mareId = widget.mare?.id ?? 'new';

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
          isEdit ? 'MARE DETAILS' : 'ADD DONOR MARE',
          style: AppTypography.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.spaceL),
        child: ResponsiveBody(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo Header with AppImagePicker (Gallery + Camera)
                AppImagePicker(
                  currentImagePath: _photoUrl,
                  label: 'Tap to Capture / Choose Mare Photo',
                  height: 160,
                  onImagePicked: (path) => setState(() => _photoUrl = path),
                ),
                const SizedBox(height: AppSpacing.spaceL),

                const SectionDividerLabel(label: 'MARE IDENTITY', isLeftAligned: true),
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
                        controller: _nameController,
                        label: 'Mare Name *',
                        prefixIcon: Icons.pets,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Mare name is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.spaceM),
                      CustomTextField(
                        controller: _breedController,
                        label: 'Breed *',
                        prefixIcon: Icons.category,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Breed is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.spaceM),
                      CustomTextField(
                        controller: _brandController,
                        label: 'Brand *',
                        prefixIcon: Icons.branding_watermark,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Brand is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.spaceM),
                      CustomTextField(
                        controller: _dnaController,
                        label: 'DNA Registration *',
                        prefixIcon: Icons.fingerprint,
                        validator: (v) => v == null || v.trim().isEmpty ? 'DNA registration is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.spaceM),
                      CustomTextField(
                        controller: _microchipController,
                        label: 'Microchip No. *',
                        prefixIcon: Icons.qr_code,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Microchip number is required' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceL),
                const SectionDividerLabel(label: 'OWNER / CLIENT DETAILS', isLeftAligned: true),
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
                        controller: _ownerNameController,
                        label: 'Owner / Client Name *',
                        prefixIcon: Icons.person,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Owner name is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.spaceM),
                      CustomTextField(
                        controller: _ownerPhoneController,
                        label: 'Owner Phone Number *',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Owner phone number is required' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceL),

                // Action button to Markings
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/markings',
                      arguments: {'ownerType': 'mare', 'ownerId': mareId},
                    );
                  },
                  icon: const Icon(Icons.palette, color: AppColors.primaryGold),
                  label: Text(
                    'RECORD MARE MARKINGS',
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
                  text: isEdit ? 'UPDATE MARE & PROCEED' : 'SAVE MARE & PROCEED TO BREEDING',
                  onPressed: _handleSave,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
