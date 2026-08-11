import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt to load .env file if available in assets
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Quietly continue if asset bundle has not reloaded
  }

  // Initialize Supabase using project credentials from .env
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseKey,
  );

  // Check initial route conditions (Onboarding + Session)
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final session = Supabase.instance.client.auth.currentSession;

  String initialRoute;
  if (!hasSeenOnboarding) {
    initialRoute = '/onboarding';
  } else if (session != null) {
    initialRoute = '/home';
  } else {
    initialRoute = '/signin';
  }

  runApp(
    ProviderScope(
      child: AnimalBirthdayPredictorApp(initialRoute: initialRoute),
    ),
  );
}

class AnimalBirthdayPredictorApp extends StatefulWidget {
  final String initialRoute;

  const AnimalBirthdayPredictorApp({
    super.key,
    required this.initialRoute,
  });

  @override
  State<AnimalBirthdayPredictorApp> createState() => _AnimalBirthdayPredictorAppState();
}

class _AnimalBirthdayPredictorAppState extends State<AnimalBirthdayPredictorApp> {
  @override
  void initState() {
    super.initState();

    // Listen for Auth changes (e.g. Password Recovery Deep Link)
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.passwordRecovery) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/update-password',
            (route) => false,
          );
        }
      });
    } catch (_) {
      // Ignore if Supabase instance is not initialized in test environment
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Animal Birthday Predictor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: widget.initialRoute,
      routes: AppRouter.routes,
    );
  }
}
