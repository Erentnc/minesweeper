import 'package:flutter/material.dart';

/// Neon Minesweeper renk paleti.
///
/// Tüm uygulama genelinde tutarlı bir koyu neon görünüm sağlamak için
/// merkezi olarak tanımlanmıştır.
class AppColors {
  AppColors._();

  // Arka plan ve yüzey renkleri
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF131836);
  static const Color surfaceElevated = Color(0xFF1A2044);
  static const Color boardFrame = Color(0xFF111632);

  // Hücre renkleri
  static const Color cellClosed = Color(0xFF1E254D);
  static const Color cellClosedHighlight = Color(0xFF283164);
  static const Color cellClosedBorder = Color(0xFF33407E);
  static const Color cellRevealed = Color(0xFF0E1329);
  static const Color cellRevealedBorder = Color(0xFF1B2246);

  // Neon vurgu renkleri
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonIndigo = Color(0xFF6C63FF);
  static const Color neonPurple = Color(0xFFD500F9);
  static const Color neonGreen = Color(0xFF76FF03);
  static const Color neonRed = Color(0xFFFF1744);
  static const Color neonOrange = Color(0xFFFF9100);
  static const Color neonTeal = Color(0xFF1DE9B6);
  static const Color neonYellow = Color(0xFFFFEA00);

  // Metin renkleri
  static const Color textPrimary = Color(0xFFECEFF1);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textMuted = Color(0xFF546E7A);

  /// Komşu mayın sayısına göre neon rakam rengi döner.
  static Color numberColor(int neighborMines) {
    switch (neighborMines) {
      case 1:
        return neonCyan;
      case 2:
        return neonGreen;
      case 3:
        return neonRed;
      case 4:
        return neonPurple;
      case 5:
        return neonOrange;
      case 6:
        return neonTeal;
      case 7:
        return textPrimary;
      case 8:
        return textSecondary;
      default:
        return textMuted;
    }
  }
}

