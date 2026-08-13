import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _fullNameError = null;
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      _fullNameError = 'Full name is required';
      isValid = false;
    }

    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      _emailError = 'Email address is required';
      isValid = false;
    } else if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email address';
      isValid = false;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleSignUp() async {
    if (!_validateForm()) return;

    final success = await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      final userEmail = _emailController.text.trim();
      Navigator.pushReplacementNamed(
        context,
        '/email-verification',
        arguments: userEmail,
      );
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.error?.toString() ?? 'An error occurred during sign up.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
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
                  // Full Name
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Alex Sterling',
                    leadingIcon: Icons.person_outline,
                    controller: _fullNameController,
                    errorText: _fullNameError,
                  ),
                  const SizedBox(height: 16.0),

                  // Email Address
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    leadingIcon: Icons.email_outlined,
                    controller: _emailController,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 16.0),

                  // Password
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Create a password',
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

                  const SizedBox(height: 28.0),

                  // Primary CTA Button
                  GradientCtaButton(
                    text: 'Create Account',
                    isLoading: isLoading,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.background,
                      size: 20,
                    ),
                    onPressed: _handleSignUp,
                  ),

                  const SizedBox(height: 28.0),

                  // Divider: OR CONTINUE WITH
                  const SectionDividerLabel(label: 'OR CONTINUE WITH'),

                  const SizedBox(height: 20.0),

                  // Social Auth Buttons
                  SocialAuthButton(
                    provider: SocialProvider.apple,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Apple sign in (Mock state trigger)'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12.0),
                  SocialAuthButton(
                    provider: SocialProvider.google,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google sign in (Mock state trigger)'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32.0),

                  // Footer navigation: Already have an account? Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: AppTypography.body,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signin');
                        },
                        child: Text(
                          'Sign In',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Fine print
                  const Center(
                    child: Text(
                      'By creating an account, you agree to our Terms of Service and Privacy Policy',
                      style: AppTypography.finePrint,
                      textAlign: TextAlign.center,
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
