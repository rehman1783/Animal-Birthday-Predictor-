import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepMeSignedIn = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      _emailError = 'Email address is required';
      isValid = false;
    } else if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email address';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleSignIn() async {
    if (!_validateForm()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.error?.toString() ?? 'Failed to sign in.';

      setState(() {
        if (errorMsg.contains('Incorrect email or password')) {
          _emailError =
              'Incorrect email or password. Please check your credentials.';
        } else if (errorMsg.contains('This account does not exist')) {
          _emailError =
              'This account does not exist. Please create an account first.';
        } else if (errorMsg.contains('Incorrect password')) {
          _passwordError = 'Incorrect password. Please try again.';
          AppFeedbackSnackbar.showError(
            context,
            title: 'Incorrect Password',
            error: 'The password you entered is incorrect. Please try again.',
          );
        } else if (errorMsg.contains('verify your email')) {
          _emailError = 'Please verify your email address before signing in.';
          AppFeedbackSnackbar.showError(
            context,
            title: 'Email Not Verified',
            error: 'Please check your Gmail/inbox and verify your email before signing in.',
          );
        } else {
          AppFeedbackSnackbar.showError(
            context,
            title: 'Sign In Failed',
            error: errorMsg,
          );
        }
      });
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
                  imagePath: 'assets/images/auth_header_welcome_back.png',
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Address
                      CustomTextField(
                        label: 'Email Address',
                        hintText: 'alex.sterling@example.com',
                        keyboardType: TextInputType.emailAddress,
                        leadingIcon: Icons.email_outlined,
                        controller: _emailController,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 16.0),

                      // Password with Inline "Forgot" link
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: '',
                            hintText: '••••••••',
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
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password',
                                style: AppTypography.inputLabel,
                              ),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/reset-password',
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTypography.inputLabel.copyWith(
                                      color: AppColors.primaryGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 08.0),
                    // Keep me signed in Toggle
                    Row(
                      children: [
                        Switch(
                          value: _keepMeSignedIn,
                          activeThumbColor: AppColors.primaryGold,
                          activeTrackColor: AppColors.surface,
                          inactiveThumbColor: AppColors.textMuted,
                          inactiveTrackColor: AppColors.inputField,
                          onChanged: (val) {
                            setState(() {
                              _keepMeSignedIn = val;
                            });
                          },
                        ),
                        const SizedBox(width: 8.0),
                        const Expanded(
                          child: Text(
                            'Keep me signed in',
                            style: AppTypography.body,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24.0),

                    // Primary CTA Button: Sign In
                    GradientCtaButton(
                      text: 'Sign In',
                      isLoading: isLoading,
                      onPressed: _handleSignIn,
                    ),

                    const SizedBox(height: 32.0),

                    // Footer navigation
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'New to Animal BirthDay Predictor? ',
                            style: AppTypography.body,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              'Create Account →',
                              style: AppTypography.body.copyWith(
                                color: AppColors.primaryGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Small trust line: Encrypted & Secure Session
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.0,
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            color: AppColors.textMuted,
                            size: 14,
                          ),
                          Text(
                            'Encrypted & Secure Session',
                            style: AppTypography.finePrint.copyWith(
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
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
