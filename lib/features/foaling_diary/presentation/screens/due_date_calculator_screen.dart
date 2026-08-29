import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../providers/foaling_diary_provider.dart';

class DueDateCalculatorScreen extends ConsumerStatefulWidget {
  const DueDateCalculatorScreen({super.key});

  @override
  ConsumerState<DueDateCalculatorScreen> createState() => _DueDateCalculatorScreenState();
}

class _DueDateCalculatorScreenState extends ConsumerState<DueDateCalculatorScreen> {
  String _selectedSpecies = 'horse'; // horse, dog, cat
  String _selectedMethod = 'natural'; // natural, chilled, frozen, et, icsi
  DateTime _serviceDate = DateTime.now().subtract(const Duration(days: 60));
  final TextEditingController _mareNameController = TextEditingController(text: 'My Mare');
  final TextEditingController _stallionNameController = TextEditingController(text: 'Registered Stallion');
  final TextEditingController _recipientNameController = TextEditingController(text: 'Recipient Mare 01');
  bool _savedToDiary = false;

  @override
  void dispose() {
    _mareNameController.dispose();
    _stallionNameController.dispose();
    _recipientNameController.dispose();
    super.dispose();
  }

  // Pure mathematical calculations based on species and method
  ({
    DateTime dueDate,
    DateTime minDueDate,
    DateTime maxDueDate,
    DateTime scan1Date,
    DateTime scan2Date,
    DateTime scan3Date,
    DateTime closePaddockDate,
    DateTime foalingBarnDate,
    int totalGestationDays,
  }) get _calculatedMilestones {
    if (_selectedSpecies == 'dog') {
      final due = _serviceDate.add(const Duration(days: 63));
      final minDue = _serviceDate.add(const Duration(days: 58));
      final maxDue = _serviceDate.add(const Duration(days: 68));
      final scan1 = _serviceDate.add(const Duration(days: 28));
      final scan2 = _serviceDate.add(const Duration(days: 45));
      final scan3 = _serviceDate.add(const Duration(days: 55));
      return (
        dueDate: due,
        minDueDate: minDue,
        maxDueDate: maxDue,
        scan1Date: scan1,
        scan2Date: scan2,
        scan3Date: scan3,
        closePaddockDate: _serviceDate.add(const Duration(days: 50)),
        foalingBarnDate: _serviceDate.add(const Duration(days: 58)),
        totalGestationDays: 63,
      );
    } else if (_selectedSpecies == 'cat') {
      final due = _serviceDate.add(const Duration(days: 65));
      final minDue = _serviceDate.add(const Duration(days: 60));
      final maxDue = _serviceDate.add(const Duration(days: 70));
      final scan1 = _serviceDate.add(const Duration(days: 25));
      final scan2 = _serviceDate.add(const Duration(days: 45));
      final scan3 = _serviceDate.add(const Duration(days: 55));
      return (
        dueDate: due,
        minDueDate: minDue,
        maxDueDate: maxDue,
        scan1Date: scan1,
        scan2Date: scan2,
        scan3Date: scan3,
        closePaddockDate: _serviceDate.add(const Duration(days: 52)),
        foalingBarnDate: _serviceDate.add(const Duration(days: 60)),
        totalGestationDays: 65,
      );
    }

    // Standard Equine (Horse) calculations
    final isET = _selectedMethod == 'et' || _selectedMethod == 'icsi';
    final int gestationDaysPostTransfer = isET ? 333 : 340;

    final due = _serviceDate.add(Duration(days: gestationDaysPostTransfer));
    final minDue = _serviceDate.add(Duration(days: isET ? 313 : 320));
    final maxDue = _serviceDate.add(Duration(days: isET ? 358 : 365));

    final scan1 = _serviceDate.add(Duration(days: isET ? 7 : 14));
    final scan2 = _serviceDate.add(Duration(days: isET ? 23 : 28));
    final scan3 = _serviceDate.add(Duration(days: isET ? 38 : 45));

    final closePaddock = _serviceDate.add(Duration(days: isET ? 303 : 310));
    final foalingBarn = _serviceDate.add(Duration(days: isET ? 323 : 330));

    return (
      dueDate: due,
      minDueDate: minDue,
      maxDueDate: maxDue,
      scan1Date: scan1,
      scan2Date: scan2,
      scan3Date: scan3,
      closePaddockDate: closePaddock,
      foalingBarnDate: foalingBarn,
      totalGestationDays: 340,
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  int _getDaysRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime.now().subtract(const Duration(days: 400)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _serviceDate = picked;
        _savedToDiary = false;
      });
    }
  }

  Future<void> _saveToDiary() async {
    final mareName = _mareNameController.text.trim().isEmpty ? 'Calculated Mare' : _mareNameController.text.trim();
    final stallionName = _stallionNameController.text.trim().isEmpty ? 'Recorded Stallion' : _stallionNameController.text.trim();
    final isET = _selectedMethod == 'et' || _selectedMethod == 'icsi';

    final entry = await ref.read(calendarDiarySyncServiceProvider).syncFromDueDateCalculator(
      mareName: mareName,
      stallionName: stallionName,
      serviceDate: _serviceDate,
      species: _selectedSpecies,
      method: _selectedMethod,
      recipientName: isET ? _recipientNameController.text.trim() : null,
      donorName: isET ? _mareNameController.text.trim() : null,
    );

    ref.invalidate(foalingDiaryProvider);
    ref.invalidate(calendarTimelineMilestonesProvider);

    setState(() => _savedToDiary = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entry.mareName} synchronized to Foaling Diary & Calendar!'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'View Diary',
            textColor: AppColors.background,
            onPressed: () => Navigator.pushNamed(context, '/foaling-diary'),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final m = _calculatedMilestones;
    final daysRemaining = _getDaysRemaining(m.dueDate);
    final isHorse = _selectedSpecies == 'horse';
    final isET = _selectedMethod == 'et' || _selectedMethod == 'icsi';

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
          isHorse ? 'When Is My Foal Due?' : 'Breeding Due Date Calculator',
          style: AppTypography.displayHeadline.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGold),
            tooltip: 'View Stud Foaling Diary',
            onPressed: () => Navigator.pushNamed(context, '/foaling-diary'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.horizontalPadding),
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Question Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryGold, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHorse ? 'When Is My Foal Due?' : 'Expected Due Date Prediction',
                              style: AppTypography.featureTitle.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Instant, verified calculation for Natural Cover, AI, and Embryo Transfer.',
                              style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Species Selection Chips
                Text('1. Select Species', style: AppTypography.featureTitle.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SpeciesChoiceChip(
                      label: 'Horse (Mare)',
                      icon: Icons.pets,
                      isSelected: _selectedSpecies == 'horse',
                      onSelected: () => setState(() => _selectedSpecies = 'horse'),
                    ),
                    const SizedBox(width: 8),
                    _SpeciesChoiceChip(
                      label: 'Dog (Bitch)',
                      icon: Icons.pets_outlined,
                      isSelected: _selectedSpecies == 'dog',
                      onSelected: () => setState(() => _selectedSpecies = 'dog'),
                    ),
                    const SizedBox(width: 8),
                    _SpeciesChoiceChip(
                      label: 'Cat (Queen)',
                      icon: Icons.pets,
                      isSelected: _selectedSpecies == 'cat',
                      onSelected: () => setState(() => _selectedSpecies = 'cat'),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Breeding Method (Equine Only)
                if (isHorse) ...[
                  Text('2. Breeding Method & Conception Type', style: AppTypography.featureTitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _MethodChip(
                          label: 'Natural Cover',
                          isSelected: _selectedMethod == 'natural',
                          onSelected: () => setState(() => _selectedMethod = 'natural'),
                        ),
                        const SizedBox(width: 8),
                        _MethodChip(
                          label: 'AI (Chilled Semen)',
                          isSelected: _selectedMethod == 'chilled',
                          onSelected: () => setState(() => _selectedMethod = 'chilled'),
                        ),
                        const SizedBox(width: 8),
                        _MethodChip(
                          label: 'AI (Frozen Semen)',
                          isSelected: _selectedMethod == 'frozen',
                          onSelected: () => setState(() => _selectedMethod = 'frozen'),
                        ),
                        const SizedBox(width: 8),
                        _MethodChip(
                          label: 'Embryo Transfer (ET)',
                          isSelected: _selectedMethod == 'et',
                          onSelected: () => setState(() => _selectedMethod = 'et'),
                        ),
                        const SizedBox(width: 8),
                        _MethodChip(
                          label: 'ICSI',
                          isSelected: _selectedMethod == 'icsi',
                          onSelected: () => setState(() => _selectedMethod = 'icsi'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Date Selection Card
                Text(
                  isET ? '3. Recipient Transfer Date' : '3. Service / Cover / Ovulation Date',
                  style: AppTypography.featureTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.event_available_rounded, color: AppColors.primaryGold, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isET ? 'ET Transfer Date' : 'Service / Cover Date',
                                      style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDate(_serviceDate),
                                      style: AppTypography.inputText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Change Date',
                            style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- PROMINENT RESULT CARD ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        isHorse ? 'EXPECTED FOALING DUE DATE' : (isHorse ? 'FOALING' : (_selectedSpecies == 'dog' ? 'WHELPING' : 'QUEENING')) + ' DUE DATE',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(m.dueDate),
                        style: AppTypography.displayHeadline.copyWith(
                          fontSize: 32,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: daysRemaining < 0
                              ? AppColors.error.withValues(alpha: 0.2)
                              : (daysRemaining <= 14 ? AppColors.warning.withValues(alpha: 0.2) : AppColors.success.withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: daysRemaining < 0
                                ? AppColors.error
                                : (daysRemaining <= 14 ? AppColors.warning : AppColors.success),
                          ),
                        ),
                        child: Text(
                          daysRemaining < 0
                              ? '🚨 OVERDUE BY ${daysRemaining.abs()} DAYS'
                              : (daysRemaining == 0 ? '🎉 DUE TODAY!' : '⏳ $daysRemaining DAYS REMAINING'),
                          style: TextStyle(
                            color: daysRemaining < 0
                                ? AppColors.error
                                : (daysRemaining <= 14 ? AppColors.warning : AppColors.success),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.inputBorder, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('EARLIEST VIABLE', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(_formatDate(m.minDueDate), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 24, color: AppColors.inputBorder),
                          Expanded(
                            child: Column(
                              children: [
                                const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('STANDARD (340d)', style: TextStyle(color: AppColors.primaryGold, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(_formatDate(m.dueDate), style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 24, color: AppColors.inputBorder),
                          Expanded(
                            child: Column(
                              children: [
                                const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('LATEST VIABLE', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(_formatDate(m.maxDueDate), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Milestones Timeline
                Text('Key Milestones & Paddock Movements', style: AppTypography.featureTitle.copyWith(fontSize: 15)),
                const SizedBox(height: 12),

                if (isHorse) ...[
                  _MilestoneCard(
                    dayLabel: isET ? 'Day 7 post-transfer' : 'Day 14–16',
                    dateStr: _formatDate(m.scan1Date),
                    title: '1st Ultrasound Scan (Crucial Twin Check)',
                    description: 'Confirm vesicle and check for twins before Day 16 fixation.',
                    isWarning: true,
                    icon: Icons.monitor_heart_outlined,
                  ),
                  _MilestoneCard(
                    dayLabel: isET ? 'Day 23 post-transfer' : 'Day 28–30',
                    dateStr: _formatDate(m.scan2Date),
                    title: '2nd Ultrasound Scan (Heartbeat Check)',
                    description: 'Verify active embryo heartbeat and normal sac growth.',
                    icon: Icons.favorite_border_rounded,
                  ),
                  _MilestoneCard(
                    dayLabel: isET ? 'Day 38 post-transfer' : 'Day 45',
                    dateStr: _formatDate(m.scan3Date),
                    title: '3rd Ultrasound Scan (45-Day Certificate)',
                    description: 'Final confirmation of fetal viability for commercial breeding certificates.',
                    icon: Icons.verified_outlined,
                  ),
                  _MilestoneCard(
                    dayLabel: isET ? 'Day 303 (30d before)' : 'Day 310 (30d before)',
                    dateStr: _formatDate(m.closePaddockDate),
                    title: 'Move to Close Monitoring Paddock',
                    description: 'Transfer mare closer for daily udder monitoring and pre-foaling 5-in-1 vaccine.',
                    icon: Icons.grass_rounded,
                  ),
                  _MilestoneCard(
                    dayLabel: isET ? 'Day 323 (10d before)' : 'Day 330 (10d before)',
                    dateStr: _formatDate(m.foalingBarnDate),
                    title: 'Move into Foaling Barn / Box',
                    description: '24/7 camera/sensor watch, check milk calcium levels, watch for waxing.',
                    icon: Icons.night_shelter_outlined,
                  ),
                ] else ...[
                  _MilestoneCard(
                    dayLabel: 'Day 28',
                    dateStr: _formatDate(m.scan1Date),
                    title: 'Ultrasound Pregnancy Confirmation',
                    description: 'Detect gestational sacs and confirm litter viability.',
                    icon: Icons.monitor_heart_outlined,
                  ),
                  _MilestoneCard(
                    dayLabel: 'Day 50',
                    dateStr: _formatDate(m.closePaddockDate),
                    title: 'Nesting Area Preparation',
                    description: 'Introduce whelping/queening box with warming pad and quiet environment.',
                    icon: Icons.home_outlined,
                  ),
                ],

                const SizedBox(height: 24),

                // Save to Stud Diary CTA
                GradientCtaButton(
                  text: _savedToDiary ? 'Saved to Stud Foaling Diary ✓' : 'Save Record to Stud Foaling Diary',
                  onPressed: _saveToDiary,
                ),

                const SizedBox(height: 12),

                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/foaling-diary'),
                    icon: const Icon(Icons.calendar_view_month_rounded, color: AppColors.primaryGold),
                    label: const Text(
                      'Open Full Stud Foaling Diary (20–100 Mares)',
                      style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeciesChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SpeciesChoiceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGold : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryGold : AppColors.inputBorder,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? AppColors.background : AppColors.primaryGold),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.background : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _MethodChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.background : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryGold,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primaryGold : AppColors.inputBorder,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final String dayLabel;
  final String dateStr;
  final String title;
  final String description;
  final IconData icon;
  final bool isWarning;

  const _MilestoneCard({
    required this.dayLabel,
    required this.dateStr,
    required this.title,
    required this.description,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning ? AppColors.warning : AppColors.inputBorder,
          width: isWarning ? 1.2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWarning
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.primaryGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isWarning ? AppColors.warning : AppColors.primaryGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.inputText.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dateStr,
                        style: const TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$dayLabel • $description',
                  style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
