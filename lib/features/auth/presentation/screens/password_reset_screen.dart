import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../providers/auth_provider.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;
  String? _emailError;

  static const int _initialCooldownSeconds = 60;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  Timer? _pollingTimer;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isAutoRedirecting = false;

  @override
  void initState() {
    super.initState();
    _startAuthListener();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _pollingTimer?.cancel();
    _authSubscription?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startAuthListener() {
    try {
      final repo = ref.read(authRepositoryProvider);
      _authSubscription = repo.onAuthStateChange.listen((data) {
        if (!mounted || _isAutoRedirecting) return;
        if (data.event == AuthChangeEvent.passwordRecovery) {
          _triggerSuccessRedirect();
        }
      });
    } catch (_) {}
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isAutoRedirecting || !_isSent) return;
      final targetEmail = _emailController.text.trim();
      if (targetEmail.isEmpty) return;

      try {
        final isVerified = await ref
            .read(authControllerProvider.notifier)
            .checkIsPasswordResetVerified(targetEmail);

        if (isVerified && mounted && !_isAutoRedirecting) {
          timer.cancel();
          _triggerSuccessRedirect();
        }
      } catch (_) {}
    });
  }

  void _triggerSuccessRedirect() {
    if (_isAutoRedirecting || !mounted) return;
    setState(() => _isAutoRedirecting = true);
    _pollingTimer?.cancel();
    _authSubscription?.cancel();

    AppFeedbackSnackbar.showSuccess(
      context,
      title: 'Reset Link Verified',
      message: 'Email link verified! Please set your new password.',
      duration: const Duration(seconds: 3),
    );

    Navigator.pushReplacementNamed(context, '/update-password');
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
      _startPolling();
      AppFeedbackSnackbar.showSuccess(
        context,
        title: 'Reset Link Sent',
        message: 'Password reset link sent! Please check your email inbox.',
      );
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg =
          errorState.error?.toString() ?? 'Failed to send reset link.';

      setState(() {
        if (errorMsg.contains('not registered')) {
          _emailError = 'This email is not registered.';
        } else {
          _emailError = errorMsg;
        }
      });
      AppFeedbackSnackbar.showError(
        context,
        title: 'Send Failed',
        error: errorMsg,
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

    if (success) {
      _startCooldownTimer();
      AppFeedbackSnackbar.showSuccess(
        context,
        title: 'Link Resent',
        message: 'Password reset link resent! Please check your inbox.',
      );
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg =
          errorState.error?.toString() ?? 'Failed to resend reset link.';
      AppFeedbackSnackbar.showError(
        context,
        title: 'Resend Failed',
        error: errorMsg,
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
          physics: const BouncingScrollPhysics(),
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
                        // Confirmation View (State-Swap UI)
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.cardRadius,
                            ),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(
                                alpha: 0.3,
                              ),
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

                        // Information Card with Automatic Detection Indicator
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.cardRadius,
                            ),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.mark_email_unread_outlined,
                                color: AppColors.primaryGold,
                                size: 26,
                              ),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Waiting for Verification...',
                                      style: AppTypography.featureTitle.copyWith(
                                        fontSize: 15,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Open your Gmail or email app and tap the password reset link. The app will automatically open and redirect you to set your new password.',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28.0),

                        // Primary CTA: "Resend Reset Link" (with Cooldown)
                        GradientCtaButton(
                          text: _cooldownSeconds > 0
                              ? 'Resend in ${_cooldownSeconds}s'
                              : 'Resend Reset Link',
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.background,
                            size: 20,
                          ),
                          isLoading: isLoading,
                          onPressed: (_cooldownSeconds > 0 || isLoading)
                              ? null
                              : _handleResendResetLink,
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
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/signin',
                                );
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
                              style: AppTypography.finePrint.copyWith(
                                fontSize: 12,
                              ),
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
