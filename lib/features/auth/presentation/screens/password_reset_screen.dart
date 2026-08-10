import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

    setState(() {
      _isLoading = true;
    });

    // Mock loading delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
                      "Enter your email address below. We'll send you a mystical link to reset your journey's password.",
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
                      isLoading: _isLoading,
                      onPressed: _handleSendResetLink,
                    ),
                  ] else ...[
                    // Confirmation View (State-Swap UI)
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
                              Text(
                                'Check Your Email',
                                style: AppTypography.featureTitle,
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
                  ],

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
                            "If you don't receive an email in a few minutes, please check your spam folder or ensure the address matches your account.",
                            style: AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32.0),

                  // Back to Sign In link
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

                  const SizedBox(height: 20.0),

                  // Trust Line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secure Recovery Protocol',
                        style: AppTypography.finePrint.copyWith(fontSize: 12),
                      ),
                    ],
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
