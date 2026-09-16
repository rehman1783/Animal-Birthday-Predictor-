import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppEnv {
  static const String defaultUrl = 'https://nqoushtsmytrecpguubq.supabase.co';
  static const String defaultKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xb3VzaHRzbXl0cmVjcGd1dWJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQ2NjUsImV4cCI6MjEwMTY3MDY2NX0.-k5WrGjrBUj0eeSHqehpT-bB2QsV-F8aH1LME0ngEAY';

  static const String authRedirectScheme = 'io.supabase.animalbirthdaypredictor';

  /// Platform-adaptive Email Verification Redirect URL
  /// On Web: redirects back to origin (browser domain)
  /// On Mobile: uses custom scheme deep link for iOS/Android
  static String get emailVerificationRedirectUrl {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && !origin.startsWith('file:')) {
          return origin;
        }
      } catch (_) {}
      return 'https://animal-birthday-predictor.web.app';
    }
    return 'io.supabase.animalbirthdaypredictor://login-callback';
  }

  /// Platform-adaptive Password Reset Redirect URL
  /// On Web: redirects back to password update web screen
  /// On Mobile: uses custom scheme deep link for iOS/Android
  static String get passwordResetRedirectUrl {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && !origin.startsWith('file:')) {
          return '$origin/#/update-password';
        }
      } catch (_) {}
      return 'https://animal-birthday-predictor.web.app/#/update-password';
    }
    return 'io.supabase.animalbirthdaypredictor://reset-callback';
  }

  static String get supabaseUrl {
    const defineUrl = String.fromEnvironment('SUPABASE_URL');
    if (defineUrl.trim().isNotEmpty) {
      return defineUrl.trim();
    }
    try {
      if (dotenv.isInitialized) {
        final url = dotenv.env['Supabase_URL'] ?? dotenv.env['SUPABASE_URL'];
        if (url != null && url.trim().isNotEmpty) {
          return url.trim();
        }
      }
    } catch (_) {}
    return defaultUrl;
  }

  static String get supabaseKey {
    const defineKey = String.fromEnvironment('SUPABASE_KEY');
    if (defineKey.trim().isNotEmpty) {
      return defineKey.trim();
    }
    try {
      if (dotenv.isInitialized) {
        final key = dotenv.env['Supabase_Key'] ?? dotenv.env['SUPABASE_KEY'];
        if (key != null && key.trim().isNotEmpty) {
          return key.trim();
        }
      }
    } catch (_) {}
    return defaultKey;
  }
}
