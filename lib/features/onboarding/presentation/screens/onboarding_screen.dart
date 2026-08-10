import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../../core/widgets/feature_list_item.dart';
import '../../../../core/widgets/trust_card.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Image & Header Overlay
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 340.0,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                  ),
                  child: Image.asset(
                    'assets/images/onboarding_hero.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.pets,
                          color: AppColors.primaryGold,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  width: double.infinity,
                  height: 340.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.4),
                        AppColors.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Top Content OVER Hero
                Positioned(
                  left: AppSpacing.horizontalPadding,
                  right: AppSpacing.horizontalPadding,
                  bottom: 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pill Badge: PREMIUM BREEDER TOOLS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.primaryGold,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PREMIUM BREEDER TOOLS',
                              style: AppTypography.sectionLabel.copyWith(
                                fontSize: 10.0,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Title: "Animal BirthDay\nPredictor"
                      const Text(
                        'Animal BirthDay\nPredictor',
                        style: AppTypography.displayHeadline,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Body Content Padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  // Subtitle
                  const Text(
                    'Tired of sleepless nights, worry and uncertainty? Let ABP take the guesswork out and give you peace of mind.',
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Section Divider Label: WHY ABP?
                  const SectionDividerLabel(label: 'WHY ABP?'),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Feature 1: Precision Tracking
                  const FeatureListItem(
                    icon: Icons.gps_fixed,
                    title: 'Precision Tracking',
                    description:
                        'ABP is a must-have tool for every serious breeder, stud, hobbyist, and veterinarian. From one to 1,000 foalings, accurately predict dates and minimize nightly wake-ups.',
                  ),

                  // Feature 2: Stay Prepared
                  const FeatureListItem(
                    icon: Icons.event_available,
                    title: 'Stay Prepared',
                    description:
                        'Be organized and prepared with built-in reminders, calendar synchronization, and contacts management. Never miss a critical moment.',
                  ),

                  // Feature 3: Instant Documentation
                  const FeatureListItem(
                    icon: Icons.photo_camera_outlined,
                    title: 'Instant Documentation',
                    description:
                        'Seamlessly follow up with a foal photo and detailed information with just one click. Keep your records pristine and professional.',
                  ),

                  const SizedBox(height: 8.0),

                  // TrustCard
                  const TrustCard(),

                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Primary CTA Button: Get Started ->
                  GradientCtaButton(
                    text: 'Get Started',
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.background,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                  ),

                  const SizedBox(height: 24.0),

                  // Footer caption: JOIN THE ELITE NETWORK OF BREEDERS
                  const Center(
                    child: Text(
                      'JOIN THE ELITE NETWORK OF BREEDERS',
                      style: AppTypography.finePrint,
                    ),
                  ),

                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
