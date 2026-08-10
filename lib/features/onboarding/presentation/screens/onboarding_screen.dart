import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
            // 1. Hero Image Graphic (Contains Photo + Badge + Title + Subtitle from Figma export)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: Image.asset(
                'assets/images/onboarding_hero.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 380,
                  color: AppColors.surface,
                ),
              ),
            ),

            // 2. Body Section below Hero
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

                  // TrustCard Graphic (Contains image + text from Figma export)
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
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
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
