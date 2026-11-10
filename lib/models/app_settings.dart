import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';

/// Seçilebilir neon vurgu renk temaları.
enum NeonThemeAccent {
  cyan(
    label: 'Siber Mavi',
    primary: AppColors.neonCyan,
    secondary: AppColors.neonIndigo,
  ),
  emerald(
    label: 'Matrix Yeşili',
    primary: AppColors.neonGreen,
    secondary: AppColors.neonTeal,
  ),
  synthwave(
    label: 'Synthwave',
    primary: AppColors.neonPurple,
    secondary: Color(0xFFFF4081),
  ),
  amber(
    label: 'Güneş Enerjisi',
    primary: AppColors.neonOrange,
    secondary: AppColors.neonYellow,
  );

  const NeonThemeAccent({
    required this.label,
    required this.primary,
    required this.secondary,
  });

  final String label;
  final Color primary;
  final Color secondary;

  static NeonThemeAccent fromName(String? value) {
    return NeonThemeAccent.values.firstWhere(
      (item) => item.name == value,
      orElse: () => NeonThemeAccent.cyan,
    );
  }
}

/// Kullanıcının tercihlerini tutan değişmez (immutable) ayarlar modeli.
@immutable
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.firstClickSafety = true,
    this.accentTheme = NeonThemeAccent.cyan,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool firstClickSafety;
  final NeonThemeAccent accentTheme;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? firstClickSafety,
    NeonThemeAccent? accentTheme,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      firstClickSafety: firstClickSafety ?? this.firstClickSafety,
      accentTheme: accentTheme ?? this.accentTheme,
    );
  }

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'firstClickSafety': firstClickSafety,
        'accentTheme': accentTheme.name,
      };

  String encode() => jsonEncode(toJson());

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      firstClickSafety: json['firstClickSafety'] as bool? ?? true,
      accentTheme: NeonThemeAccent.fromName(json['accentTheme'] as String?),
    );
  }

  static AppSettings decode(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppSettings.fromJson(map);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.soundEnabled == soundEnabled &&
        other.hapticsEnabled == hapticsEnabled &&
        other.firstClickSafety == firstClickSafety &&
        other.accentTheme == accentTheme;
  }

  @override
  int get hashCode => Object.hash(
        soundEnabled,
        hapticsEnabled,
        firstClickSafety,
        accentTheme,
      );
}

