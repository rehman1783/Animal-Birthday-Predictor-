import 'package:flutter/material.dart';

abstract class AppColors {
  /// Primary dark navy background (#0A192F)
  static const Color background = Color(0xFF0A192F);

  /// Elevated surface container / icon containers (#112240)
  static const Color surface = Color(0xFF112240);

  /// Input text field background (#131B2D)
  static const Color inputField = Color(0xFF131B2D);

  /// Input text field border default (#080E1A)
  static const Color inputBorder = Color(0xFF080E1A);

  /// Primary gold (#D4AF37) - Headings, labels, links, active states
  static const Color primaryGold = Color(0xFFD4AF37);

  /// CTA button gradient start (#D6B23F)
  static const Color goldGradientStart = Color(0xFFD6B23F);

  /// CTA button gradient end (#EDD086)
  static const Color goldGradientEnd = Color(0xFFEDD086);

  /// Titles on dark background (#FFFFFF)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Body copy / descriptions (#8A8F98)
  static const Color textSecondary = Color(0xFF8A8F98);

  /// Fine print, footer captions (#525358)
  static const Color textMuted = Color(0xFF525358);

  /// Error color (#E53935)
  static const Color error = Color(0xFFE53935);

  /// Gold Linear Gradient for CTA buttons
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldGradientStart, goldGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
