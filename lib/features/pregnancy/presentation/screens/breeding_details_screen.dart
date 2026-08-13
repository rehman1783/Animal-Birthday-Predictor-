import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/breeding_record.dart';
import '../providers/pregnancy_provider.dart';

class BreedingDetailsScreen extends ConsumerStatefulWidget {
  final String mareId;

  const BreedingDetailsScreen({super.key, required this.mareId});

  @override
  ConsumerState<BreedingDetailsScreen> createState() => _BreedingDetailsScreenState();
}

class _BreedingDetailsScreenState extends ConsumerState<BreedingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMethod; // 'natural', 'chilled', 'frozen', 'icsi'
  bool _isEmbryoTransfer = false;
  DateTime _coverDate = DateTime.now();
  String? _photoUrl;
  bool _isSaving = false;

  final List<({String label, String value})> _methods = const [
    (label: 'Natural', value: 'natural'),
    (label: 'Chilled', value: 'chilled'),
    (label: 'Frozen', value: 'frozen'),
    (label: 'ICSI', value: 'icsi'),
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _coverDate,
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
      setState(() => _coverDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a breeding method (* required)')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(pregnancyRepositoryProvider);
      final breedingRecord = BreedingRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mareId: widget.mareId,
        method: _selectedMethod!,
        isEmbryoTransfer: _isEmbryoTransfer,
        coverOrTransferDate: _coverDate,
        photoUrl: _photoUrl,
        createdAt: DateTime.now(),
      );

      final savedBreeding = await repo.saveBreedingRecord(breedingRecord);

      if (mounted) {
        if (_isEmbryoTransfer) {
          // Navigate to Recipient Mare Details next
          Navigator.pushNamed(
            context,
            '/recipient-mare-details',
            arguments: savedBreeding.id,
          );
        } else {
          // Immediately calculate and insert pregnancy record for Donor Mare
          await repo.createCalculatedPregnancyRecord(
            carrierType: 'mare',
            carrierId: widget.mareId,
            breedingRecordId: savedBreeding.id,
            method: _selectedMethod!,
            baseDate: _coverDate,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Breeding details & pregnancy record saved!')),
            );
            Navigator.pushNamed(
              context,
              '/pregnancy-details',
              arguments: {'carrierType': 'mare', 'carrierId': widget.mareId},
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving breeding details: $e')),
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
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BREEDING DETAILS',
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
                const SectionDividerLabel(label: 'BREEDING METHOD *', isLeftAligned: true),
                const SizedBox(height: AppSpacing.spaceM),

                // Responsive Wrap for Chips
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _methods.map((m) {
                    final isSelected = _selectedMethod == m.value;
                    return ChoiceChip(
                      label: Text(
                        m.label,
                        style: TextStyle(
                          color: isSelected ? AppColors.background : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGold,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryGold : AppColors.inputBorder,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedMethod = m.value;
                            if (m.value == 'icsi') {
                              _isEmbryoTransfer = true; // ICSI is embryo transfer by nature
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                ),

                if (_selectedMethod == null) ...[
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      '* Selecting a breeding method is required',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],

                if (_selectedMethod != null) ...[
                  const SizedBox(height: AppSpacing.spaceL),
                  const SectionDividerLabel(label: 'EMBRYO TRANSFER', isLeftAligned: true),
                  const SizedBox(height: AppSpacing.spaceM),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Was the resulting embryo transferred to a recipient mare?',
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isEmbryoTransfer,
                          activeThumbColor: AppColors.primaryGold,
                          onChanged: _selectedMethod == 'icsi'
                              ? null // Locked to true for ICSI
                              : (val) {
                                  setState(() => _isEmbryoTransfer = val);
                                },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.spaceL),
                const SectionDividerLabel(label: 'DATE & DOCUMENTATION', isLeftAligned: true),
                const SizedBox(height: AppSpacing.spaceM),

                // Date Picker Field
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEmbryoTransfer ? 'Date of Transfer *' : 'Date of Cover / Insemination *',
                                style: AppTypography.inputLabel,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_coverDate.day}/${_coverDate.month}/${_coverDate.year}',
                                style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: AppColors.primaryGold),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceM),

                // Insemination Photo Slot using AppImagePicker
                AppImagePicker(
                  currentImagePath: _photoUrl,
                  label: 'Tap to Add Insemination / Straw Photo',
                  height: 120,
                  onImagePicked: (path) => setState(() => _photoUrl = path),
                ),

                const SizedBox(height: AppSpacing.spaceXL),

                GradientCtaButton(
                  text: _isEmbryoTransfer ? 'CONTINUE TO RECIPIENT MARE' : 'SAVE & VIEW PREGNANCY SCANS',
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
