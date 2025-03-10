import 'package:flutter/material.dart';

class AppColors {
  // Primary brand color
  static final Color primary = Color(0xFF4F6CFF);
  static final Color primaryContainer = Color(0xFFE4EAFF);
  
  // Secondary
  static final Color secondary = Color(0xFF9747FF);
  static final Color secondaryContainer = Color(0xFFF2E7FF);
  
  // Accent
  static final Color accent = Color(0xFF00C2FF);
  static final Color accentContainer = Color(0xFFDFF6FF);
  
  // Functional colors
  static final Color error = Color(0xFFFF574D);
  static final Color success = Color(0xFF2ED573);
  static final Color warning = Color(0xFFFFBE44);
  static final Color info = Color(0xFF54A0FF);
  static final Color infoContainer = Color(0xFFE4F2FF);
  
  // Light theme colors
  static final Color backgroundLight = Color(0xFFF8F9FC);
  static final Color surfaceLight = Color(0xFFFFFFFF);
  static final Color textPrimaryLight = Color(0xFF1A1A2C);
  static final Color textSecondaryLight = Color(0xFF6E7191);
  static final Color outlineLight = Color(0xFFE2E8F0);
  
  // Dark theme colors
  static final Color backgroundDark = Color(0xFF121212);
  static final Color surfaceDark = Color(0xFF1E1E1E);
  static final Color textPrimaryDark = Color(0xFFF7F9FC);
  static final Color textSecondaryDark = Color(0xFFAFB5C0);
  static final Color outlineDark = Color(0xFF2A2E3F);
  
  // Gradients
  static final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primary.withOpacity(0.8)],
  );
  
  static final LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
