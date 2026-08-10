import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AuthHeaderBanner extends StatelessWidget {
  final String imagePath;

  const AuthHeaderBanner({
    super.key,
    required this.imagePath,
    IconData? icon,
    String? title,
    String? subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imagePath,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 240,
            color: AppColors.background,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.7),
                  AppColors.background,
                ],
                stops: const [0.0, 0.5, 0.85, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
