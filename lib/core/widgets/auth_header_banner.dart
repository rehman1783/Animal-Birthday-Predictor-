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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 220,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}
