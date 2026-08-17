import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class SectionDividerLabel extends StatelessWidget {
  final String label;
  final bool isLeftAligned;

  const SectionDividerLabel({
    super.key,
    required this.label,
    this.isLeftAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLeftAligned) {
      return Row(
        children: [
          Container(
            width: 32.0,
            height: 2.0,
            color: AppColors.primaryGold,
          ),
          const SizedBox(width: 12.0),
          Text(
            label.toUpperCase(),
            style: AppTypography.sectionLabel.copyWith(
              fontSize: 13.0,
              letterSpacing: 2.0,
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.sectionLabel,
            ),
          );
        }
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
      },
    );
  }
}
