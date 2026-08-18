import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../providers/auth_provider.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;
  String? _emailError;

  static const int _initialCooldownSeconds = 60;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _isCheckingVerification = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
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

  bool _validateEmail() {
    setState(() {
      _emailError = null;
    });

    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty) {
      _emailError = 'Email address is required';
      setState(() {});
      return false;
    } else if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email address';
      setState(() {});
      return false;
    }

    return true;
  }

  Future<void> _handleSendResetLink() async {
    if (!_validateEmail()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .resetPasswordForEmail(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() {
        _isSent = true;
      });
      _startCooldownTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Please check your email inbox.'),
          backgroundColor: AppColors.surface,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.error?.toString() ?? 'Failed to send reset link.';

      setState(() {
        if (errorMsg.contains('not registered')) {
          _emailError = 'This email is not registered.';
        } else {
          _emailError = errorMsg;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleResendResetLink() async {
    if (_cooldownSeconds > 0) return;

    final targetEmail = _emailController.text.trim();
    if (targetEmail.isEmpty) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .resetPasswordForEmail(targetEmail);

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      _startCooldownTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link resent! Please check your inbox.'),
          backgroundColor: AppColors.surface,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.error?.toString() ?? 'Failed to resend reset link.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCheckVerified() async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
    });

    final targetEmail = _emailController.text.trim();
    final isVerified = await ref
        .read(authControllerProvider.notifier)
        .checkIsPasswordResetVerified(targetEmail);

    if (!mounted) return;

    setState(() {
      _isCheckingVerification = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset link verified! Please enter your new password.'),
          backgroundColor: AppColors.surface,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacementNamed(context, '/update-password');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your password reset link has not been verified yet. Please check your email inbox and tap the link first.',
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ResponsiveBody(
          child: Column(
            children: [
              // Header Banner
              const AuthHeaderBanner(
                imagePath: 'assets/images/auth_header_lost_your_way.png',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPadding,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSent) ...[
                      // Description
                      const Text(
                        "Enter your email address below. We'll send you a link to reset your password.",
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: 24.0),

                      // Email Field
                      CustomTextField(
                        label: 'Email Address',
                        hintText: 'Enter your registered email',
                        keyboardType: TextInputType.emailAddress,
                        leadingIcon: Icons.email_outlined,
                        controller: _emailController,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 28.0),

                      // CTA Button: Send Reset Link ➤
                      GradientCtaButton(
                        text: 'Send Reset Link ➤',
                        isLoading: isLoading,
                        onPressed: _handleSendResetLink,
                      ),
                    ] else ...[
                      // Confirmation View (State-Swap UI with 2 Action Buttons)
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.mark_email_read_outlined,
                                  color: AppColors.primaryGold,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Check Your Email',
                                    style: AppTypography.featureTitle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'We have dispatched password reset instructions to:\n${_emailController.text.trim()}',
                              style: AppTypography.body,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Info Note Box
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.inputField,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(
                            color: AppColors.inputBorder,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryGold,
                              size: 20,
                            ),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                'Please open your email app (e.g. Gmail), tap the reset link sent by ABP, and then tap “Verify Link” below.',
                                style: AppTypography.body,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28.0),

                      // Button 1 (Primary): "Verify Link"
                      GradientCtaButton(
                        text: 'Verify Link',
                        icon: const Icon(
                          Icons.verified_outlined,
                          color: AppColors.background,
                          size: 20,
                        ),
                        isLoading: _isCheckingVerification,
                        onPressed: _isCheckingVerification ? null : _handleCheckVerified,
                      ),

                      const SizedBox(height: 16.0),

                      // Button 2 (Secondary Outlined): "Resend Reset Link" (with Cooldown)
                      OutlinedButton(
                        onPressed: (_cooldownSeconds > 0 || isLoading)
                            ? null
                            : _handleResendResetLink,
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
                        child: isLoading
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
                                    : 'Resend Reset Link',
                                style: AppTypography.body.copyWith(
                                  color: _cooldownSeconds > 0
                                      ? AppColors.textMuted
                                      : AppColors.primaryGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],

                    const SizedBox(height: 32.0),

                    // Navigation Links: Back to Sign In or Change Email
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 20.0,
                        runSpacing: 10.0,
                        children: [
                          GestureDetector(
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
                          if (_isSent)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSent = false;
                                });
                              },
                              child: Text(
                                'Change Email',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // Trust Line
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.0,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.textMuted,
                            size: 14,
                          ),
                          Text(
                            'Secure Recovery Protocol',
                            style: AppTypography.finePrint.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
