import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../domain/preventative_care_record.dart';
import '../providers/preventative_care_provider.dart';

class MarePreventativeCareScreen extends ConsumerStatefulWidget {
  final String mareId;

  const MarePreventativeCareScreen({super.key, required this.mareId});

  @override
  ConsumerState<MarePreventativeCareScreen> createState() => _MarePreventativeCareScreenState();
}

class _MarePreventativeCareScreenState extends ConsumerState<MarePreventativeCareScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dentistPhoneController = TextEditingController();
  final _farrierPhoneController = TextEditingController();

  final Map<String, ({DateTime? date, bool done, String label, String interval})> _careItems = {
    'wormer': (date: null, done: false, label: 'Wormer', interval: 'Every 6-8 weeks'),
    'tetanus': (date: null, done: false, label: 'Tetanus Toxoid', interval: 'Annual / Pre-foaling 4 weeks'),
    'strangles': (date: null, done: false, label: 'Strangles', interval: 'Annual booster'),
    'eq_herpes': (date: null, done: false, label: 'Equine Herpes Virus (EHV-1/4)', interval: '5, 7 & 9 months gestation'),
    'rotavirus': (date: null, done: false, label: 'Rotavirus', interval: '8, 9 & 10 months gestation'),
    'hendra': (date: null, done: false, label: 'Hendra Virus (AUS)', interval: '6-month booster'),
    'eq_influenza': (date: null, done: false, label: 'EQ Influenza (EU & UK)', interval: 'Annual booster'),
    'eee_wee_wnv': (date: null, done: false, label: 'EEE / WEE / WNV (USA)', interval: 'Annual booster'),
    'rabies': (date: null, done: false, label: 'Rabies (USA)', interval: 'Annual booster'),
  };

  DateTime? _dentalDate;
  bool _dentalDone = false;

  DateTime? _farrierDate;
  bool _farrierDone = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(preventativeCareRepositoryProvider);
    final record = await repo.getPreventativeCare('mare', widget.mareId);
    if (record != null && mounted) {
      setState(() {
        _careItems['wormer'] = (date: record.wormerDate, done: record.wormerDone, label: 'Wormer', interval: 'Every 6-8 weeks');
        _careItems['tetanus'] = (date: record.tetanusDate, done: record.tetanusDone, label: 'Tetanus Toxoid', interval: 'Annual / Pre-foaling 4 weeks');
        _careItems['strangles'] = (date: record.stranglesDate, done: record.stranglesDone, label: 'Strangles', interval: 'Annual booster');
        _careItems['eq_herpes'] = (date: record.eqHerpesDate, done: record.eqHerpesDone, label: 'Equine Herpes Virus (EHV-1/4)', interval: '5, 7 & 9 months gestation');
        _careItems['rotavirus'] = (date: record.rotavirusDate, done: record.rotavirusDone, label: 'Rotavirus', interval: '8, 9 & 10 months gestation');
        _careItems['hendra'] = (date: record.hendraDate, done: record.hendraDone, label: 'Hendra Virus (AUS)', interval: '6-month booster');
        _careItems['eq_influenza'] = (date: record.eqInfluenzaDate, done: record.eqInfluenzaDone, label: 'EQ Influenza (EU & UK)', interval: 'Annual booster');
        _careItems['eee_wee_wnv'] = (date: record.eeeWeeWnvDate, done: record.eeeWeeWnvDone, label: 'EEE / WEE / WNV (USA)', interval: 'Annual booster');
        _careItems['rabies'] = (date: record.rabiesDate, done: record.rabiesDone, label: 'Rabies (USA)', interval: 'Annual booster');

        _dentalDate = record.dentalDate;
        _dentalDone = record.dentalDone;
        _dentistPhoneController.text = record.dentistNumber ?? '';

        _farrierDate = record.farrierDate;
        _farrierDone = record.farrierDone;
        _farrierPhoneController.text = record.farrierNumber ?? '';
      });
    }
  }

  @override
  void dispose() {
    _dentistPhoneController.dispose();
    _farrierPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String key) async {
    final current = key == 'dental' ? _dentalDate : (key == 'farrier' ? _farrierDate : _careItems[key]?.date);
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
        if (key == 'dental') {
          _dentalDate = picked;
        } else if (key == 'farrier') {
          _farrierDate = picked;
        } else if (_careItems.containsKey(key)) {
          final item = _careItems[key]!;
          _careItems[key] = (date: picked, done: item.done, label: item.label, interval: item.interval);
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Select Date';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _callPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
      final repo = ref.read(preventativeCareRepositoryProvider);
      final record = PreventativeCareRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerType: 'mare',
        ownerId: widget.mareId,
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
        dentalDate: _dentalDate,
        dentalDone: _dentalDone,
        dentistNumber: _dentistPhoneController.text.trim(),
        farrierDate: _farrierDate,
        farrierDone: _farrierDone,
        farrierNumber: _farrierPhoneController.text.trim(),
        createdAt: DateTime.now(),
      );

      await repo.savePreventativeCare(record);
      ref.invalidate(preventativeCareProvider((ownerType: 'mare', ownerId: widget.mareId)));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mare preventative care saved!')),
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
          'PREVENTATIVE CARE — MARE',
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
                const SectionDividerLabel(label: 'VACCINATIONS & WORMER', isLeftAligned: true),
                const SizedBox(height: AppSpacing.spaceM),

                ..._careItems.keys.map((k) => _buildVaccineRow(k)),

                const SizedBox(height: AppSpacing.spaceL),
                const SectionDividerLabel(label: 'DENTISTRY & FARRIER', isLeftAligned: true),
                const SizedBox(height: AppSpacing.spaceM),

                // Dentistry Card
                Container(
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
                            child: Text('Dental Checkup', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
                          ),
                          Checkbox(
                            value: _dentalDone,
                            activeColor: AppColors.primaryGold,
                            checkColor: AppColors.background,
                            onChanged: (v) => setState(() => _dentalDone = v ?? false),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => _pickDate('dental'),
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
                              Text(_formatDate(_dentalDate), style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceM),
                      CustomTextField(
                        controller: _dentistPhoneController,
                        label: 'Dentist Phone Number *',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Dentist phone number is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.spaceS),
                      if (_dentistPhoneController.text.trim().isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _callPhone(_dentistPhoneController.text.trim()),
                          icon: const Icon(Icons.call, color: AppColors.background),
                          label: Text(
                            'CALL DENTIST (${_dentistPhoneController.text.trim()})',
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        )
                      else
                        Text('No Dentist Number Added', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceM),

                // Farrier Card
                Container(
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
                            child: Text('Farrier Service', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold)),
                          ),
                          Checkbox(
                            value: _farrierDone,
                            activeColor: AppColors.primaryGold,
                            checkColor: AppColors.background,
                            onChanged: (v) => setState(() => _farrierDone = v ?? false),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => _pickDate('farrier'),
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
                              Text(_formatDate(_farrierDate), style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceM),
                      CustomTextField(
                        controller: _farrierPhoneController,
                        label: 'Farrier Phone Number *',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Farrier phone number is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.spaceS),
                      if (_farrierPhoneController.text.trim().isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _callPhone(_farrierPhoneController.text.trim()),
                          icon: const Icon(Icons.call, color: AppColors.background),
                          label: Text(
                            'CALL FARRIER (${_farrierPhoneController.text.trim()})',
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        )
                      else
                        Text('No Farrier Number Added', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceXL),

                GradientCtaButton(
                  text: 'SAVE PREVENTATIVE CARE',
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
