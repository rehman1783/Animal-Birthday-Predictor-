import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_feedback_snackbar.dart';

class AppPhoneLauncher {
  AppPhoneLauncher._();

  static bool get _isMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Initiates a phone call or opens the device dialer on Android/iOS.
  /// If the platform/device does not support direct calling (e.g. tablet without SIM, desktop, web),
  /// it automatically copies the number to clipboard and informs the user with a rich feedback notification.
  static Future<void> makePhoneCall(BuildContext context, String rawPhoneNumber) async {
    final cleanPhone = rawPhoneNumber.trim();
    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Number Required',
          error: 'Please enter a contact phone number first.',
        );
      }
      return;
    }

    // Format phone number for tel: uri (preserve leading +, remove spaces, hyphens, brackets)
    final formattedDigits = cleanPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$formattedDigits');

    bool launched = false;
    if (_isMobilePlatform) {
      try {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        launched = false;
      }
    }

    if (!launched) {
      try {
        await Clipboard.setData(ClipboardData(text: cleanPhone));
      } catch (_) {}
      if (context.mounted) {
        AppFeedbackSnackbar.showInfo(
          context,
          title: 'Phone Number Copied',
          message: '$cleanPhone copied to clipboard (device dialer unavailable).',
        );
      }
    }
  }

  /// Launches email composer or copies email address.
  static Future<void> sendEmail(BuildContext context, String rawEmail) async {
    final email = rawEmail.trim();
    if (email.isEmpty) return;
    final uri = Uri.parse('mailto:$email');

    bool launched = false;
    if (_isMobilePlatform) {
      try {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        launched = false;
      }
    }

    if (!launched) {
      try {
        await Clipboard.setData(ClipboardData(text: email));
      } catch (_) {}
      if (context.mounted) {
        AppFeedbackSnackbar.showInfo(
          context,
          title: 'Email Copied',
          message: '$email copied to clipboard.',
        );
      }
    }
  }
}
