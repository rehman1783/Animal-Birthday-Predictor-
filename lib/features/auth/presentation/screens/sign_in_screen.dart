import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/auth_header_banner.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../../core/widgets/social_auth_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepMeSignedIn = true;
  bool _isLoading = false;

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

    if (email.isEmpty) {
      _emailError = 'Email address is required';
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

    setState(() {
      _isLoading = true;
    });

    // Mock API loading delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate to placeholder home screen
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner (Welcome Back / Starry Sky Header)
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
                  
                      const SizedBox(height: 8.0),
                      CustomTextField(
                        label: '',
                        hintText: '••••••••',
                        leadingIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        errorText: _passwordError,
                        trailingWidget: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                          Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Password',
                            style: AppTypography.inputLabel,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/reset-password');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: AppTypography.inputLabel.copyWith(
                                color: AppColors.primaryGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12.0),

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
                      const Text(
                        'Keep me signed in',
                        style: AppTypography.body,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),

                  // Primary CTA Button: Begin Journey ✦
                  GradientCtaButton(
                    text: 'Begin Journey ✦',
                    isLoading: _isLoading,
                    onPressed: _handleSignIn,
                  ),

                  const SizedBox(height: 28.0),

                  // Divider: SOCIAL ACCESS
                  const SectionDividerLabel(label: 'SOCIAL ACCESS'),

                  const SizedBox(height: 20.0),

                  // Social Auth Buttons (Apple / Google)
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

                  // Footer navigation: New to the celestial cycle? Join the Pride →
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New to the celestial cycle? ',
                        style: AppTypography.body,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          'Join the Pride →',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  // Small trust line: Encrypted & Secure Session
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        color: AppColors.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Encrypted & Secure Session',
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
