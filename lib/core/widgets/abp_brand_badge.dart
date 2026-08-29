import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import 'horseshoe_icon.dart';

/// Official ABP Crest Logo with luxury gold border and branding
class AbpOfficialLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showBadge;

  const AbpOfficialLogo({
    super.key,
    this.size = 44,
    this.showText = false,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGold, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/abp_official_logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surface,
                child: Center(
                  child: HorseshoeIcon(
                    size: size * 0.55,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!showText && !showBadge) {
      return logoWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoWidget,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ABP',
                  style: AppTypography.displayHeadline.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryGold,
                    letterSpacing: 1.5,
                  ),
                ),
                if (showBadge) ...[
                  const SizedBox(width: 6),
                  const AbpBrandBadge(text: 'ORIGINAL'),
                ],
              ],
            ),
            const Text(
              'ANIMAL BIRTHDAY PREDICTOR',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact verified badge: "OFFICIAL ABP™ PRODUCT" / "VERIFIED"
class AbpBrandBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AbpBrandBadge({
    super.key,
    this.text = 'OFFICIAL ABP™ PRODUCT',
    this.backgroundColor,
    this.textColor,
    this.icon = Icons.verified_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (textColor ?? AppColors.primaryGold).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: textColor ?? AppColors.primaryGold,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: textColor ?? AppColors.primaryGold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative watermark seal for detail cards and screens to prevent copying
class AbpWatermarkSeal extends StatelessWidget {
  final String label;
  final double size;

  const AbpWatermarkSeal({
    super.key,
    this.label = 'ABP VERIFIED REGISTRY',
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.08,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryGold, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HorseshoeIcon(size: 28, color: AppColors.primaryGold),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standardized footer stamp: "Official ABP™ • Proprietary Breeding & Gestation Technology"
class AbpProtectedFooter extends StatelessWidget {
  final bool isCompact;

  const AbpProtectedFooter({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 12 : 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HorseshoeIcon(size: 14, color: AppColors.primaryGold),
              const SizedBox(width: 6),
              Text(
                'ANIMAL BIRTHDAY PREDICTOR (ABP)™',
                style: AppTypography.finePrint.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Official ABP Product • Proprietary Breeding & Gestation Engine\nAll Rights Reserved © 2026 ABP Ltd.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
