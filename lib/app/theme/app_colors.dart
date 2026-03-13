import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surfaces
  static const surface = Color(0xFF0F0F14);
  static const surfaceLight = Color(0xFF16161E);
  static const cardSurface = Color(0xFF1A1A24);
  static const inputSurface = Color(0xFF1E1E2A);

  // Accent
  static const accent = Color(0xFF00BFA6);
  static const accentLight = Color(0xFF00E5CC);
  static const accentDark = Color(0xFF009688);

  // Gradients
  static const accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surfaceGradient = LinearGradient(
    colors: [Color(0xFF1A1A24), Color(0xFF0F0F14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFFB0B0C0);
  static const textMuted = Color(0xFF6B6B80);

  // Status
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFEF5350);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);

  // Borders
  static const border = Color(0xFF2A2A3A);
  static const borderLight = Color(0xFF3A3A4A);

  // Glass
  static const glassWhite = Color(0x14FFFFFF);
  static const glassBorder = Color(0x24FFFFFF);

  // Message bubbles
  static const userBubble = Color(0xFF00BFA6);
  static const assistantBubble = Color(0xFF1E1E2A);
}
