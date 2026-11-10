import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/models/app_settings.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:mayin_tarlasi/widgets/neon_background.dart';

/// Ses, titreşim, oynanış ve neon tema ayarlarını yöneten ekran.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final accent = settings.accentTheme;

    return NeonBackground(
      accentColor: accent.primary,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(AppStrings.settingsTitle),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SettingSwitchCard(
                      icon: Icons.volume_up_rounded,
                      title: AppStrings.soundEffectsLabel,
                      subtitle: AppStrings.soundEffectsDesc,
                      value: settings.soundEnabled,
                      accentColor: accent.primary,
                      onChanged: notifier.setSoundEnabled,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _SettingSwitchCard(
                      icon: Icons.vibration_rounded,
                      title: AppStrings.hapticsLabel,
                      subtitle: AppStrings.hapticsDesc,
                      value: settings.hapticsEnabled,
                      accentColor: accent.primary,
                      onChanged: notifier.setHapticsEnabled,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _SettingSwitchCard(
                      icon: Icons.verified_user_rounded,
                      title: AppStrings.firstClickSafetyLabel,
                      subtitle: AppStrings.firstClickSafetyDesc,
                      value: settings.firstClickSafety,
                      accentColor: AppColors.neonGreen,
                      onChanged: notifier.setFirstClickSafety,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: accent.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.palette_rounded,
                                color: accent.primary,
                                size: 22,
                              ),
                              const SizedBox(width: AppDimensions.sm),
                              const Text(
                                AppStrings.themeAccentLabel,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Wrap(
                            spacing: AppDimensions.sm,
                            runSpacing: AppDimensions.sm,
                            children: [
                              for (final option in NeonThemeAccent.values)
                                _ThemeOptionChip(
                                  accent: option,
                                  selected: settings.accentTheme == option,
                                  onTap: () => notifier.setAccentTheme(option),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingSwitchCard extends StatelessWidget {
  const _SettingSwitchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color accentColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm + 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: (value ? accentColor : AppColors.cellClosedBorder)
              .withValues(alpha: value ? 0.45 : 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionChip extends StatelessWidget {
  const _ThemeOptionChip({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final NeonThemeAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? accent.primary.withValues(alpha: 0.16)
              : AppColors.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: selected
                ? accent.primary
                : AppColors.cellClosedBorder.withValues(alpha: 0.6),
            width: selected ? 1.6 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accent.primary, accent.secondary],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              accent.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? accent.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

