import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/preventative_care_record.dart';
import '../providers/preventative_care_provider.dart';
import '../widgets/contact_number_block.dart';
import '../widgets/vaccination_row.dart';

class PreventativeCareScreen extends ConsumerStatefulWidget {
  final String ownerType; // 'animal' or 'foal'
  final String ownerId;
  final String? title;
  final String? damMareId; // If foal, looks up dam mare's vaccines

  const PreventativeCareScreen({
    super.key,
    required this.ownerType,
    required this.ownerId,
    this.title,
    this.damMareId,
  });

  @override
  ConsumerState<PreventativeCareScreen> createState() => _PreventativeCareScreenState();
}

class _PreventativeCareScreenState extends ConsumerState<PreventativeCareScreen> {
  final _dentistNumberController = TextEditingController();
  final _farrierNumberController = TextEditingController();

  DateTime? _wormerDate;
  bool _wormerDone = false;

  DateTime? _tetanusDate;
  bool _tetanusDone = false;

  DateTime? _stranglesDate;
  bool _stranglesDone = false;

  DateTime? _eqHerpesDate;
  bool _eqHerpesDone = false;

  DateTime? _rotavirusDate;
  bool _rotavirusDone = false;

  DateTime? _hendraDate;
  bool _hendraDone = false;

  DateTime? _eqInfluenzaDate;
  bool _eqInfluenzaDone = false;

  DateTime? _eeeWeeWnvDate;
  bool _eeeWeeWnvDone = false;

  DateTime? _rabiesDate;
  bool _rabiesDone = false;

  DateTime? _dentalDate;
  bool _dentalDone = false;

  DateTime? _farrierDate;
  bool _farrierDone = false;

  PreventativeCareRecord? _damMareCare;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(preventativeCareRepositoryProvider);
    final rec = await repo.getPreventativeCare(widget.ownerType, widget.ownerId);

    if (rec != null && mounted) {
      _wormerDate = rec.wormerDate;
      _wormerDone = rec.wormerDone;
      _tetanusDate = rec.tetanusDate;
      _tetanusDone = rec.tetanusDone;
      _stranglesDate = rec.stranglesDate;
      _stranglesDone = rec.stranglesDone;
      _eqHerpesDate = rec.eqHerpesDate;
      _eqHerpesDone = rec.eqHerpesDone;
      _rotavirusDate = rec.rotavirusDate;
      _rotavirusDone = rec.rotavirusDone;
      _hendraDate = rec.hendraDate;
      _hendraDone = rec.hendraDone;
      _eqInfluenzaDate = rec.eqInfluenzaDate;
      _eqInfluenzaDone = rec.eqInfluenzaDone;
      _eeeWeeWnvDate = rec.eeeWeeWnvDate;
      _eeeWeeWnvDone = rec.eeeWeeWnvDone;
      _rabiesDate = rec.rabiesDate;
      _rabiesDone = rec.rabiesDone;
      _dentalDate = rec.dentalDate;
      _dentalDone = rec.dentalDone;
      _dentistNumberController.text = rec.dentistNumber ?? '';
      _farrierDate = rec.farrierDate;
      _farrierDone = rec.farrierDone;
      _farrierNumberController.text = rec.farrierNumber ?? '';
    }

    if (widget.damMareId != null && widget.damMareId!.isNotEmpty) {
      _damMareCare = await repo.getPreventativeCare('animal', widget.damMareId!);
    }

