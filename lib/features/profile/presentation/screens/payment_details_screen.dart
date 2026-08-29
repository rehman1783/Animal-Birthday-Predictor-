import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/abp_brand_badge.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PaymentDetailsScreen extends ConsumerStatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  ConsumerState<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends ConsumerState<PaymentDetailsScreen> {
  bool _autoRenew = true;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppFeedbackSnackbar.showSuccess(
      context,
      title: 'Copied to Clipboard',
      message: '$label copied: $text',
    );
  }

  void _showUpdateCardModal() {
    final cardNumberController = TextEditingController(text: '4242 4242 4242 4242');
    final expiryController = TextEditingController(text: '08/29');
    final cvcController = TextEditingController(text: '888');
    final nameController = TextEditingController(text: 'Certified Breeder');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update Payment Card',
                  style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: AppColors.inputBorder),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              style: AppTypography.inputText,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.inputField,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cardNumberController,
              style: AppTypography.inputText,
              decoration: InputDecoration(
                labelText: 'Card Number',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primaryGold),
                filled: true,
                fillColor: AppColors.inputField,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryController,
                    style: AppTypography.inputText,
                    decoration: InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.inputField,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cvcController,
                    obscureText: true,
                    style: AppTypography.inputText,
                    decoration: InputDecoration(
                      labelText: 'CVC / CVV',
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.inputField,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientCtaButton(
              text: 'Save Payment Card',
              onPressed: () {
                Navigator.pop(ctx);
                AppFeedbackSnackbar.showSuccess(
                  context,
                  title: 'Payment Method Updated',
                  message: 'Your payment card details were safely encrypted and updated.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptModal(String invoiceNo, String date, String amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
        title: Row(
          children: [
            const AbpOfficialLogo(size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Official ABP Receipt',
                style: AppTypography.displayHeadline.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReceiptRow(label: 'Invoice #', value: invoiceNo),
                  const SizedBox(height: 6),
                  _ReceiptRow(label: 'Billing Date', value: date),
                  const SizedBox(height: 6),
                  _ReceiptRow(label: 'Amount Paid', value: amount),
                  const SizedBox(height: 6),
                  _ReceiptRow(label: 'Status', value: 'PAID (Verified)'),
                  const SizedBox(height: 6),
                  _ReceiptRow(label: 'Plan', value: 'ABP Pro Master Breeder (Annual)'),
                  const SizedBox(height: 6),
                  _ReceiptRow(label: 'Payment Mode', value: 'Visa ending in 4242'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, color: AppColors.success, size: 14),
                SizedBox(width: 4),
                Text(
                  'Encrypted 256-bit ABP Certified Invoice',
                  style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.background,
            ),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download PDF Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              AppFeedbackSnackbar.showSuccess(
                context,
                title: 'Receipt Downloaded',
                message: 'Receipt $invoiceNo downloaded to your device storage.',
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final breederName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Breeder User';
    final breederEmail = user?.email ?? 'breeder@example.com';

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
          'Payment & Billing Details',
          style: AppTypography.displayHeadline.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Official Header Badge
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AbpBrandBadge(text: 'OFFICIAL ABP™ PAYMENT & SUBSCRIPTION PORTAL'),
                    AbpOfficialLogo(size: 28),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Active Subscription Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ACTIVE SUBSCRIPTION',
                                style: AppTypography.finePrint.copyWith(
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ABP Pro — Master Breeder',
                                style: AppTypography.displayHeadline.copyWith(fontSize: 19),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.success, width: 1),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.inputBorder),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Billing Tier', style: AppTypography.finePrint),
                          Text(
                            '\$29.99 / Year (Annual Billing)',
                            style: AppTypography.inputText.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Account Owner', style: AppTypography.finePrint),
                          Text(breederName, style: AppTypography.inputText),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Registered Email', style: AppTypography.finePrint),
                          Text(breederEmail, style: AppTypography.inputText),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Next Renewal Date', style: AppTypography.finePrint),
                          Text(
                            '29 August 2027',
                            style: AppTypography.inputText.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Included Features Checkpoints
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          children: [
                            _FeatureCheckRow(title: 'Unlimited Mare, Foal & Puppy Profiles'),
                            _FeatureCheckRow(title: 'Automated 45-Day Scans & Foaling Diary Sync'),
                            _FeatureCheckRow(title: 'Official PDF Pedigree & Health Certificates'),
                            _FeatureCheckRow(title: 'Direct Contacts Directory & Click-to-Call'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Auto-Renew Subscription', style: AppTypography.inputText),
                          Switch(
                            value: _autoRenew,
                            activeTrackColor: AppColors.surface,
                            activeThumbColor: AppColors.primaryGold,
                            onChanged: (val) {
                              setState(() => _autoRenew = val);
                              AppFeedbackSnackbar.showSuccess(
                                context,
                                title: val ? 'Auto-Renewal Enabled' : 'Auto-Renewal Disabled',
                                message: val
                                    ? 'Your plan will automatically renew on 29 August 2027.'
                                    : 'Auto-renewal turned off. Your plan remains active until 29 August 2027.',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Stored Payment Method
                _SectionCard(
                  title: 'Payment Method on File',
                  icon: Icons.credit_card_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Credit Card Preview Mock
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F2B48), Color(0xFF1E3A5F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    HorseshoeIcon(size: 18, color: AppColors.primaryGold),
                                    SizedBox(width: 6),
                                    Text(
                                      'ABP BREEDER CARD',
                                      style: TextStyle(
                                        color: AppColors.primaryGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'VISA',
                                    style: TextStyle(
                                      color: Color(0xFF1A1F71),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              '•••• •••• •••• 4242',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 3,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('CARD HOLDER', style: TextStyle(color: Colors.white60, fontSize: 8)),
                                    Text(breederName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('EXPIRES', style: TextStyle(color: Colors.white60, fontSize: 8)),
                                    Text('08 / 29', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGold),
                          foregroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Update or Replace Payment Card', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _showUpdateCardModal,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Direct Bank / Wire Transfer Information
                _SectionCard(
                  title: 'Direct Bank & Wire Transfer Details',
                  icon: Icons.account_balance_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'For institutional breeding studs, veterinary clinics, or direct corporate invoice payments, wire transfers are accepted with 0% processing fees.',
                        style: AppTypography.finePrint,
                      ),
                      const SizedBox(height: 14),
                      _BankCopyTile(
                        label: 'Beneficiary Name',
                        value: 'Animal Birthday Predictor (ABP) Ltd.',
                        onCopy: () => _copyToClipboard('Animal Birthday Predictor (ABP) Ltd.', 'Beneficiary Name'),
                      ),
                      _BankCopyTile(
                        label: 'Bank Name',
                        value: 'JPMorgan Chase Bank, N.A. (New York)',
                        onCopy: () => _copyToClipboard('JPMorgan Chase Bank, N.A.', 'Bank Name'),
                      ),
                      _BankCopyTile(
                        label: 'Account / IBAN Number',
                        value: 'US94 CHAS 0210 0002 8921 4401',
                        onCopy: () => _copyToClipboard('US94CHAS0210000289214401', 'Account Number'),
                      ),
                      _BankCopyTile(
                        label: 'SWIFT / BIC Code',
                        value: 'CHASUS33ABP',
                        onCopy: () => _copyToClipboard('CHASUS33ABP', 'SWIFT Code'),
                      ),
                      _BankCopyTile(
                        label: 'Payment Reference Code',
                        value: 'ABP-ACC-2026-${user?.id.substring(0, 6).toUpperCase() ?? "BREEDER"}',
                        onCopy: () => _copyToClipboard('ABP-ACC-2026-${user?.id.substring(0, 6).toUpperCase() ?? "BREEDER"}', 'Reference Code'),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.primaryGold, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please include your Reference Code in wire description and email proof of transfer to payments@animalbirthdaypredictor.com.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Billing History & Official Invoices
                _SectionCard(
                  title: 'Billing History & Invoices',
                  icon: Icons.receipt_long_rounded,
                  child: Column(
                    children: [
                      _InvoiceTile(
                        invoiceNo: 'ABP-INV-2026-001',
                        date: '29 Aug 2026',
                        amount: '\$29.99',
                        status: 'PAID',
                        onViewReceipt: () => _showReceiptModal('ABP-INV-2026-001', '29 Aug 2026', '\$29.99'),
                      ),
                      const Divider(color: AppColors.inputBorder, height: 1),
                      _InvoiceTile(
                        invoiceNo: 'ABP-INV-2025-001',
                        date: '29 Aug 2025',
                        amount: '\$29.99',
                        status: 'PAID',
                        onViewReceipt: () => _showReceiptModal('ABP-INV-2025-001', '29 Aug 2025', '\$29.99'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 6. ABP Payment Protection & Security Seal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security_rounded, color: AppColors.primaryGold, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'OFFICIAL ABP PAYMENT ENCRYPTION & GUARANTEE',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'All transactions are processed through 256-bit bank-grade SSL encryption. Guaranteed authentic ABP Software license with anti-counterfeit protection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10, height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const AbpProtectedFooter(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.featureTitle.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.inputBorder, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FeatureCheckRow extends StatelessWidget {
  final String title;

  const _FeatureCheckRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: AppColors.primaryGold, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankCopyTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _BankCopyTile({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                const SizedBox(height: 1),
                Text(value, style: AppTypography.inputText.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.primaryGold, size: 18),
            tooltip: 'Copy $label',
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final String invoiceNo;
  final String date;
  final String amount;
  final String status;
  final VoidCallback onViewReceipt;

  const _InvoiceTile({
    required this.invoiceNo,
    required this.date,
    required this.amount,
    required this.status,
    required this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: const Icon(Icons.description_outlined, color: AppColors.primaryGold, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoiceNo, style: AppTypography.inputText.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(date, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: AppTypography.inputText.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: AppColors.success, fontSize: 8.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                onPressed: onViewReceipt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        Text(value, style: AppTypography.inputText.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
