import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'species_icon.dart';

class AppThumbnailAvatar extends StatelessWidget {
  final String? species;
  final String? imagePath;
  final IconData fallbackIcon;
  final Widget? customFallback;
  final double size;
  final double iconSize;
  final double borderRadius;
  final bool isCircle;

  const AppThumbnailAvatar({
    super.key,
    required this.imagePath,
    this.species,
    this.fallbackIcon = Icons.pets,
    this.customFallback,
    this.size = 50,
    this.iconSize = 24,
    this.borderRadius = 8,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallbackWidget = Center(
      child: customFallback ??
          (species != null
              ? SpeciesIcon(species: species, size: iconSize)
              : Icon(fallbackIcon, color: AppColors.primaryGold, size: iconSize)),
    );

    Widget content;
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) {
      content = fallbackWidget;
    } else if (path.startsWith('data:image/') || path.startsWith('base64,')) {
      try {
        final commaIndex = path.indexOf(',');
        final base64String = commaIndex != -1 ? path.substring(commaIndex + 1) : path;
        final bytes = base64Decode(base64String);
        content = Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => fallbackWidget,
        );
      } catch (_) {
        content = fallbackWidget;
      }
    } else if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      content = Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => fallbackWidget,
      );
    } else if (path.length > 200 && !path.contains(Platform.pathSeparator) && !path.contains('/')) {
      // Try raw Base64 without data URI scheme
      try {
        final bytes = base64Decode(path);
        content = Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => fallbackWidget,
        );
      } catch (_) {
        content = fallbackWidget;
      }
    } else if (!kIsWeb) {
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
    } else {
      content = fallbackWidget;
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
