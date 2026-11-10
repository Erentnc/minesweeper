import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/models/game_stats.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:mayin_tarlasi/providers/stats_provider.dart';
import 'package:mayin_tarlasi/widgets/neon_background.dart';
import 'package:mayin_tarlasi/widgets/neon_button.dart';

/// Oyuncunun tüm zamanlardaki istatistiklerini ve rekor sürelerini gösterir.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  String _formatDuration(int? seconds) {
    if (seconds == null) return '--:--';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.resetStatsConfirmTitle),
        content: const Text(
          AppStrings.resetStatsConfirmBody,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              AppStrings.confirmReset,
              style: TextStyle(color: AppColors.neonRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(statsProvider.notifier).resetStats();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final accent = ref.watch(settingsProvider).accentTheme;

    return NeonBackground(
      accentColor: accent.primary,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(AppStrings.statsTitle),
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
                    Row(
                      children: [
                        Expanded(
                          child: _OverviewCard(
                            label: AppStrings.totalGames,
                            value: '${stats.totalPlayed}',
                            icon: Icons.grid_view_rounded,
                            color: accent.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: _OverviewCard(
                            label: AppStrings.winRate,
                            value:
                                '%${stats.overallWinRatePercent.toStringAsFixed(0)}',
                            icon: Icons.pie_chart_rounded,
                            color: AppColors.neonGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Expanded(
                          child: _OverviewCard(
                            label: AppStrings.currentStreak,
                            value: '${stats.currentStreak}',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.neonOrange,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: _OverviewCard(
                            label: AppStrings.bestStreak,
                            value: '${stats.bestStreak}',
                            icon: Icons.emoji_events_rounded,
                            color: AppColors.neonYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    for (final preset in DifficultyConfig.presets) ...[
                      _DifficultyStatsCard(
                        title: preset.label,
                        accentColor: preset.accentColor,
                        stats: stats.statsFor(preset.difficulty),
                        formatDuration: _formatDuration,
                        showRecords: true,
                      ),
                      const SizedBox(height: AppDimensions.md),
                    ],
                    _DifficultyStatsCard(
                      title: AppStrings.custom,
                      accentColor: AppColors.neonPurple,
                      stats: stats.statsFor(GameDifficulty.custom),
                      formatDuration: _formatDuration,
                      showRecords: false,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    NeonButton(
                      label: AppStrings.resetStats,
                      icon: Icons.delete_outline_rounded,
                      accentColor: AppColors.neonRed,
                      onPressed: stats.totalPlayed > 0
                          ? () => _confirmReset(context, ref)
                          : null,
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppDimensions.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyStatsCard extends StatelessWidget {
  const _DifficultyStatsCard({
    required this.title,
    required this.accentColor,
    required this.stats,
    required this.formatDuration,
    required this.showRecords,
  });

  final String title;
  final Color accentColor;
  final DifficultyStats stats;
  final String Function(int?) formatDuration;
  final bool showRecords;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: accentColor,
                ),
              ),
              Text(
                '${stats.gamesWon}/${stats.gamesPlayed} Kazanma (%${stats.winRatePercent.toStringAsFixed(0)})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (showRecords) ...[
            const SizedBox(height: AppDimensions.sm + 2),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: AppStrings.bestTimeLabel,
                    value: formatDuration(stats.bestTimeSeconds),
                    color: AppColors.neonYellow,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: _MiniStat(
                    label: 'ORTALAMA',
                    value: formatDuration(stats.averageWinTimeSeconds),
                    color: AppColors.neonCyan,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm + 4,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

