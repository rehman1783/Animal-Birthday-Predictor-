import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../pregnancy/domain/preventative_care_record.dart';
import '../../../pregnancy/presentation/providers/preventative_care_provider.dart';

class FoalPreventativeCareScreen extends ConsumerStatefulWidget {
  final String foalId;
  final String? damMareId;

  const FoalPreventativeCareScreen({
    super.key,
    required this.foalId,
    this.damMareId,
  });

  @override
  ConsumerState<FoalPreventativeCareScreen> createState() => _FoalPreventativeCareScreenState();
}

class _FoalPreventativeCareScreenState extends ConsumerState<FoalPreventativeCareScreen> {
  final Map<String, ({DateTime? date, bool done, String label, String interval})> _careItems = {
    'tetanus': (date: null, done: false, label: 'Tetanus', interval: 'Priming schedule at 3, 4 & 5 months'),
    'strangles': (date: null, done: false, label: 'Strangles', interval: 'Priming schedule at 3, 4 & 5 months'),
    'eq_herpes': (date: null, done: false, label: 'Equine Herpes Virus', interval: 'As advised by vet'),
    'rotavirus': (date: null, done: false, label: 'Rotavirus', interval: 'Dam vaccination timing dependent'),
    'hendra': (date: null, done: false, label: 'Hendra Virus (AUS)', interval: 'Start at 6 months'),
    'eq_influenza': (date: null, done: false, label: 'EQ Influenza (EU & UK)', interval: 'Start at 6 months'),
    'eee_wee_wnv': (date: null, done: false, label: 'EEE / WEE / WNV (USA)', interval: 'Start at 4-6 months'),
    'rabies': (date: null, done: false, label: 'Rabies (USA)', interval: 'Start at 6 months'),
    'wormer': (date: null, done: false, label: 'Wormer', interval: 'First worming at 6-8 weeks'),
  };

  PreventativeCareRecord? _damMareCareRecord;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(preventativeCareRepositoryProvider);
    final record = await repo.getPreventativeCare('foal', widget.foalId);
    if (record != null && mounted) {
      setState(() {
        _careItems['tetanus'] = (date: record.tetanusDate, done: record.tetanusDone, label: 'Tetanus', interval: 'Priming schedule at 3, 4 & 5 months');
        _careItems['strangles'] = (date: record.stranglesDate, done: record.stranglesDone, label: 'Strangles', interval: 'Priming schedule at 3, 4 & 5 months');
        _careItems['eq_herpes'] = (date: record.eqHerpesDate, done: record.eqHerpesDone, label: 'Equine Herpes Virus', interval: 'As advised by vet');
        _careItems['rotavirus'] = (date: record.rotavirusDate, done: record.rotavirusDone, label: 'Rotavirus', interval: 'Dam vaccination timing dependent');
        _careItems['hendra'] = (date: record.hendraDate, done: record.hendraDone, label: 'Hendra Virus (AUS)', interval: 'Start at 6 months');
        _careItems['eq_influenza'] = (date: record.eqInfluenzaDate, done: record.eqInfluenzaDone, label: 'EQ Influenza (EU & UK)', interval: 'Start at 6 months');
        _careItems['eee_wee_wnv'] = (date: record.eeeWeeWnvDate, done: record.eeeWeeWnvDone, label: 'EEE / WEE / WNV (USA)', interval: 'Start at 4-6 months');
        _careItems['rabies'] = (date: record.rabiesDate, done: record.rabiesDone, label: 'Rabies (USA)', interval: 'Start at 6 months');
        _careItems['wormer'] = (date: record.wormerDate, done: record.wormerDone, label: 'Wormer', interval: 'First worming at 6-8 weeks');
      });
    }

