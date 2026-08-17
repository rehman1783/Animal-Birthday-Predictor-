import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppThumbnailAvatar extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;
  final double size;
  final double iconSize;
  final double borderRadius;
  final bool isCircle;

  const AppThumbnailAvatar({
    super.key,
    required this.imagePath,
    this.fallbackIcon = Icons.pets,
    this.size = 50,
    this.iconSize = 24,
    this.borderRadius = 8,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallbackWidget = Center(
      child: Icon(fallbackIcon, color: AppColors.primaryGold, size: iconSize),
    );

    Widget content;
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) {
      content = fallbackWidget;
    } else if (path.startsWith('http://') || path.startsWith('https://') || kIsWeb) {
      content = Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => fallbackWidget,
      );
    } else {
      try {
        final file = File(path);
        if (file.existsSync()) {
          content = Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => fallbackWidget,
          );
        } else {
          content = fallbackWidget;
        }
      } catch (_) {
        content = fallbackWidget;
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.inputField,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
      ),
      child: isCircle
          ? ClipOval(child: content)
          : ClipRRect(borderRadius: BorderRadius.circular(borderRadius - 1), child: content),
    );
  }
}
