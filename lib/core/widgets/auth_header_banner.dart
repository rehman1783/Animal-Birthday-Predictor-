import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AuthHeaderBanner extends StatelessWidget {
  final String imagePath;
  final double height;

  const AuthHeaderBanner({
    super.key,
    required this.imagePath,
    this.height = 220,
    IconData? icon,
    String? title,
    String? subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              errorBuilder: (context, error, stackTrace) => Container(
                height: height,
                color: AppColors.background,
              ),
            ),
            Container(
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
          ],
        ),
      ),
    );
  }
}
