import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surfaces
  // Dark, premium-neutral palette (no neon, no bright purple/blue).
  // Direction: graphite + warm stone, accent: muted brass (very subtle).
  static const surface = Color(0xFF0F1111);
  static const surfaceLight = Color(0xFF171A19);
  static const cardSurface = Color(0xFF141716);
  static const inputSurface = Color(0xFF101312);

  // Accent
  // Muted brass (not yellow/neon).
  static const accent = Color(0xFF9B8F7A);
  static const accentLight = Color(0xFFC7BCA8);
  static const accentDark = Color(0xFF7A705F);

  // Gradients
  static const accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surfaceGradient = LinearGradient(
    colors: [Color(0xFF141716), Color(0xFF0F1111)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const ambientGlowGradient = RadialGradient(
    colors: [
      Color(0x169B8F7A),
      Color(0x000F1111),
    ],
    radius: 1.0,
    center: Alignment(-0.7, -0.8),
  );

  static const lightSurfaceGradient = LinearGradient(
    colors: [Color(0xFFF6F3EE), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const lightAmbientGlowGradient = RadialGradient(
    colors: [
      Color(0x129B8F7A),
      Color(0x00FFFFFF),
    ],
    radius: 1.0,
    center: Alignment(-0.6, -0.9),
  );

  // Text
  static const textPrimary = Color(0xFFF2F0EA);
  static const textSecondary = Color(0xFFB9B6AD);
  static const textMuted = Color(0xFF7E827B);

  // Status
  static const success = Color(0xFF4F7E63);
  static const error = Color(0xFFB85D5D);
  static const warning = Color(0xFFB8924B);
  static const info = Color(0xFF6E7B73);

  // Borders
  static const border = Color(0xFF272C35);
  static const borderLight = Color(0xFF343B48);

  // Glass
  static const glassWhite = Color(0x0FFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);

  // Shadows
  static const shadow = Color(0xCC000000);

  // Message bubbles
  static const userBubble = accent;
  static const assistantBubble = cardSurface;
}
