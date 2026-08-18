import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Centralized service to manage runtime permissions (Camera, Gallery / Photos)
/// with elegant UI feedback and Settings redirect if permanently denied.
class PermissionService {
  /// Request Camera access before taking a photo.
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // Non-mobile platforms (or testing environments) bypass runtime permission dialogs
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return true;
    }

    try {
      final status = await Permission.camera.status;

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showPermissionSettingsDialog(
            context,
            title: 'Camera Permission Required',
            description:
                'Animal Birthday Predictor requires camera access to take photos of animals, markings, and ultrasound scans. Please enable camera access in your device settings.',
          );
        }
        return false;
      }

      final result = await Permission.camera.request();
      if (result.isGranted || result.isLimited) {
        return true;
      }

      if (result.isPermanentlyDenied) {
        if (context.mounted) {
          await _showPermissionSettingsDialog(
            context,
            title: 'Camera Permission Required',
            description:
                'Animal Birthday Predictor requires camera access to take photos of animals, markings, and ultrasound scans. Please enable camera access in your device settings.',
          );
        }
        return false;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission was denied. Please allow permission to take photos.'),
            backgroundColor: AppColors.surface,
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('PermissionService: Camera request error: $e');
      return true; // Fallback to let image_picker handle it natively
    }
  }

  /// Request Photos / Media Library access before picking an image from gallery.
  static Future<bool> requestPhotosPermission(BuildContext context) async {
    // Non-mobile platforms bypass runtime permission dialogs
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return true;
    }

    try {
      PermissionStatus status = await Permission.photos.status;

      // On older Android (SDK < 33), photos permission might return permanentlyDenied or not applicable,
      // fallback to storage permission check.
      if (!status.isGranted && !status.isLimited && Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted || storageStatus.isLimited) {
          return true;
        }
      }

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showPermissionSettingsDialog(
            context,
            title: 'Photo Library Permission Required',
            description:
                'Animal Birthday Predictor requires access to your photo library to select photos for animals, markings, and ultrasound scans. Please enable photo access in your device settings.',
          );
        }
        return false;
      }

      // Request photos permission
      var result = await Permission.photos.request();

      // Fallback for Android versions requiring storage permission
      if (!result.isGranted && !result.isLimited && Platform.isAndroid) {
        result = await Permission.storage.request();
      }

      if (result.isGranted || result.isLimited) {
        return true;
      }

      if (result.isPermanentlyDenied) {
        if (context.mounted) {
          await _showPermissionSettingsDialog(
            context,
            title: 'Photo Library Permission Required',
            description:
                'Animal Birthday Predictor requires access to your photo library to select photos for animals, markings, and ultrasound scans. Please enable photo access in your device settings.',
          );
        }
        return false;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo library permission was denied. Please allow permission to upload photos.'),
            backgroundColor: AppColors.surface,
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('PermissionService: Photos request error: $e');
      return true; // Fallback to let image_picker handle it natively
    }
  }

  /// Displays an attractive gold-themed modal dialog with options to cancel or open system app settings.
  static Future<void> _showPermissionSettingsDialog(
    BuildContext context, {
    required String title,
    required String description,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.security_outlined, color: AppColors.primaryGold, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTypography.displayHeadline.copyWith(
                  fontSize: 17,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('OPEN SETTINGS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
