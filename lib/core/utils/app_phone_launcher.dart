import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_feedback_snackbar.dart';

class AppPhoneLauncher {
  AppPhoneLauncher._();

  /// Cleans and formats a phone number for dialing.
  /// Preserves a single leading '+', removes spaces, parentheses, dashes, letters, and extensions.
  static String sanitizePhoneNumber(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final hasLeadingPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '';
    return hasLeadingPlus ? '+$digitsOnly' : digitsOnly;
  }

  /// Initiates a phone call or opens the device dialer across Android, iOS, and desktop/web.
  /// If the platform/device does not support direct calling (e.g. tablet without SIM, desktop without dialer),
  /// it automatically copies the number to clipboard and informs the user with a rich notification.
  static Future<bool> makePhoneCall(BuildContext context, String rawPhoneNumber) async {
    final cleanPhone = rawPhoneNumber.trim();
    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Number Required',
          error: 'Please enter a contact phone number first.',
        );
      }
      return false;
    }

    final sanitized = sanitizePhoneNumber(cleanPhone);
    if (sanitized.isEmpty) {
      if (context.mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Invalid Phone Number',
          error: 'The entered phone number does not contain any valid digits.',
        );
      }
      return false;
    }

    final uri = Uri(scheme: 'tel', path: sanitized);

    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
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
      return false;
    }

    return true;
  }

  /// Launches native SMS messenger with optional message text.
  static Future<bool> sendSms(BuildContext context, String rawPhoneNumber, {String? body}) async {
    final cleanPhone = rawPhoneNumber.trim();
    if (cleanPhone.isEmpty) return false;
    final sanitized = sanitizePhoneNumber(cleanPhone);
    if (sanitized.isEmpty) return false;

    final uri = body != null && body.isNotEmpty
        ? Uri(scheme: 'sms', path: sanitized, queryParameters: {'body': body})
        : Uri(scheme: 'sms', path: sanitized);

    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
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
          message: '$cleanPhone copied to clipboard.',
        );
      }
      return false;
    }

    return true;
  }

  /// Opens WhatsApp chat with the target phone number.
  static Future<bool> sendWhatsApp(BuildContext context, String rawPhoneNumber, {String? message}) async {
    final cleanPhone = rawPhoneNumber.trim();
    if (cleanPhone.isEmpty) return false;
    final digitsOnly = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return false;

    final urlStr = message != null && message.isNotEmpty
        ? 'https://wa.me/$digitsOnly?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$digitsOnly';
    final uri = Uri.parse(urlStr);

    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = false;
      }
    }
    return launched;
  }

  /// Launches email composer or copies email address.
  static Future<bool> sendEmail(BuildContext context, String rawEmail, {String? subject, String? body}) async {
    final email = rawEmail.trim();
    if (email.isEmpty) return false;

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      },
    );

    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
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
      return false;
    }

    return true;
  }
}
