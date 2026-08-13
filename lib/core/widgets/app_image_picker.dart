import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class AppImagePicker extends StatelessWidget {
  final String? currentImagePath;
  final String label;
  final ValueChanged<String?> onImagePicked;
  final double height;
  final IconData icon;
  final bool isRequired;
  final String? errorText;

  const AppImagePicker({
    super.key,
    required this.currentImagePath,
    required this.label,
    required this.onImagePicked,
    this.height = 160,
    this.icon = Icons.camera_alt,
    this.isRequired = false,
    this.errorText,
  });

  Future<void> _showPickerOptions(BuildContext context) async {
    final picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceM),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.spaceM),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Select Image Source',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.primaryGold),
                ),
                const SizedBox(height: AppSpacing.spaceM),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primaryGold),
                  title: Text('Take Photo (Camera)', style: AppTypography.bodyMedium),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final picked = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (picked != null) {
                        onImagePicked(picked.path);
                      }
                    } catch (e) {
                      debugPrint('Error picking image from camera: $e');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primaryGold),
                  title: Text('Choose from Gallery', style: AppTypography.bodyMedium),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (picked != null) {
                        onImagePicked(picked.path);
                      }
                    } catch (e) {
                      debugPrint('Error picking image from gallery: $e');
                    }
                  },
                ),
                if (currentImagePath != null && currentImagePath!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(
                      'Remove Photo',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onImagePicked(null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  ImageProvider? _getImageProvider() {
    if (currentImagePath == null || currentImagePath!.trim().isEmpty) {
      return null;
    }
    final path = currentImagePath!.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return NetworkImage(path);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusL),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : (imageProvider != null
                        ? AppColors.primaryGold
                        : AppColors.primaryGold.withValues(alpha: 0.3)),
                width: hasError ? 1.5 : 1.0,
              ),
              image: imageProvider != null
                  ? DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageProvider == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: AppColors.primaryGold, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to capture with camera or choose from gallery',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(height: 4),
                        Text(
                          '* Photo required',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  )
                : Stack(
                    children: [
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: AppColors.primaryGold, size: 18),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
