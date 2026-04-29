// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === PRIMARY PALETTE ===
  static const Color primary = Color(0xFF7C3AED); // Violet 600
  static const Color primaryLight = Color(0xFFA78BFA); // Violet 400
  static const Color secondary = Color(0xFFEC4899); // Pink 500
  static const Color accent = Color(0xFF06B6D4); // Cyan 500

  // === BACKGROUNDS ===
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgDarkSurface = Color(0xFF12121A);
  static const Color bgDarkCard = Color(0xFF1A1A28);
  static const Color bgLight = Color(0xFFF5F3FF);
  static const Color bgLightSurface = Color(0xFFFFFFFF);
  static const Color bgLightCard = Color(0xFFFAF8FF);

  // === TEXT ===
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textDarkSecondary = Color(0xFF334155);

  // === GLASS ===
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x80FFFFFF);

  // === STATUS ===
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // === SKILL CHIP COLORS ===
  static const List<Color> chipColors = [
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
  ];

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFDB2777)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0891B2), Color(0xFF7C3AED)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF06B6D4)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
  );

  static const LinearGradient bgGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A1A), Color(0xFF0F0A1E), Color(0xFF0A0A0F)],
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x407C3AED), Color(0x007C3AED)],
    radius: 0.8,
  );

  // === SHADOW ===
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primary.withOpacity(0.15),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
}
