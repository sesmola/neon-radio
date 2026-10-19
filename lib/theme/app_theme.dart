import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0A0A14);
  static const surface = Color(0xFF14142A);
  static const pink = Color(0xFFFF2E93);
  static const cyan = Color(0xFF00E5FF);
  static const purple = Color(0xFF7C4DFF);

  static const gradient = LinearGradient(
    colors: [pink, purple, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cyan,
          secondary: AppColors.pink,
          surface: AppColors.surface,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.purple.withOpacity(.35),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.cyan, width: 1.4),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.cyan,
          thumbColor: AppColors.cyan,
        ),
      );
}
