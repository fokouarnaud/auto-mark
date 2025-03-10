import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const primary = Color(0xFF6750A4);       // Deep Purple
  static const secondary = Color(0xFF7D5260);     // Burgundy
  static const tertiary = Color(0xFFEFB8C8);      // Pink
  static const primaryContainer = Color(0xFFEADDFF); // Light Purple
  
  // Light theme colors
  static const backgroundLight = Color(0xFFFFFBFE);
  static const surfaceLight = Color(0xFFFFFBFE);
  static const outlineLight = Color(0xFFCAC4D0);
  static const textPrimaryLight = Color(0xFF1C1B1F);
  static const textSecondaryLight = Color(0xFF49454F);
  
  // Dark theme colors
  static const backgroundDark = Color(0xFF1C1B1F);
  static const surfaceDark = Color(0xFF2B2930);
  static const outlineDark = Color(0xFF938F99);
  static const textPrimaryDark = Color(0xFFE6E1E5);
  static const textSecondaryDark = Color(0xFFCAC4D0);
  
  // Semantic colors
  static const success = Color(0xFF4CAF50);  // Green
  static const warning = Color(0xFFFFC107);  // Amber
  static const error = Color(0xFFF44336);    // Red
  static const info = Color(0xFF2196F3);     // Blue
  
  // Neutral colors
  static const background = Color(0xFFFFFBFE);
  static const surface = Color(0xFFFFFBFE);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onTertiary = Color(0xFF000000);
  
  // Private constructor to prevent instantiation
  AppColors._();
}
