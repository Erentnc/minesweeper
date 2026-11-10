import 'package:flutter/services.dart';

/// Oyun içi dokunsal titreşim (haptic feedback) yardımcıları.
class HapticHelper {
  HapticHelper._();

  static Future<void> onReveal({required bool enabled}) async {
    if (!enabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> onFlag({required bool enabled}) async {
    if (!enabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> onExplosion({required bool enabled}) async {
    if (!enabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  static Future<void> onWin({required bool enabled}) async {
    if (!enabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}

