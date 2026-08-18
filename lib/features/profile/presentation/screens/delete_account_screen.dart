import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _passwordError = null;
    });

    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required to confirm account deletion';
      });
      return false;
    }
    return true;
  }

  Future<void> _handleDeleteAccount() async {
    if (!_validateForm()) return;

    // Show final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 10),
            Text('Final Confirmation', style: AppTypography.featureTitle.copyWith(color: AppColors.error)),
          ],
        ),
        content: const Text(
          'Are you absolutely sure? All your animals, pregnancy logs, breeding records, certificates, and credentials will be permanently erased.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
      _passwordError = null;
    });

    final password = _passwordController.text;

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.deleteAccount(password: password);

      if (!mounted) return;

      AppFeedbackSnackbar.showSuccess(
        context,
        title: 'Account Deleted',
        message: 'Your account and all associated data have been permanently deleted.',
        duration: const Duration(seconds: 4),
      );

      // Reset local auth session state cleanly
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e is AuthExceptionCustom
          ? e.message
          : e.toString().replaceAll('Exception: ', '').replaceAll('AuthExceptionCustom: ', '');

      setState(() {
        if (errorMsg.toLowerCase().contains('incorrect password') ||
            errorMsg.toLowerCase().contains('invalid')) {
          _passwordError = 'Incorrect password. Please enter your valid password.';
        } else {
          _passwordError = errorMsg;
        }
      });

      AppFeedbackSnackbar.showError(
        context,
        title: 'Deletion Failed',
        error: errorMsg.toLowerCase().contains('incorrect password') ||
                errorMsg.toLowerCase().contains('invalid')
            ? 'Incorrect password. Please enter your valid password.'
            : errorMsg,
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Delete Account',
          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ResponsiveBody(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.error, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          color: AppColors.error,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Permanent Account Deletion',
                        style: AppTypography.displayHeadline.copyWith(
                          fontSize: 20,
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This action is irreversible. All your animal records, medical logs, and account credentials will be permanently erased.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // What Will Be Deleted Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What will be permanently deleted:',
                        style: AppTypography.featureTitle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _DeletionImpactItem(
                        icon: Icons.pets_outlined,
                        title: 'All Animals & Profiles',
                        subtitle: 'Mares, stallions, canines, and all registered animals.',
                      ),
                      _DeletionImpactItem(
                        icon: Icons.monitor_heart_outlined,
                        title: 'Breeding & Pregnancy Logs',
                        subtitle: 'Ultrasound scans, dates, and predictor calculations.',
                      ),
                      _DeletionImpactItem(
                        icon: Icons.child_care_outlined,
                        title: 'Foal & Puppy Records',
                        subtitle: 'Birth logs, weight tracking, and preventative care.',
                      ),
                      _DeletionImpactItem(
                        icon: Icons.badge_outlined,
                        title: 'Certificates & Contacts',
                        subtitle: 'PDF birth certificates and your breeder directory.',
                      ),
                      _DeletionImpactItem(
                        icon: Icons.vpn_key_outlined,
                        title: 'Authentication & Credentials',
                        subtitle: 'Your email login, password, and active sessions.',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Password Verification Box
                Text(
                  'Confirm Deletion With Password',
                  style: AppTypography.featureTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enter your current account password to verify your identity before proceeding:',
                  style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Account Password',
                  hintText: 'Enter your password',
                  leadingIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  errorText: _passwordError,
                  trailingWidget: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Delete CTA Button
                ElevatedButton(
                  onPressed: _isDeleting ? null : _handleDeleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    elevation: 0,
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Permanently Delete Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 14),

                // Cancel Button
                OutlinedButton(
                  onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                  child: Text(
                    'Cancel & Keep Account',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _DeletionImpactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const _DeletionImpactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.inputText.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
