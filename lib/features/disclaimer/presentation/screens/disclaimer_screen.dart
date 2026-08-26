import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_disclaimer_content.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';

class DisclaimerScreen extends StatelessWidget {
  final bool showAcceptButton;
  final VoidCallback? onAccepted;

  const DisclaimerScreen({
    super.key,
    this.showAcceptButton = false,
    this.onAccepted,
  });

  static Future<bool?> showModal(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context, false),
            ),
            title: const Text('Terms & Disclaimer', style: AppTypography.featureTitle),
          ),
          body: const DisclaimerScreen(),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'medical':
        return Icons.medical_services_outlined;
      case 'clock':
        return Icons.access_time_rounded;
      case 'scan':
        return Icons.monitor_heart_outlined;
      case 'gavel':
        return Icons.gavel_rounded;
      case 'shield':
        return Icons.verified_user_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Disclaimer & Legal Notice',
          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
        ),
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
                // Top Warning Advisory Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined, color: AppColors.primaryGold, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Important Notice for Breeders',
                                  style: AppTypography.featureTitle,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Version ${AppDisclaimerContent.version} • Updated ${AppDisclaimerContent.lastUpdated}',
                                  style: AppTypography.finePrint.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Text(
                          AppDisclaimerContent.shortSummary,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Terms of Medical & Gestation Calculation',
                  style: AppTypography.featureTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Disclaimer Sections
                ...AppDisclaimerContent.sections.map((section) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getIconForType(section.icon), color: AppColors.primaryGold, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                section.title,
                                style: AppTypography.inputText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: AppColors.inputBorder, height: 1),
                        const SizedBox(height: 10),
                        Text(
                          section.content,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.9),
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Bottom Agreement CTA / Return Button
                GradientCtaButton(
                  text: showAcceptButton ? 'I Understand & Agree' : 'Back to Settings',
                  onPressed: () {
                    if (onAccepted != null) {
                      onAccepted!();
                    }
                    Navigator.maybePop(context, true);
                  },
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
