import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnimalBirthdayPredictorApp());
}

class AnimalBirthdayPredictorApp extends StatelessWidget {
  const AnimalBirthdayPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal BirthDay Predictor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/onboarding',
      routes: AppRouter.routes,
    );
  }
}
