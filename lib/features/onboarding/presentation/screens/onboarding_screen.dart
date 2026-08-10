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
            // 1. Full Hero Section with Background Photo
            Stack(
              children: [
                // Background Photo of Mare & Foal (520px height)
                Container(
                  width: double.infinity,
                  height: 500.0,
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
                // Smooth Bottom Transition Gradient into Dark Navy #0A192F
                Container(
                  width: double.infinity,
                  height: 500.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.8),
                        AppColors.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4, 0.85, 1.0],
                    ),
                  ),
                ),
                // Header Content Positioned over Hero Photo
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                      vertical: 36.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill Badge: PREMIUM BREEDER TOOLS
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(alpha: 0.8),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'PREMIUM BREEDER TOOLS',
                            style: AppTypography.sectionLabel.copyWith(
                              fontSize: 10.0,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Title: "Animal BirthDay\nPredictor"
                        Text(
                          'Animal BirthDay\nPredictor',
                          style: AppTypography.displayHeadline.copyWith(
                            fontSize: 32.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Subtitle
                        Text(
                          'Tired of sleepless nights, worry and uncertainty? Let ABP take the guesswork out and give you peace of mind.',
                          style: AppTypography.subtitle.copyWith(
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.9),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Body Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),

                  // Section Divider Label: — WHY ABP?
                  const SectionDividerLabel(
                    label: 'WHY ABP?',
                    isLeftAligned: true,
                  ),
                  const SizedBox(height: 28.0),

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

                  const SizedBox(height: 12.0),

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
