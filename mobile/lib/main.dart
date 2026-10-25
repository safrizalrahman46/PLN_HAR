import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PLNHARApp());
}

class PLNHARApp extends StatelessWidget {
  const PLNHARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLN Nusa Daya HAR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

