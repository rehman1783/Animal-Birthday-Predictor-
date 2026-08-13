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
import '../../domain/markings.dart';
import '../providers/mare_provider.dart';

class MarkingsScreen extends ConsumerStatefulWidget {
  final String ownerType; // 'mare', 'recipient_mare', 'foal'
  final String ownerId;

  const MarkingsScreen({
    super.key,
    required this.ownerType,
    required this.ownerId,
  });

  @override
  ConsumerState<MarkingsScreen> createState() => _MarkingsScreenState();
}

class _MarkingsScreenState extends ConsumerState<MarkingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _headNotesController;
  String? _leftSideImage;
  String? _rightSideImage;
  String? _headViewImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _headNotesController = TextEditingController();
    _loadExistingMarkings();
  }

  Future<void> _loadExistingMarkings() async {
    final repo = ref.read(mareRepositoryProvider);
    final existing = await repo.getMarkings(widget.ownerType, widget.ownerId);
    if (existing != null && mounted) {
      setState(() {
        _leftSideImage = existing.leftSideImageUrl;
        _rightSideImage = existing.rightSideImageUrl;
        _headViewImage = existing.headViewImageUrl;
        _headNotesController.text = existing.headViewNotes ?? '';
      });
    }
  }

  @override
  void dispose() {
    _headNotesController.dispose();
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
      final markings = Markings(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerType: widget.ownerType,
        ownerId: widget.ownerId,
        leftSideImageUrl: _leftSideImage,
        rightSideImageUrl: _rightSideImage,
        headViewImageUrl: _headViewImage,
        headViewNotes: _headNotesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveMarkings(markings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Markings saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving markings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleType = widget.ownerType.replaceAll('_', ' ').toUpperCase();

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
          '$titleType MARKINGS',
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
                // Static Disclaimer Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The diagrams provided are intended as a general guide only. Markings and brands should be recorded as accurately as possible, however always refer to official breed registration when in doubt.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceL),
                const SectionDividerLabel(label: 'PHOTO & BRAND CAPTURE', isLeftAligned: true),
                const SizedBox(height: AppSpacing.spaceM),

                Text('Left Side Markings', style: AppTypography.inputLabel),
                const SizedBox(height: 8),
                AppImagePicker(
                  currentImagePath: _leftSideImage,
                  label: 'Left Side Photo',
                  height: 140,
                  onImagePicked: (path) => setState(() => _leftSideImage = path),
                ),
                const SizedBox(height: AppSpacing.spaceM),

                Text('Right Side Markings', style: AppTypography.inputLabel),
                const SizedBox(height: 8),
                AppImagePicker(
                  currentImagePath: _rightSideImage,
                  label: 'Right Side Photo',
                  height: 140,
                  onImagePicked: (path) => setState(() => _rightSideImage = path),
                ),
                const SizedBox(height: AppSpacing.spaceM),

                Text('Head View Markings', style: AppTypography.inputLabel),
                const SizedBox(height: 8),
                AppImagePicker(
                  currentImagePath: _headViewImage,
                  label: 'Head View Photo',
                  height: 140,
                  onImagePicked: (path) => setState(() => _headViewImage = path),
                ),
                const SizedBox(height: AppSpacing.spaceM),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: CustomTextField(
                    controller: _headNotesController,
                    label: 'Head View / Brand Notes *',
                    prefixIcon: Icons.notes,
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Markings notes are required' : null,
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceXL),

                GradientCtaButton(
                  text: 'SAVE MARKINGS',
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
