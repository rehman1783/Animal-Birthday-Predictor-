import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  static const int _initialCooldownSeconds = 60;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _isCheckingVerification = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() {
      _cooldownSeconds = _initialCooldownSeconds;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds > 1) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        setState(() {
          _cooldownSeconds = 0;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendEmail() async {
    if (_cooldownSeconds > 0) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .resendVerificationEmail(widget.email);

    if (!mounted) return;

    if (success) {
      _startCooldownTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email resent! Please check your inbox.'),
          backgroundColor: AppColors.surface,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.error?.toString() ?? 'Failed to resend email.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCheckVerified() async {
    setState(() {
      _isCheckingVerification = true;
    });

    final isVerified = await ref
        .read(authControllerProvider.notifier)
        .checkIsEmailVerified(widget.email);

    if (!mounted) return;

    setState(() {
      _isCheckingVerification = false;
    });

    if (isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully! Please sign in to continue.'),
          backgroundColor: AppColors.surface,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your email is not verified yet. Please check your inbox and click the verification link.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isGlobalLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Auth Banner Header
            const AuthHeaderBanner(
              imagePath: 'assets/images/auth_header_join_the_mystery.png',
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPadding,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
                  const Text(
                    'Verify Your Email',
                    style: AppTypography.displayHeadlineWhite,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'We sent a verification link to your email address:',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: AppColors.inputField,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            widget.email,
                            style: AppTypography.body.copyWith(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Information Card
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                        color: AppColors.primaryGold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.mark_email_unread_outlined,
                          color: AppColors.primaryGold,
                          size: 24,
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'Please open your email app, tap the verification link, and then return to this screen.',
                            style: AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32.0),

                  // Primary CTA 1: "I've Verified My Email"
                  GradientCtaButton(
                    text: 'I’ve Verified My Email',
                    isLoading: _isCheckingVerification,
                    onPressed: _isCheckingVerification ? null : _handleCheckVerified,
                  ),

                  const SizedBox(height: 16.0),

                  // Primary CTA 2: "Resend Verification Email" (with Cooldown Timer)
                  OutlinedButton(
                    onPressed: (_cooldownSeconds > 0 || isGlobalLoading)
                        ? null
                        : _handleResendEmail,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(
                        color: _cooldownSeconds > 0
                            ? AppColors.inputBorder
                            : AppColors.primaryGold,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      ),
                    ),
                    child: isGlobalLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGold,
                            ),
                          )
                        : Text(
                            _cooldownSeconds > 0
                                ? 'Resend in ${_cooldownSeconds}s'
                                : 'Resend Verification Email',
                            style: AppTypography.body.copyWith(
                              color: _cooldownSeconds > 0
                                  ? AppColors.textMuted
                                  : AppColors.primaryGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 32.0),

                  // Back to Sign In
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signin');
                      },
                      child: Text(
                        '← Back to Sign In',
                        style: AppTypography.body.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