    if (widget.damMareId != null && widget.damMareId!.isNotEmpty) {
      final damRecord = await repo.getPreventativeCare('mare', widget.damMareId!);
      if (damRecord != null && mounted) {
        setState(() => _damMareCareRecord = damRecord);
      }
    }
  }

  Future<void> _pickDate(String key) async {
    final current = _careItems[key]?.date;
    final picked = await showDatePicker(
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

    if (picked != null) {
      setState(() {
        final item = _careItems[key]!;
        _careItems[key] = (date: picked, done: item.done, label: item.label, interval: item.interval);
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String? _getDamCareDateString(String key) {
    if (_damMareCareRecord == null) return null;
    DateTime? d;
    switch (key) {
      case 'tetanus':
        d = _damMareCareRecord!.tetanusDate;
        break;
      case 'strangles':
        d = _damMareCareRecord!.stranglesDate;
        break;
      case 'eq_herpes':
        d = _damMareCareRecord!.eqHerpesDate;
        break;
      case 'rotavirus':
        d = _damMareCareRecord!.rotavirusDate;
        break;
      case 'hendra':
        d = _damMareCareRecord!.hendraDate;
        break;
      case 'eq_influenza':
        d = _damMareCareRecord!.eqInfluenzaDate;
        break;
      case 'eee_wee_wnv':
        d = _damMareCareRecord!.eeeWeeWnvDate;
        break;
      case 'rabies':
        d = _damMareCareRecord!.rabiesDate;
        break;
      case 'wormer':
        d = _damMareCareRecord!.wormerDate;
        break;
    }
    if (d == null) return null;
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(preventativeCareRepositoryProvider);
      final record = PreventativeCareRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerType: 'foal',
        ownerId: widget.foalId,
        wormerDate: _careItems['wormer']?.date,
        wormerDone: _careItems['wormer']?.done ?? false,
        tetanusDate: _careItems['tetanus']?.date,
        tetanusDone: _careItems['tetanus']?.done ?? false,
        stranglesDate: _careItems['strangles']?.date,
        stranglesDone: _careItems['strangles']?.done ?? false,
        eqHerpesDate: _careItems['eq_herpes']?.date,
        eqHerpesDone: _careItems['eq_herpes']?.done ?? false,
        rotavirusDate: _careItems['rotavirus']?.date,
        rotavirusDone: _careItems['rotavirus']?.done ?? false,
        hendraDate: _careItems['hendra']?.date,
        hendraDone: _careItems['hendra']?.done ?? false,
        eqInfluenzaDate: _careItems['eq_influenza']?.date,
        eqInfluenzaDone: _careItems['eq_influenza']?.done ?? false,
        eeeWeeWnvDate: _careItems['eee_wee_wnv']?.date,
        eeeWeeWnvDone: _careItems['eee_wee_wnv']?.done ?? false,
        rabiesDate: _careItems['rabies']?.date,
        rabiesDone: _careItems['rabies']?.done ?? false,
        createdAt: DateTime.now(),
      );

      await repo.savePreventativeCare(record);
      ref.invalidate(preventativeCareProvider((ownerType: 'foal', ownerId: widget.foalId)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foal preventative care saved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving care record: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildVaccineRow(String key) {
    final item = _careItems[key]!;
    final damDateStr = _getDamCareDateString(key);

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
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold),
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: item.done,
                activeColor: AppColors.primaryGold,
                checkColor: AppColors.background,
                onChanged: (val) {
                  setState(() {
                    _careItems[key] = (date: item.date, done: val ?? false, label: item.label, interval: item.interval);
                  });
                },
              ),
            ],
          ),
          InkWell(
            onTap: () => _pickDate(key),
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
                  Text(_formatDate(item.date), style: AppTypography.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ref Interval: ${item.interval}',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
          ),
          if (damDateStr != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Mare\'s ${item.label} recorded: $damDateStr',
                style: AppTypography.caption.copyWith(color: AppColors.primaryGold, fontSize: 11),
              ),
            ),
          ],
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
          'FOAL PREVENTATIVE CARE',
          style: AppTypography.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.spaceL),
        child: ResponsiveBody(
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
                child: Text(
                  'All foals require a priming vaccination program for most vaccinations, always consult your Veterinarian for correct schedule and vaccine for your region. Please note the Vaccination Status of the pregnant mare will affect the start date of the priming program.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),

              const SizedBox(height: AppSpacing.spaceL),
              const SectionDividerLabel(label: 'FOAL PRIMING VACCINATIONS', isLeftAligned: true),
              const SizedBox(height: AppSpacing.spaceM),

              ..._careItems.keys.map((k) => _buildVaccineRow(k)),

              const SizedBox(height: AppSpacing.spaceXL),

              GradientCtaButton(
                text: 'SAVE FOAL PREVENTATIVE CARE',
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
