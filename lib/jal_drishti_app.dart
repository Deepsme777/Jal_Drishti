import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/jd_colors.dart';

class JalDrishtiApp extends StatelessWidget {
  const JalDrishtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jal-Drishti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: JDColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: JDColors.waterBlue,
          primary: JDColors.waterBlue,
          secondary: JDColors.teal,
          surface: JDColors.surface,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: JDColors.navy,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
          headlineMedium: TextStyle(
            color: JDColors.navy,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          bodyLarge: TextStyle(
            color: JDColors.mutedText,
            fontSize: 16,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: JDColors.mutedText,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}