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
  final String ownerType; // 'animal' or 'foal'
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
  final _headNotesController = TextEditingController();
  String? _leftSideImage;
  String? _rightSideImage;
  String? _headViewImage;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadExistingMarkings();
  }

  Future<void> _loadExistingMarkings() async {
    final repo = ref.read(mareRepositoryProvider);
    final markings = await repo.getMarkings(widget.ownerType, widget.ownerId);
    if (markings != null && mounted) {
      setState(() {
        _leftSideImage = markings.leftSideImageUrl;
        _rightSideImage = markings.rightSideImageUrl;
        _headViewImage = markings.headViewImageUrl;
        _headNotesController.text = markings.headViewNotes ?? '';
        _isLoaded = true;
      });
    } else {
      setState(() => _isLoaded = true);
    }
  }

  @override
  void dispose() {
    _headNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
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
      ref.invalidate(markingsForOwnerProvider((ownerType: widget.ownerType, ownerId: widget.ownerId)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Markings details saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save markings: $e')),
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
        title: const Text('PHYSICAL MARKINGS', style: AppTypography.sectionLabel),
        centerTitle: true,
      ),
      body: SafeArea(
        child: !_isLoaded
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                child: ResponsiveBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Disclaimer Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Left Side Markings
                      const SectionDividerLabel(label: 'LEFT SIDE VIEW'),
                      const SizedBox(height: 12.0),
                      AppImagePicker(
                        label: 'Left Side Markings Photo (Camera First) (Optional)',
                        initialImageUrl: _leftSideImage,
                        onImageSelected: (url) => setState(() => _leftSideImage = url),
                      ),
                      const SizedBox(height: 24.0),

                      // Right Side Markings
                      const SectionDividerLabel(label: 'RIGHT SIDE VIEW'),
                      const SizedBox(height: 12.0),
                      AppImagePicker(
                        label: 'Right Side Markings Photo (Camera First) (Optional)',
                        initialImageUrl: _rightSideImage,
                        onImageSelected: (url) => setState(() => _rightSideImage = url),
                      ),
                      const SizedBox(height: 24.0),

                      // Head View
                      const SectionDividerLabel(label: 'HEAD VIEW & FACIAL MARKINGS'),
                      const SizedBox(height: 12.0),
                      AppImagePicker(
                        label: 'Head View / Muzzle Markings Photo (Optional)',
                        initialImageUrl: _headViewImage,
                        onImageSelected: (url) => setState(() => _headViewImage = url),
                      ),
                      const SizedBox(height: 14.0),

                      CustomTextField(
                        label: 'Head View & Facial Notes (Optional)',
                        hintText: 'e.g. Star, strip, snip, white lower lip, whorl between eyes...',
                        controller: _headNotesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32.0),

                      // Save CTA
                      GradientCtaButton(
                        text: _isSaving ? 'SAVING MARKINGS...' : 'SAVE MARKINGS',
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
