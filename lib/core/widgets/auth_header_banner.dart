import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'horseshoe_icon.dart';

/// Professional executive header banner for authentication and account screens.
/// Features the official ABP Gold Crest, professional equine breeding identity,
/// and eliminates all mystical, fantasy, or novelty visual elements.
class AuthHeaderBanner extends StatelessWidget {
  final String? imagePath;
  final double height;
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final String? badgeText;

  const AuthHeaderBanner({
    super.key,
    this.imagePath,
    this.height = 240,
    this.icon,
    this.title,
    this.subtitle,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF060F1E),
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Industry Credibility Pill / Top Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HorseshoeIcon(size: 11, color: AppColors.primaryGold),
                    const SizedBox(width: 6),
                    Text(
                      badgeText ?? 'OFFICIAL EQUINE & LIVESTOCK BREEDING PLATFORM',
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Central Official ABP Logo Badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B192E),
                  border: Border.all(color: AppColors.primaryGold, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/abp_official_logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: HorseshoeIcon(size: 38, color: AppColors.primaryGold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Official Platform Title
              Text(
                title ?? 'ANIMAL BIRTHDAY PREDICTOR',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 4),

              // 4. Subtitle / Purpose
              Text(
                subtitle ?? 'Precision Foaling, Ultrasound Milestones & Official Pedigree Registry',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.0,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // 5. Gold Accent Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 1,
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 1,
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
