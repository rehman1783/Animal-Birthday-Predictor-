import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/keyboard_helper.dart';

/// Reusable Standardized Back Button that automatically closes the keyboard
/// first if open before triggering back navigation.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;
  final double size;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color = AppColors.textPrimary,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: color, size: size),
      onPressed: () {
        if (dismissKeyboardIfOpen(context)) {
          return;
        }
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
