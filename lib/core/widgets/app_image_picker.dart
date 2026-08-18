import 'dart:convert';
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

  Future<void> _handleImagePicked(XFile? picked) async {
    if (picked == null) return;
    try {
      final bytes = await picked.readAsBytes();
      if (bytes.isNotEmpty) {
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        onImagePicked(base64String);
      } else {
        onImagePicked(picked.path);
      }
    } catch (_) {
      onImagePicked(picked.path);
    }
  }

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
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 75,
                      );
                      await _handleImagePicked(picked);
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
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 75,
                      );
                      await _handleImagePicked(picked);
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

  Widget _buildImagePreview() {
    final path = currentImagePath?.trim();
    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
      );
    }

    // 1. Data URI / Base64 format
    if (path.startsWith('data:image/') || path.startsWith('base64,')) {
      try {
        final commaIndex = path.indexOf(',');
        final base64String = commaIndex != -1 ? path.substring(commaIndex + 1) : path;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
          ),
        );
      } catch (_) {
        return const Center(
          child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
        );
      }
    }

    // 2. HTTP / HTTPS / Blob network URLs
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
        ),
      );
    }

    // 3. Raw Base64 string fallback
    if (path.length > 200 && !path.contains(Platform.pathSeparator) && !path.contains('/')) {
      try {
        final bytes = base64Decode(path);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
          ),
        );
      } catch (_) {}
    }

    // 4. Local File (non-web)
    if (!kIsWeb) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
            ),
          );
        }
      } catch (_) {}
    }

    return const Center(
      child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = currentImagePath != null && currentImagePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: AppTypography.inputLabel,
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          softWrap: true,
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
                        _buildImagePreview(),
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