    if (mounted) setState(() => _isLoaded = true);
  }

  @override
  void dispose() {
    _dentistNumberController.dispose();
    _farrierNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String key) async {
    DateTime initial = DateTime.now();
    switch (key) {
      case 'wormer': if (_wormerDate != null) initial = _wormerDate!; break;
      case 'tetanus': if (_tetanusDate != null) initial = _tetanusDate!; break;
      case 'strangles': if (_stranglesDate != null) initial = _stranglesDate!; break;
      case 'eq_herpes': if (_eqHerpesDate != null) initial = _eqHerpesDate!; break;
      case 'rotavirus': if (_rotavirusDate != null) initial = _rotavirusDate!; break;
      case 'hendra': if (_hendraDate != null) initial = _hendraDate!; break;
      case 'eq_influenza': if (_eqInfluenzaDate != null) initial = _eqInfluenzaDate!; break;
      case 'eee_wee_wnv': if (_eeeWeeWnvDate != null) initial = _eeeWeeWnvDate!; break;
      case 'rabies': if (_rabiesDate != null) initial = _rabiesDate!; break;
      case 'dental': if (_dentalDate != null) initial = _dentalDate!; break;
      case 'farrier': if (_farrierDate != null) initial = _farrierDate!; break;
    }

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
        switch (key) {
          case 'wormer': _wormerDate = picked; break;
          case 'tetanus': _tetanusDate = picked; break;
          case 'strangles': _stranglesDate = picked; break;
          case 'eq_herpes': _eqHerpesDate = picked; break;
          case 'rotavirus': _rotavirusDate = picked; break;
          case 'hendra': _hendraDate = picked; break;
          case 'eq_influenza': _eqInfluenzaDate = picked; break;
          case 'eee_wee_wnv': _eeeWeeWnvDate = picked; break;
          case 'rabies': _rabiesDate = picked; break;
          case 'dental': _dentalDate = picked; break;
          case 'farrier': _farrierDate = picked; break;
        }
      });
    }
  }

  String _formatDateShort(DateTime? dt) {
    if (dt == null) return 'none';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(preventativeCareRepositoryProvider);
      final record = PreventativeCareRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerType: widget.ownerType,
        ownerId: widget.ownerId,
        wormerDate: _wormerDate,
        wormerDone: _wormerDone,
        tetanusDate: _tetanusDate,
        tetanusDone: _tetanusDone,
        stranglesDate: _stranglesDate,
        stranglesDone: _stranglesDone,
        eqHerpesDate: _eqHerpesDate,
        eqHerpesDone: _eqHerpesDone,
        rotavirusDate: _rotavirusDate,
        rotavirusDone: _rotavirusDone,
        hendraDate: _hendraDate,
        hendraDone: _hendraDone,
        eqInfluenzaDate: _eqInfluenzaDate,
        eqInfluenzaDone: _eqInfluenzaDone,
        eeeWeeWnvDate: _eeeWeeWnvDate,
        eeeWeeWnvDone: _eeeWeeWnvDone,
        rabiesDate: _rabiesDate,
        rabiesDone: _rabiesDone,
        dentalDate: _dentalDate,
        dentalDone: _dentalDone,
        dentistNumber: _dentistNumberController.text.trim(),
        farrierDate: _farrierDate,
        farrierDone: _farrierDone,
        farrierNumber: _farrierNumberController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.savePreventativeCare(record);
      ref.invalidate(preventativeCareForOwnerProvider((ownerType: widget.ownerType, ownerId: widget.ownerId)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preventative care details saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save preventative care: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFoal = widget.ownerType == 'foal';

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
          widget.title != null ? '${widget.title!.toUpperCase()} HEALTH' : 'PREVENTATIVE CARE',
          style: AppTypography.sectionLabel,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: !_isLoaded
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Disclaimer Header
                    if (isFoal) ...[
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
                                'All foals require a priming vaccination program for most vaccinations, always consult your Veterinarian for correct schedule and vaccine for your region. Please note the Vaccination Status of the pregnant mare will affect the start date of the priming program.',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],

                    // 1. Parasite & Deworming
                    const SectionDividerLabel(label: 'PARASITE & DEWORMING'),
                    const SizedBox(height: 12.0),

                    VaccinationRow(
                      label: 'Wormer',
                      interval: 'Interval: Every 6-8 weeks as per vet protocol',
                      date: _wormerDate,
                      done: _wormerDone,
                      onPickDate: () => _pickDate('wormer'),
                      onToggleDone: (v) => setState(() => _wormerDone = v ?? false),
                    ),
                    const SizedBox(height: 20.0),

                    // 2. Vaccinations
                    const SectionDividerLabel(label: 'CORE & RISK-BASED VACCINATIONS'),
                    const SizedBox(height: 12.0),

                    VaccinationRow(
                      label: 'Tetanus Toxoid',
                      interval: 'Interval: Annual booster / Pre-foaling 4 weeks',
                      date: _tetanusDate,
                      done: _tetanusDone,
                      onPickDate: () => _pickDate('tetanus'),
                      onToggleDone: (v) => setState(() => _tetanusDone = v ?? false),
                      mareReferenceNote: isFoal && _damMareCare != null
                          ? "Mare's Tetanus recorded ${_formatDateShort(_damMareCare!.tetanusDate)}"
                          : null,
                    ),

                    VaccinationRow(
                      label: 'Strangles',
                      interval: 'Interval: Annual booster as recommended',
                      date: _stranglesDate,
                      done: _stranglesDone,
                      onPickDate: () => _pickDate('strangles'),
                      onToggleDone: (v) => setState(() => _stranglesDone = v ?? false),
                      mareReferenceNote: isFoal && _damMareCare != null
                          ? "Mare's Strangles recorded ${_formatDateShort(_damMareCare!.stranglesDate)}"
                          : null,
                    ),

                    VaccinationRow(
                      label: 'Equine Herpes Virus (EHV-1/4)',
                      interval: 'Interval: 5, 7 & 9 months gestation / Annual',
                      date: _eqHerpesDate,
                      done: _eqHerpesDone,
                      onPickDate: () => _pickDate('eq_herpes'),
                      onToggleDone: (v) => setState(() => _eqHerpesDone = v ?? false),
                      mareReferenceNote: isFoal && _damMareCare != null
                          ? "Mare's EHV recorded ${_formatDateShort(_damMareCare!.eqHerpesDate)}"
                          : null,
                    ),

                    VaccinationRow(
                      label: 'Rotavirus',
                      interval: 'Interval: 8, 9 & 10 months gestation',
                      date: _rotavirusDate,
                      done: _rotavirusDone,
                      onPickDate: () => _pickDate('rotavirus'),
                      onToggleDone: (v) => setState(() => _rotavirusDone = v ?? false),
                    ),

                    VaccinationRow(
                      label: 'Hendra Virus (AUS)',
                      interval: 'Interval: 6-month booster in endemic regions',
                      date: _hendraDate,
                      done: _hendraDone,
                      onPickDate: () => _pickDate('hendra'),
                      onToggleDone: (v) => setState(() => _hendraDone = v ?? false),
                    ),

                    VaccinationRow(
                      label: 'EQ Influenza (EU & UK)',
                      interval: 'Interval: Annual / 6-month FEI requirements',
                      date: _eqInfluenzaDate,
                      done: _eqInfluenzaDone,
                      onPickDate: () => _pickDate('eq_influenza'),
                      onToggleDone: (v) => setState(() => _eqInfluenzaDone = v ?? false),
                    ),

                    VaccinationRow(
                      label: 'EEE / WEE / WNV (USA)',
                      interval: 'Interval: Annual booster before vector season',
                      date: _eeeWeeWnvDate,
                      done: _eeeWeeWnvDone,
                      onPickDate: () => _pickDate('eee_wee_wnv'),
                      onToggleDone: (v) => setState(() => _eeeWeeWnvDone = v ?? false),
                    ),

                    VaccinationRow(
                      label: 'Rabies (USA)',
                      interval: 'Interval: Annual booster in rabies risk regions',
                      date: _rabiesDate,
                      done: _rabiesDone,
                      onPickDate: () => _pickDate('rabies'),
                      onToggleDone: (v) => setState(() => _rabiesDone = v ?? false),
                    ),
                    const SizedBox(height: 20.0),

                    // 3. Dentistry & Farrier
                    const SectionDividerLabel(label: 'DENTISTRY & FARRIER CARE'),
                    const SizedBox(height: 12.0),

                    // Dental Date Row
                    VaccinationRow(
                      label: 'Dentistry Check',
                      interval: 'Routine dental examination & floating',
                      date: _dentalDate,
                      done: _dentalDone,
                      onPickDate: () => _pickDate('dental'),
                      onToggleDone: (v) => setState(() => _dentalDone = v ?? false),
                    ),

                    ContactNumberBlock(
                      title: 'Equine Dentist',
                      hintText: 'e.g. +1 555 019 4920',
                      controller: _dentistNumberController,
                      icon: Icons.medical_information_outlined,
                      onSave: _handleSave,
                    ),

                    // Farrier Date Row
                    VaccinationRow(
                      label: 'Farrier / Trimming',
                      interval: 'Routine hoof care, trimming & shoeing (4-6 weeks)',
                      date: _farrierDate,
                      done: _farrierDone,
                      onPickDate: () => _pickDate('farrier'),
                      onToggleDone: (v) => setState(() => _farrierDone = v ?? false),
                    ),

                    ContactNumberBlock(
                      title: 'Farrier',
                      hintText: 'e.g. +1 555 019 7291',
                      controller: _farrierNumberController,
                      icon: Icons.handyman_outlined,
                      onSave: _handleSave,
                    ),
                    const SizedBox(height: 24.0),

                    // Save CTA
                    GradientCtaButton(
                      text: _isSaving ? 'SAVING CARE RECORDS...' : 'SAVE PREVENTATIVE CARE',
                      onPressed: _isSaving ? null : _handleSave,
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
      ),
    );
  }
}
