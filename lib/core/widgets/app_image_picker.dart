import 'dart:io';
import 'package:flutter/foundation.dart';
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

  AppImagePicker({
    super.key,
    String? currentImagePath,
    String? initialImageUrl,
    required this.label,
    ValueChanged<String?>? onImagePicked,
    ValueChanged<String?>? onImageSelected,
    this.height = 160,
    this.icon = Icons.camera_alt,
    this.isRequired = false,
    this.errorText,
  })  : currentImagePath = currentImagePath ?? initialImageUrl,
        onImagePicked = onImagePicked ?? onImageSelected ?? ((_) {});

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
                      debugPrint('Camera picker error: $e');
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
                      debugPrint('Gallery picker error: $e');
                    }
                  },
                ),
                if (currentImagePath != null && currentImagePath!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
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

  @override
  Widget build(BuildContext context) {
    final hasImage = currentImagePath != null && currentImagePath!.isNotEmpty;
    final isNetwork = hasImage && (currentImagePath!.startsWith('http://') || currentImagePath!.startsWith('https://'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.inputLabel,
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 6.0),
        GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputField,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: errorText != null
                    ? Colors.redAccent
                    : hasImage
                        ? AppColors.primaryGold
                        : AppColors.surface,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius - 1),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isNetwork)
                          Image.network(
                            currentImagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
                            ),
                          )
                        else if (kIsWeb)
                          Image.network(
                            currentImagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
                            ),
                          )
                        else if (File(currentImagePath!).existsSync())
                          Image.file(
                            File(currentImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
                          ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryGold),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: AppColors.primaryGold,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: AppColors.primaryGold,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to take photo or choose image',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
