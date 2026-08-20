import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/advanced_pregnancy_info.dart';
import '../providers/pregnancy_provider.dart';

class AdvancedPregnancyInfoScreen extends ConsumerStatefulWidget {
  final String pregnancyRecordId;

  const AdvancedPregnancyInfoScreen({
    super.key,
    required this.pregnancyRecordId,
  });

  @override
  ConsumerState<AdvancedPregnancyInfoScreen> createState() => _AdvancedPregnancyInfoScreenState();
}

class _AdvancedPregnancyInfoScreenState extends ConsumerState<AdvancedPregnancyInfoScreen> {
  DateTime? _caslickDate;
  bool _caslickDone = false;

  DateTime? _fetalSexDate;
  bool _fetalSexDone = false;

  DateTime? _ffsResultDate;
  String? _ffsResult; // 'filly', 'colt'

  String? _infoId;
  String? _ultrasoundImage;
  bool _isSaving = false;
  bool _isLoaded = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoaded = false;
      _loadError = null;
    });
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final info = await repo.getAdvancedPregnancyInfo(widget.pregnancyRecordId);
      if (info != null && mounted) {
        setState(() {
          _infoId = info.id;
          _caslickDate = info.caslickDate;
          _caslickDone = info.caslickDone;
          _fetalSexDate = info.fetalSexScanDate;
          _fetalSexDone = info.fetalSexScanDone;
          _ffsResultDate = info.ffsResultDate;
          _ffsResult = info.ffsResult;
          _ultrasoundImage = info.ultrasoundImageUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoaded = true);
      }
    }
  }

  Future<void> _pickDate(String type) async {
    DateTime initial = DateTime.now();
    if (type == 'caslick' && _caslickDate != null) initial = _caslickDate!;
    if (type == 'fetal_sex' && _fetalSexDate != null) initial = _fetalSexDate!;
    if (type == 'ffs_result' && _ffsResultDate != null) initial = _ffsResultDate!;

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
        if (type == 'caslick') _caslickDate = picked;
        if (type == 'fetal_sex') _fetalSexDate = picked;
        if (type == 'ffs_result') _ffsResultDate = picked;
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final info = AdvancedPregnancyInfo(
        id: _infoId ?? '',
        pregnancyRecordId: widget.pregnancyRecordId,
        caslickDate: _caslickDate,
        caslickDone: _caslickDone,
        fetalSexScanDate: _fetalSexDate,
        fetalSexScanDone: _fetalSexDone,
        ffsResultDate: _ffsResultDate,
        ffsResult: _ffsResult,
        ultrasoundImageUrl: _ultrasoundImage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveAdvancedPregnancyInfo(info);
      ref.invalidate(advancedPregnancyInfoProvider(widget.pregnancyRecordId));

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: 'Info Saved',
          message: 'Advanced pregnancy info saved successfully!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Save Failed',
          error: e,
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
        title: const Text('ADVANCED PREGNANCY INFO', style: AppTypography.sectionLabel),
        centerTitle: true,
      ),
      body: SafeArea(
        child: !_isLoaded
            ? const AppLoadingView(message: 'Loading advanced pregnancy info...')
            : _loadError != null
                ? AppErrorView(
                    error: _loadError,
                    onRetry: _loadData,
                  )
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
                              'Fetal sexing is a specialised procedure that relies on optimal timing and imaging conditions. While every effort is made to provide accurate information, results are not guaranteed and may be subject to misinterpretation due to fetal positioning, natural variation etc. We recommend discussing any findings with a qualified veterinarian. This feature is provided for informational purposes only.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // 1. Caslick Section
                    const SectionDividerLabel(label: 'CASLICK PROCEDURE'),
                    const SizedBox(height: 12.0),
                    _ProcedureCard(
                      title: 'Caslick Procedure',
                      date: _caslickDate,
                      isDone: _caslickDone,
                      onPickDate: () => _pickDate('caslick'),
                      onToggleDone: (val) => setState(() => _caslickDone = val ?? false),
                    ),
                    const SizedBox(height: 20.0),

                    // 2. Fetal Sex Scan Section
                    const SectionDividerLabel(label: 'FETAL SEX SCAN'),
                    const SizedBox(height: 12.0),
                    _ProcedureCard(
                      title: 'Fetal Sex Scan Procedure',
                      date: _fetalSexDate,
                      isDone: _fetalSexDone,
                      onPickDate: () => _pickDate('fetal_sex'),
                      onToggleDone: (val) => setState(() => _fetalSexDone = val ?? false),
                    ),
                    const SizedBox(height: 20.0),

                    // 3. FFS Result Section
                    const SectionDividerLabel(label: 'FETAL SEX SCAN (FFS) RESULT'),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: AppColors.surface),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              const Text('Result Date', style: AppTypography.inputLabel),
                              GestureDetector(
                                onTap: () => _pickDate('ffs_result'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputField,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _formatDate(_ffsResultDate),
                                    style: TextStyle(
                                      color: _ffsResultDate != null ? AppColors.primaryGold : AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text('Fetal Gender Determination', style: AppTypography.displayHeadline.copyWith(fontSize: 15)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _ffsResult = 'filly'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _ffsResult == 'filly' ? AppColors.primaryGold : AppColors.inputField,
                                    foregroundColor: _ffsResult == 'filly' ? AppColors.background : AppColors.textPrimary,
                                    side: const BorderSide(color: AppColors.primaryGold),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('FILLY (FEMALE)', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _ffsResult = 'colt'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _ffsResult == 'colt' ? AppColors.primaryGold : AppColors.inputField,
                                    foregroundColor: _ffsResult == 'colt' ? AppColors.background : AppColors.textPrimary,
                                    side: const BorderSide(color: AppColors.primaryGold),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('COLT (MALE)', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // 4. Ultrasound Image
                    const SectionDividerLabel(label: 'FETAL ULTRASOUND SCAN IMAGE'),
                    const SizedBox(height: 12.0),
                    AppImagePicker(
                      label: 'Upload Ultrasound Image (Optional)',
                      initialImageUrl: _ultrasoundImage,
                      onImageSelected: (url) => setState(() => _ultrasoundImage = url),
                    ),
                    const SizedBox(height: 32.0),

                    // Save CTA
                    GradientCtaButton(
                      text: _isSaving ? 'SAVING...' : 'SAVE ADVANCED PREGNANCY INFO',
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

class _ProcedureCard extends StatelessWidget {
  final String title;
  final DateTime? date;
  final bool isDone;
  final VoidCallback onPickDate;
  final ValueChanged<bool?> onToggleDone;

  const _ProcedureCard({
    required this.title,
    required this.date,
    required this.isDone,
    required this.onPickDate,
    required this.onToggleDone,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isDone ? AppColors.primaryGold : AppColors.surface,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                title,
                style: AppTypography.displayHeadline.copyWith(fontSize: 15),
              ),
              GestureDetector(
                onTap: onPickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.inputField,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: date != null ? AppColors.primaryGold : AppColors.surface),
                  ),
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      color: date != null ? AppColors.primaryGold : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.inputField,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isDone,
                  onChanged: onToggleDone,
                  activeColor: AppColors.primaryGold,
                  checkColor: AppColors.background,
                  side: const BorderSide(color: AppColors.primaryGold),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Procedure Performed (Yes)',
                    style: TextStyle(
                      color: isDone ? AppColors.primaryGold : AppColors.textPrimary,
                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
