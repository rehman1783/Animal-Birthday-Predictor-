import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../data/certificate_quota_service.dart';

class PurchaseCertificatesDialog extends ConsumerStatefulWidget {
  final VoidCallback? onPurchased;

  const PurchaseCertificatesDialog({super.key, this.onPurchased});

  static Future<bool?> show(BuildContext context, {VoidCallback? onPurchased}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PurchaseCertificatesDialog(onPurchased: onPurchased),
    );
  }

  @override
  ConsumerState<PurchaseCertificatesDialog> createState() =>
      _PurchaseCertificatesDialogState();
}

class _PurchaseCertificatesDialogState
    extends ConsumerState<PurchaseCertificatesDialog> {
  int _selectedPackIndex = 1; // Default to 5-Pack (Best Value)
  bool _isProcessing = false;

  final List<({String title, int count, String price, String perUnit, bool isPopular})> _packs = const [
    (
      title: 'Single Certificate Pass',
      count: 1,
      price: '\$4.99',
      perUnit: '\$4.99 / cert',
      isPopular: false,
    ),
    (
      title: '5-Pack Foal & Litter Bundle',
      count: 5,
      price: '\$19.99',
      perUnit: '\$3.99 / cert (Save 20%)',
      isPopular: true,
    ),
    (
      title: 'Commercial Stud 20-Pack',
      count: 20,
      price: '\$59.99',
      perUnit: '\$2.99 / cert (Save 40%)',
      isPopular: false,
    ),
  ];

  Future<void> _handlePurchase() async {
    setState(() => _isProcessing = true);
    final pack = _packs[_selectedPackIndex];

    try {
      // In production, this invokes in_app_purchase / StoreKit / Google Play Billing
      await ref
          .read(certificateQuotaProvider.notifier)
          .purchaseCertificateCredits(pack.count);

      if (!mounted) return;

      AppFeedbackSnackbar.showSuccess(
        context,
        title: 'Certificates Added',
        message: 'Successfully added ${pack.count} certificate credit${pack.count > 1 ? "s" : ""} to your account.',
      );

      widget.onPurchased?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      AppFeedbackSnackbar.showError(
        context,
        title: 'Transaction Failed',
        error: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.6), width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon & Header
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B192E),
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                ),
                child: const Center(
                  child: HorseshoeIcon(size: 26, color: AppColors.primaryGold),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'CERTIFICATE QUOTA LIMIT',
                style: AppTypography.displayHeadline.copyWith(
                  fontSize: 17,
                  color: AppColors.primaryGold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              Text(
                'You have utilized all certificates entitled to your account. Select a certificate package to generate and print official pedigree certificates for this animal:',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // 2. Package Options
              for (int i = 0; i < _packs.length; i++) ...[
                _buildPackTile(i, _packs[i]),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 14),

              // 3. Purchase Action
              GradientCtaButton(
                text: _isProcessing
                    ? 'PROCESSING...'
                    : 'PURCHASE ${_packs[_selectedPackIndex].count} CERTIFICATE${_packs[_selectedPackIndex].count > 1 ? "S" : ""} • ${_packs[_selectedPackIndex].price}',
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : _handlePurchase,
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackTile(int index, ({String title, int count, String price, String perUnit, bool isPopular}) pack) {
    final isSelected = _selectedPackIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedPackIndex = index),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F2648) : AppColors.inputField,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.primaryGold.withValues(alpha: 0.2),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pack.title,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (pack.isPopular) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pack.perUnit,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              pack.price,
              style: TextStyle(
                color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
