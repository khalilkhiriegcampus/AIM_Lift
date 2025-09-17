import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1976D2); // Blue
  static const secondary = Color(0xFF42A5F5); // Light blue
  static const background = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const body = TextStyle(fontSize: 16, color: AppColors.textPrimary);

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(bodyMedium: AppTextStyles.body),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  ),
);
