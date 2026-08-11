import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppEnv {
  static const String defaultUrl = 'https://nqoushtsmytrecpguubq.supabase.co';
  static const String defaultKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xb3VzaHRzbXl0cmVjcGd1dWJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQ2NjUsImV4cCI6MjEwMTY3MDY2NX0.-k5WrGjrBUj0eeSHqehpT-bB2QsV-F8aH1LME0ngEAY';

  static String get supabaseUrl {
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
