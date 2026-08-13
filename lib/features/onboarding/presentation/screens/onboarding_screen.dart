import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/feature_list_item.dart';
import '../../../../core/widgets/trust_card.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ResponsiveBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Image Graphic Header
              Image.asset(
                'assets/images/onboarding_hero_full_header.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 300, color: AppColors.surface),
              ),

              // 2. Body Section below Hero
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),

                    // Section Header: WHY ABP?
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 2,
                          color: const Color(0xFFE5C158),
                        ),
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Text(
                            'WHY ABP?',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE5C158),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),

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

                    // TrustCard Graphic
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
                      onPressed: () async {
                        await ref.read(onboardingProvider.notifier).completeOnboarding();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/signup');
                        }
                      },
                    ),

                    const SizedBox(height: 24.0),

                    // Footer caption
                    const Center(
                      child: Text(
                        'JOIN THE ELITE NETWORK OF BREEDERS',
                        textAlign: TextAlign.center,
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
      ),
    );
  }
}
