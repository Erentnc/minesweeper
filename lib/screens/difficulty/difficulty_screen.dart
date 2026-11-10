import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/core/router/app_router.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/providers/game_provider.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:mayin_tarlasi/providers/stats_provider.dart';
import 'package:mayin_tarlasi/widgets/difficulty_card.dart';
import 'package:mayin_tarlasi/widgets/neon_background.dart';

/// Kullanıcının hazır veya özel zorluk seviyesini seçtiği ekran.
class DifficultyScreen extends ConsumerWidget {
  const DifficultyScreen({super.key});

  void _startPresetGame(
    BuildContext context,
    WidgetRef ref,
    DifficultyConfig config,
  ) {
    ref.read(selectedDifficultyProvider.notifier).select(config);
    Navigator.pushNamed(context, AppRoutes.game);
  }

  IconData _iconFor(GameDifficulty difficulty) {
    return switch (difficulty) {
      GameDifficulty.easy => Icons.spa_rounded,
      GameDifficulty.medium => Icons.bolt_rounded,
      GameDifficulty.hard => Icons.local_fire_department_rounded,
      GameDifficulty.custom => Icons.tune_rounded,
    };
  }

  String? _recordLabelFor(int? bestSeconds) {
    if (bestSeconds == null) return null;
    final m = (bestSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (bestSeconds % 60).toString().padLeft(2, '0');
    return 'Rekor $m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final accent = ref.watch(settingsProvider).accentTheme;

    return NeonBackground(
      accentColor: accent.secondary,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(AppStrings.selectDifficulty),
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
                    const Text(
                      AppStrings.selectDifficultyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    for (final preset in DifficultyConfig.presets) ...[
                      DifficultyCard(
                        title: preset.label,
                        subtitle: preset.subtitle,
                        gridLabel: '${preset.rows}×${preset.cols} Kare',
                        minesLabel: '${preset.mineCount} Mayın',
                        recordLabel: _recordLabelFor(
                          stats.statsFor(preset.difficulty).bestTimeSeconds,
                        ),
                        accentColor: preset.accentColor,
                        icon: _iconFor(preset.difficulty),
                        onTap: () => _startPresetGame(context, ref, preset),
                      ),
                      const SizedBox(height: AppDimensions.md),
                    ],
                    DifficultyCard(
                      title: AppStrings.custom,
                      subtitle:
                          'Tahta boyutunu ve mayın sayısını kendin belirle',
                      gridLabel:
                          '${AppDimensions.minCustomGridSize}×${AppDimensions.minCustomGridSize} - ${AppDimensions.maxCustomGridSize}×${AppDimensions.maxCustomGridSize}',
                      minesLabel: 'Esnek Mayın',
                      accentColor: AppColors.neonPurple,
                      icon: _iconFor(GameDifficulty.custom),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customSetup);
                      },
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
