import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pregnancy/presentation/providers/pregnancy_provider.dart';
import '../../../animals/domain/animal_type.dart';
import '../../../pregnancy/domain/pregnancy_record.dart';

class DashboardHomeScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const DashboardHomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userProfile = authState.value;
    final pregnancyState = ref.watch(pregnancyListProvider);
    final calculatorState = ref.watch(gestationCalculatorProvider);

    final userName = userProfile?.fullName.isNotEmpty == true
        ? userProfile!.fullName
        : 'Celestial Breeder';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Welcome Greeting Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WELCOME BACK',
                          style: AppTypography.sectionLabel,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: AppTypography.displayHeadline,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGold, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: AppColors.primaryGold,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24.0),

              // 2. Overview Stats Cards Grid
              pregnancyState.when(
                data: (pregnancies) {
                  final activeCount = pregnancies.where((p) => p.status == PregnancyStatus.active || p.status == PregnancyStatus.dueSoon).length;
                  final dueSoonCount = pregnancies.where((p) => p.isDueSoon).length;

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Active Pregnancies',
                          count: '$activeCount',
                          icon: Icons.monitor_heart_outlined,
                          accentColor: AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Due Soon (≤14 days)',
                          count: '$dueSoonCount',
                          icon: Icons.alarm_on_rounded,
                          accentColor: dueSoonCount > 0 ? AppColors.primaryGold : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28.0),

              // 3. Quick Birthday Predictor Card
              const SectionDividerLabel(label: 'QUICK BIRTHDAY PREDICTOR'),
              const SizedBox(height: 16.0),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.inputBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Gestational Date Predictor',
                          style: AppTypography.featureTitle.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Species Selector
                    Text(
                      'Select Animal Species',
                      style: AppTypography.inputLabel.copyWith(color: AppColors.primaryGold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.inputField,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AnimalType>(
                          value: calculatorState.animalType,
                          dropdownColor: AppColors.surface,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGold),
                          items: AnimalType.values.map((type) {
                            return DropdownMenuItem<AnimalType>(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(type.icon, size: 18, color: AppColors.primaryGold),
                                  const SizedBox(width: 10),
                                  Text(
                                    type.displayName,
                                    style: AppTypography.inputText,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newType) {
                            if (newType != null) {
                              ref.read(gestationCalculatorProvider.notifier).updateAnimalType(newType);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Breeding Date Selector
                    Text(
                      'Breeding Date',
                      style: AppTypography.inputLabel.copyWith(color: AppColors.primaryGold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: calculatorState.breedingDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
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
                          ref.read(gestationCalculatorProvider.notifier).updateBreedingDate(picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.inputField,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${calculatorState.breedingDate.day}/${calculatorState.breedingDate.month}/${calculatorState.breedingDate.year}',
                              style: AppTypography.inputText,
                            ),
                            const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGold, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Prediction Outcome Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPECTED ${calculatorState.animalType.birthTerm.toUpperCase()} DATE',
                            style: AppTypography.sectionLabel.copyWith(fontSize: 10),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${calculatorState.expectedDueDate.day} ${_monthName(calculatorState.expectedDueDate.month)} ${calculatorState.expectedDueDate.year}',
                            style: AppTypography.displayHeadline.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestation Window: ${_formatDate(calculatorState.minDueDate)} - ${_formatDate(calculatorState.maxDueDate)} (${calculatorState.animalType.averageGestationDays} days avg)',
                            style: AppTypography.finePrint,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28.0),

              // 4. Active Pregnancies & Countdown List
              const SectionDividerLabel(label: 'UPCOMING PREGNANCIES'),
              const SizedBox(height: 16.0),

              pregnancyState.when(
                data: (pregnancies) {
                  final activeList = pregnancies.where((p) => p.status != PregnancyStatus.delivered).toList();
                  if (activeList.isEmpty) {
                    return _EmptyCard(
                      message: 'No active pregnancies logged yet.',
                      onPressed: () => onNavigateTab?.call(2),
                    );
                  }

                  return Column(
                    children: activeList.map((p) {
                      return _PregnancyCountdownTile(pregnancy: p);
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28.0),

              // 5. Quick Nav Buttons
              Row(
                children: [
                  Expanded(
                    child: GradientCtaButton(
                      text: 'View Animals',
                      icon: const Icon(Icons.pets, color: AppColors.background, size: 18),
                      onPressed: () => onNavigateTab?.call(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientCtaButton(
                      text: 'Pregnancy Log',
                      icon: const Icon(Icons.medical_services_outlined, color: AppColors.background, size: 18),
                      onPressed: () => onNavigateTab?.call(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor, size: 22),
              Text(
                count,
                style: AppTypography.displayHeadline.copyWith(
                  fontSize: 24,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PregnancyCountdownTile extends StatelessWidget {
  final PregnancyRecord pregnancy;

  const _PregnancyCountdownTile({required this.pregnancy});

  @override
  Widget build(BuildContext context) {
    final progress = pregnancy.progressPercentage;
    final daysRemaining = pregnancy.daysRemaining;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: pregnancy.isDueSoon ? AppColors.primaryGold : AppColors.inputBorder,
          width: pregnancy.isDueSoon ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(pregnancy.animalType.icon, color: AppColors.primaryGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    pregnancy.damName,
                    style: AppTypography.featureTitle,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pregnancy.isDueSoon ? AppColors.primaryGold.withValues(alpha: 0.2) : AppColors.inputField,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: pregnancy.isDueSoon ? AppColors.primaryGold : AppColors.inputBorder),
                ),
                child: Text(
                  pregnancy.isDueSoon ? '$daysRemaining Days Left!' : '$daysRemaining days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: pregnancy.isDueSoon ? AppColors.primaryGold : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bred to: ${pregnancy.sireName} • Expected Due: ${pregnancy.expectedDueDate.day}/${pregnancy.expectedDueDate.month}/${pregnancy.expectedDueDate.year}',
            style: AppTypography.body.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.inputField,
              valueColor: AlwaysStoppedAnimation<Color>(
                pregnancy.isDueSoon ? AppColors.primaryGold : AppColors.goldGradientStart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;

  const _EmptyCard({required this.message, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GradientCtaButton(
            text: 'Add Breeding Record',
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
