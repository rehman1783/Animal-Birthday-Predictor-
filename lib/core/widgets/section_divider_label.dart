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
            width: 24.0,
            height: 2.0,
            color: AppColors.primaryGold,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.sectionLabel.copyWith(
                fontSize: 13.0,
                letterSpacing: 1.5,
              ),
              softWrap: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 1,
            color: AppColors.surface,
          ),
        ),
        Flexible(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.sectionLabel,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 1,
            color: AppColors.surface,
          ),
        ),
      ],
    );
  }
}
