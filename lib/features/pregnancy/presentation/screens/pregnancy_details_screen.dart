import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/pregnancy_record.dart';
import '../providers/pregnancy_provider.dart';

class PregnancyDetailsScreen extends ConsumerStatefulWidget {
  final String carrierType;
  final String carrierId;

  const PregnancyDetailsScreen({
    super.key,
    required this.carrierType,
    required this.carrierId,
  });

  @override
  ConsumerState<PregnancyDetailsScreen> createState() => _PregnancyDetailsScreenState();
}

class _PregnancyDetailsScreenState extends ConsumerState<PregnancyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vetNameController = TextEditingController();
  final _vetMobileController = TextEditingController();

  PregnancyRecord? _record;
  bool _scan1Confirmed = false;
  bool _scan2Confirmed = false;
  bool _scan3Confirmed = false;
  String? _scan1Image;
  String? _scan2Image;
  String? _scan3Image;
  bool _isSaving = false;

  @override
  void dispose() {
    _vetNameController.dispose();
    _vetMobileController.dispose();
    super.dispose();
  }

  void _populateFromRecord(PregnancyRecord r) {
    _record = r;
    _scan1Confirmed = r.scan1Confirmed;
    _scan2Confirmed = r.scan2Confirmed;
    _scan3Confirmed = r.scan3Confirmed;
    _scan1Image = r.scan1ImageUrl;
    _scan2Image = r.scan2ImageUrl;
    _scan3Image = r.scan3ImageUrl;
    _vetNameController.text = r.vetName ?? '';
    _vetMobileController.text = r.vetMobile ?? '';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _handleSave() async {
    if (_record == null) return;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields correctly.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final updated = PregnancyRecord(
        id: _record!.id,
        carrierType: _record!.carrierType,
        carrierId: _record!.carrierId,
        breedingRecordId: _record!.breedingRecordId,
        scan1DueDate: _record!.scan1DueDate,
        scan1Confirmed: _scan1Confirmed,
        scan1ImageUrl: _scan1Image,
        scan2DueDate: _record!.scan2DueDate,
        scan2Confirmed: _scan2Confirmed,
        scan2ImageUrl: _scan2Image,
        scan3DueDate: _record!.scan3DueDate,
        scan3Confirmed: _scan3Confirmed,
        scan3ImageUrl: _scan3Image,
        foalingDueDate: _record!.foalingDueDate,
        vetName: _vetNameController.text.trim(),
        vetMobile: _vetMobileController.text.trim(),
        createdAt: _record!.createdAt,
      );

      await repo.savePregnancyRecord(updated);
      ref.invalidate(pregnancyRecordForCarrierProvider((carrierType: widget.carrierType, carrierId: widget.carrierId)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pregnancy scan & vet details saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving pregnancy details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _callVet(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer for $phone')),
        );
      }
    }
  }

  Widget _buildScanSubCard({
    required String title,
    required DateTime? dueDate,
    required bool isConfirmed,
    required ValueChanged<bool> onConfirmedChanged,
    required String? imageUrl,
    required ValueChanged<String?> onPhotoPicked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceM),
      padding: const EdgeInsets.all(AppSpacing.spaceM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Due: ${_formatDate(dueDate)}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pregnancy Confirmed', style: AppTypography.bodyMedium),
              Checkbox(
                value: isConfirmed,
                activeColor: AppColors.primaryGold,
                checkColor: AppColors.background,
                onChanged: (val) => onConfirmedChanged(val ?? false),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceS),
          AppImagePicker(
            currentImagePath: imageUrl,
            label: 'Upload $title Photo',
            height: 110,
            icon: Icons.photo_camera,
            onImagePicked: onPhotoPicked,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pregnancyAsync = ref.watch(
      pregnancyRecordForCarrierProvider((carrierType: widget.carrierType, carrierId: widget.carrierId)),
    );

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
          'PREGNANCY DETAILS',
          style: AppTypography.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: pregnancyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
        error: (err, stack) => Center(child: Text('Error loading pregnancy details: $err', style: AppTypography.bodyMedium)),
        data: (record) {
          if (record == null) {
            return Center(
              child: Text('No active pregnancy record found for this mare.', style: AppTypography.bodyMedium),
            );
          }

          if (_record == null) {
            _populateFromRecord(record);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spaceL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Expected Foaling Due Date Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.child_care, color: AppColors.primaryGold, size: 36),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ESTIMATED FOALING DUE DATE', style: AppTypography.caption.copyWith(letterSpacing: 1.2)),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(record.foalingDueDate),
                              style: AppTypography.titleLarge.copyWith(color: AppColors.primaryGold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.spaceL),

                  // Static Warning Banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Early Pregnancy Scan Day 14-16 post cover/insemination. To reduce the risk of multiple pregnancies, it is strongly recommended to have your mare scanned by your veterinarian. Multiple pregnancies are dangerous and early detection is your best chance to safely manage them.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.spaceL),
                  const SectionDividerLabel(label: 'PREGNANCY SCANS (1, 2, 3)', isLeftAligned: true),
                  const SizedBox(height: AppSpacing.spaceM),

                  _buildScanSubCard(
                    title: '1st Pregnancy Scan',
                    dueDate: record.scan1DueDate,
                    isConfirmed: _scan1Confirmed,
                    onConfirmedChanged: (v) => setState(() => _scan1Confirmed = v),
                    imageUrl: _scan1Image,
                    onPhotoPicked: (path) => setState(() => _scan1Image = path),
                  ),

                  _buildScanSubCard(
                    title: '2nd Pregnancy Scan',
                    dueDate: record.scan2DueDate,
                    isConfirmed: _scan2Confirmed,
                    onConfirmedChanged: (v) => setState(() => _scan2Confirmed = v),
                    imageUrl: _scan2Image,
                    onPhotoPicked: (path) => setState(() => _scan2Image = path),
                  ),

                  _buildScanSubCard(
                    title: '3rd Pregnancy Scan',
                    dueDate: record.scan3DueDate,
                    isConfirmed: _scan3Confirmed,
                    onConfirmedChanged: (v) => setState(() => _scan3Confirmed = v),
                    imageUrl: _scan3Image,
                    onPhotoPicked: (path) => setState(() => _scan3Image = path),
                  ),

                  const SizedBox(height: AppSpacing.spaceL),
                  const SectionDividerLabel(label: 'VETERINARIAN DETAILS', isLeftAligned: true),
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
                          controller: _vetNameController,
                          label: 'Vet Name *',
                          prefixIcon: Icons.medical_services,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Vet name is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.spaceM),
                        CustomTextField(
                          controller: _vetMobileController,
                          label: 'Vet Mobile Number *',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Vet mobile number is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.spaceM),
                        if (_vetMobileController.text.trim().isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _callVet(_vetMobileController.text.trim()),
                            icon: const Icon(Icons.call, color: AppColors.background),
                            label: Text('CALL VET (${_vetMobileController.text.trim()})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              minimumSize: const Size(double.infinity, 44),
                            ),
                          )
                        else
                          Text(
                            'No Vet Added Yet',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.spaceL),

                  // Button to Advanced Pregnancy Info
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/advanced-pregnancy',
                        arguments: record.id,
                      );
                    },
                    icon: const Icon(Icons.biotech, color: AppColors.primaryGold),
                    label: Text(
                      'ADVANCED PREGNANCY INFO (CASLICK & FETAL SEX)',
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
                    text: 'SAVE PREGNANCY DETAILS',
                    onPressed: _handleSave,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
