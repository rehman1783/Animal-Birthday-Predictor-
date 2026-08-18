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

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty) {
      _newPasswordError = 'New password is required';
      isValid = false;
    } else if (newPassword.length < 8) {
      _newPasswordError = 'Password must be at least 8 characters';
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your new password';
      isValid = false;
    } else if (newPassword != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleUpdatePassword() async {
    if (!_validateForm()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .updatePassword(_newPasswordController.text);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Welcome to Animal Birthday Predictor.'),
          backgroundColor: AppColors.surface,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.error?.toString() ?? 'Failed to update password.';
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
                      const Text(
                        'Reset Your Password',
                        style: AppTypography.displayHeadlineWhite,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Please enter a new secure password for your account.',
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: 24.0),

                      // New Password Field
                      CustomTextField(
                        label: 'New Password',
                        hintText: 'Enter new password (min 8 chars)',
                        leadingIcon: Icons.lock_outline,
                        obscureText: _obscureNewPassword,
                        controller: _newPasswordController,
                        errorText: _newPasswordError,
                        trailingWidget: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Confirm Password Field
                      CustomTextField(
                        label: 'Confirm New Password',
                        hintText: 'Re-enter new password',
                        leadingIcon: Icons.lock_reset_outlined,
                        obscureText: _obscureConfirmPassword,
                        controller: _confirmPasswordController,
                        errorText: _confirmPasswordError,
                        trailingWidget: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 28.0),

                      // CTA Button: Update Password
                      GradientCtaButton(
                        text: 'Update Password ✦',
                        isLoading: isLoading,
                        onPressed: _handleUpdatePassword,
                      ),

                      const SizedBox(height: 32.0),

                      // Back to Sign In Link
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
        ),
      ),
    );
  }
}
