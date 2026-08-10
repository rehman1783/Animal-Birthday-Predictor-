import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gradient_cta_button.dart';

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'ABP Dashboard (Mock)',
          style: TextStyle(color: AppColors.primaryGold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.primaryGold,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to ABP!',
              style: AppTypography.displayHeadline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Milestone 1, Part A UI layer complete!\n(Supabase integration pending in next milestone step)',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            GradientCtaButton(
              text: 'Return to Onboarding Demo',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/onboarding');
              },
            ),
          ],
        ),
      ),
    );
  }
}
