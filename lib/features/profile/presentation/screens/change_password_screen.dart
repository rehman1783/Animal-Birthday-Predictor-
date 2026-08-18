import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      _currentPasswordError = 'Current password is required';
      isValid = false;
    }

    if (newPassword.isEmpty) {
      _newPasswordError = 'New password is required';
      isValid = false;
    } else if (newPassword.length < 8) {
      _newPasswordError = 'Password must be at least 8 characters';
      isValid = false;
    } else if (currentPassword.isNotEmpty && newPassword == currentPassword) {
      _newPasswordError = 'New password must be different from current password';
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

  Future<void> _handleChangePassword() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      AppFeedbackSnackbar.showSuccess(
        context,
        title: 'Password Changed',
        message: 'Your password has been updated successfully!',
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final errorMsg = e is AuthExceptionCustom
          ? e.message
          : e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');

      setState(() {
        if (errorMsg.toLowerCase().contains('current password') ||
            errorMsg.toLowerCase().contains('incorrect')) {
          _currentPasswordError = errorMsg;
        }
      });

      AppFeedbackSnackbar.showError(
        context,
        title: 'Password Change Failed',
        error: errorMsg,
      );
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryGold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveBody(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPadding,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Box
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
                          Icons.security_outlined,
                          color: AppColors.primaryGold,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'To change your password, enter your current password followed by your new password.',
                            style: AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // 1. Current Password Field
                  CustomTextField(
                    label: 'Current Password',
                    hintText: 'Enter your current password',
                    leadingIcon: Icons.lock_outline,
                    obscureText: _obscureCurrentPassword,
                    controller: _currentPasswordController,
                    errorText: _currentPasswordError,
                    trailingWidget: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // 2. New Password Field
                  CustomTextField(
                    label: 'New Password',
                    hintText: 'Enter new password (min 8 chars)',
                    leadingIcon: Icons.lock_reset_outlined,
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

                  // 3. Confirm New Password Field
                  CustomTextField(
                    label: 'Confirm New Password',
                    hintText: 'Re-enter new password',
                    leadingIcon: Icons.check_circle_outline,
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

                  // CTA Button: Change Password
                  GradientCtaButton(
                    text: 'Change Password ✦',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleChangePassword,
                  ),

                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
