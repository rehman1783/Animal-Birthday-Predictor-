import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/advanced_pregnancy_info.dart';
import '../providers/pregnancy_provider.dart';

class AdvancedPregnancyInfoScreen extends ConsumerStatefulWidget {
  final String pregnancyRecordId;

  const AdvancedPregnancyInfoScreen({super.key, required this.pregnancyRecordId});

  @override
  ConsumerState<AdvancedPregnancyInfoScreen> createState() => _AdvancedPregnancyInfoScreenState();
}

class _AdvancedPregnancyInfoScreenState extends ConsumerState<AdvancedPregnancyInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _caslickDate;
  bool _caslickDone = false;

  DateTime? _fetalSexScanDate;
  bool _fetalSexScanDone = false;

  DateTime? _ffsResultDate;
  String _ffsResult = 'filly'; // 'filly' or 'colt'

  String? _ultrasoundImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(pregnancyRepositoryProvider);
    final existing = await repo.getAdvancedPregnancyInfo(widget.pregnancyRecordId);
    if (existing != null && mounted) {
      setState(() {
        _caslickDate = existing.caslickDate;
        _caslickDone = existing.caslickDone;
        _fetalSexScanDate = existing.fetalSexScanDate;
        _fetalSexScanDone = existing.fetalSexScanDone;
        _ffsResultDate = existing.ffsResultDate;
        _ffsResult = existing.ffsResult ?? 'filly';
        _ultrasoundImageUrl = existing.ultrasoundImageUrl;
      });
    }
  }

  Future<DateTime?> _pickDate(DateTime? current) async {
    return showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
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
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final info = AdvancedPregnancyInfo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pregnancyRecordId: widget.pregnancyRecordId,
        caslickDate: _caslickDate,
        caslickDone: _caslickDone,
        fetalSexScanDate: _fetalSexScanDate,
        fetalSexScanDone: _fetalSexScanDone,
        ffsResultDate: _ffsResultDate,
        ffsResult: _ffsResult,
        ultrasoundImageUrl: _ultrasoundImageUrl,
      );

      await repo.saveAdvancedPregnancyInfo(info);
      ref.invalidate(advancedPregnancyInfoProvider(widget.pregnancyRecordId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advanced pregnancy info saved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving info: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSubCard({
    required String title,
    required DateTime? date,
    required ValueChanged<DateTime?> onDateChanged,
    required Widget toggleWidget,
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
          Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
          const SizedBox(height: AppSpacing.spaceS),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12.0,
            runSpacing: 8.0,
            children: [
              InkWell(
                onTap: () async {
                  final picked = await _pickDate(date);
                  if (picked != null) onDateChanged(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.inputField,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primaryGold, size: 16),
                      const SizedBox(width: 8),
                      Text(_formatDate(date), style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ),
              toggleWidget,
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'ADVANCED PREGNANCY INFO',
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
                const SectionDividerLabel(label: 'PROCEDURES & SEXING', isLeftAligned: true),
                const SizedBox(height: AppSpacing.spaceM),

                // 1. Caslick Sub-Card
                _buildSubCard(
                  title: 'Caslick Procedure',
                  date: _caslickDate,
                  onDateChanged: (d) => setState(() => _caslickDate = d),
                  toggleWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Performed', style: AppTypography.bodySmall),
                      Switch(
                        value: _caslickDone,
                        activeThumbColor: AppColors.primaryGold,
                        onChanged: (v) => setState(() => _caslickDone = v),
                      ),
                    ],
                  ),
                ),

                // 2. Fetal Sex Scan Sub-Card
                _buildSubCard(
                  title: 'Fetal Sex Scan',
                  date: _fetalSexScanDate,
                  onDateChanged: (d) => setState(() => _fetalSexScanDate = d),
                  toggleWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Done', style: AppTypography.bodySmall),
                      Switch(
                        value: _fetalSexScanDone,
                        activeThumbColor: AppColors.primaryGold,
                        onChanged: (v) => setState(() => _fetalSexScanDone = v),
                      ),
                    ],
                  ),
                ),

                // 3. FFS Result Sub-Card
                _buildSubCard(
                  title: 'Fetal Sex Result (FFS)',
                  date: _ffsResultDate,
                  onDateChanged: (d) => setState(() => _ffsResultDate = d),
                  toggleWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChoiceChip(
                        label: const Text('Filly'),
                        selected: _ffsResult == 'filly',
                        selectedColor: AppColors.primaryGold,
                        onSelected: (val) {
                          if (val) setState(() => _ffsResult = 'filly');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Colt'),
                        selected: _ffsResult == 'colt',
                        selectedColor: AppColors.primaryGold,
                        onSelected: (val) {
                          if (val) setState(() => _ffsResult = 'colt');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceM),

                // Ultrasound Photo Upload Slot
                AppImagePicker(
                  currentImagePath: _ultrasoundImageUrl,
                  label: 'Upload Fetal Ultrasound Image',
                  height: 120,
                  icon: Icons.center_focus_strong,
                  onImagePicked: (path) => setState(() => _ultrasoundImageUrl = path),
                ),

                const SizedBox(height: AppSpacing.spaceL),

                // Static Disclaimer Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Fetal sexing is a specialised procedure that relies on optimal timing and imaging conditions. While every effort is made to provide accurate results, results are not guaranteed and may be subject to misinterpretation due to fetal positioning, natural variation etc. We recommend discussing any findings with a qualified veterinarian. This feature is provided for informational purposes only.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceXL),

                GradientCtaButton(
                  text: 'SAVE ADVANCED INFO',
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
