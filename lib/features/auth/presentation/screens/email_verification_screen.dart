import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
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
  Timer? _pollingTimer;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isAutoRedirecting = false;

  @override
  void initState() {
    super.initState();
    _startAuthListener();
    _startPolling();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _pollingTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _startAuthListener() {
    try {
      final repo = ref.read(authRepositoryProvider);
      _authSubscription = repo.onAuthStateChange.listen((data) {
        if (!mounted || _isAutoRedirecting) return;
        final event = data.event;
        final session = data.session;
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.userUpdated ||
            (session != null &&
                session.user.emailConfirmedAt != null &&
                session.user.emailConfirmedAt!.isNotEmpty)) {
          _triggerSuccessRedirect();
        }
      });
    } catch (_) {}
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isAutoRedirecting) return;
      final targetEmail = _getTargetEmail();
      if (targetEmail.isEmpty) return;

      try {
        final isVerified = await ref
            .read(authControllerProvider.notifier)
            .checkIsEmailVerified(targetEmail);

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
      title: 'Email Verified',
      message: 'Your email has been verified! Welcome to Animal Birthday Predictor.',
      duration: const Duration(seconds: 3),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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

  String _getTargetEmail() {
    if (widget.email.trim().isNotEmpty) {
      return widget.email.trim();
    }
    final sessionEmail = ref.read(authRepositoryProvider).currentSession?.user.email;
    if (sessionEmail != null && sessionEmail.isNotEmpty) {
      return sessionEmail;
    }
    final profileEmail = ref.read(authControllerProvider).value?.email;
    return profileEmail ?? '';
  }

  Future<void> _handleResendEmail() async {
    if (_cooldownSeconds > 0) return;

    final targetEmail = _getTargetEmail();
    if (targetEmail.isEmpty) {
      AppFeedbackSnackbar.showError(
        context,
        title: 'Missing Email',
        error: 'Email address is missing. Please sign up or sign in again.',
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .resendVerificationEmail(targetEmail);

    if (!mounted) return;

    if (success) {
      _startCooldownTimer();
      AppFeedbackSnackbar.showSuccess(
        context,
        title: 'Verification Link Sent',
        message: 'A fresh verification email has been sent! Please check your inbox.',
      );
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.error?.toString() ?? 'Failed to resend verification email.';
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
    final isGlobalLoading = authState.isLoading;
    final displayEmail = _getTargetEmail();

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
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.inputField,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
                                displayEmail.isNotEmpty ? displayEmail : 'your email address',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
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
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
                                    'Open your email (e.g. Gmail) and tap the verification link. The app will automatically detect it and take you straight to your Home Dashboard.',
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

                      const SizedBox(height: 32.0),

                      // Primary CTA: "Resend Verification Email" (with Cooldown Timer)
                      GradientCtaButton(
                        text: _cooldownSeconds > 0
                            ? 'Resend in ${_cooldownSeconds}s'
                            : 'Resend Verification Email',
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.background,
                          size: 20,
                        ),
                        isLoading: isGlobalLoading,
                        onPressed: (_cooldownSeconds > 0 || isGlobalLoading)
                            ? null
                            : _handleResendEmail,
                      ),

                      const SizedBox(height: 32.0),

                      // Navigation Links: Back to Sign In or Sign Up
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 24.0,
                          runSpacing: 12.0,
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
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/signup');
                              },
                              child: Text(
                                'Back to Sign Up',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
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

