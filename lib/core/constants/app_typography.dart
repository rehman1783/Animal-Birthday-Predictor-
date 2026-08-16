import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  /// Display Headline ("Animal BirthDay Predictor", "Welcome Back"): Serif, ~28-32sp, gold or white
  static const TextStyle displayHeadline = TextStyle(
    fontFamily: 'serif',
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGold,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Display Headline White version
  static const TextStyle displayHeadlineWhite = TextStyle(
    fontFamily: 'serif',
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Section Label ("WHY ABP?", "OR CONTINUE WITH"): Small caps, letter-spaced, gold, ~11-12sp
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryGold,
    letterSpacing: 1.8,
  );

  /// Feature Title ("Precision Tracking" etc.): Sans-serif, semi-bold, gold, ~16sp
  static const TextStyle featureTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryGold,
    letterSpacing: 0.2,
  );

  /// Subtitle / Header tagline
  static const TextStyle subtitle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Body (descriptions, subtitles): Sans-serif regular, textSecondary, ~14sp, line-height ~1.5
  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// Button label: Sans-serif bold, dark navy text on gold gradient buttons
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.background,
    letterSpacing: 0.3,
  );

  /// Input Field text
  static const TextStyle inputText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Input Field label
  static const TextStyle inputLabel = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Input Field placeholder
  static const TextStyle inputHint = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  /// Fine print / footer caption
  static const TextStyle finePrint = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  // Standard Typography Aliases
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGold,
    letterSpacing: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
