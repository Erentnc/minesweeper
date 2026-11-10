import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/models/app_settings.dart';

/// Uygulamanın koyu neon Material 3 teması.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => darkThemeFor(NeonThemeAccent.cyan);

  static ThemeData darkThemeFor(NeonThemeAccent accent) {
    final colorScheme = ColorScheme.dark(
      primary: accent.primary,
      secondary: accent.secondary,
      tertiary: AppColors.neonPurple,
      surface: AppColors.surface,
      error: AppColors.neonRed,
      onPrimary: AppColors.background,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (BuildContext context) {
          return const Icon(Icons.arrow_back_ios_new_rounded, size: 20);
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(
            color: accent.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent.primary,
        inactiveTrackColor: AppColors.cellClosed,
        thumbColor: accent.primary,
        overlayColor: accent.primary.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.surfaceElevated,
        valueIndicatorTextStyle: TextStyle(
          color: accent.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.primary.withValues(alpha: 0.32);
          }
          return AppColors.cellClosed;
        }),
      ),
    );
  }
}
