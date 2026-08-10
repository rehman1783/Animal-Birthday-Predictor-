import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class SectionDividerLabel extends StatelessWidget {
  final String label;

  const SectionDividerLabel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.surface,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.sectionLabel,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.surface,
          ),
        ),
      ],
    );
  }
}
