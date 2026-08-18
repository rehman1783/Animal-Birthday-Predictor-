import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';

class CongratulationsScreen extends StatelessWidget {
  final String species;

  const CongratulationsScreen({
    super.key,
    this.species = 'Equine',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.spaceXL),
          child: ResponsiveBody(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                // Animated Sparkle Badge
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 56,
                      color: AppColors.background,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.spaceXL),

                Text(
                  'CONGRATULATIONS!',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primaryGold,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.spaceM),

                Text(
                  'Congratulations on your new arrival!',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.spaceS),

                Text(
                  'Your $species gestation period is complete. Create a new foal record to begin tracking growth and preventative care.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                GradientCtaButton(
                  text: 'REGISTER NEW FOAL RECORD',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/foal-details');
                  },
                ),

                const SizedBox(height: AppSpacing.spaceM),

                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                    ),
                  ),
                  child: Text(
                    'RETURN TO DASHBOARD',
                    style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
