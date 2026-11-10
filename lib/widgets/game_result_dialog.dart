import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/widgets/neon_button.dart';

/// Kazanma ve kaybetme durumlarını tek bir yerden yöneten ortak sonuç diyalogu.
class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.isWin,
    required this.elapsedSeconds,
    required this.config,
    required this.onPlayAgain,
    required this.onChangeDifficulty,
    required this.onMainMenu,
    this.isNewRecord = false,
    this.bestTimeSeconds,
  });

  final bool isWin;
  final int elapsedSeconds;
  final DifficultyConfig config;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeDifficulty;
  final VoidCallback onMainMenu;
  final bool isNewRecord;
  final int? bestTimeSeconds;

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isWin ? AppColors.neonGreen : AppColors.neonRed;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(AppDimensions.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(color: accentColor.withValues(alpha: 0.6), width: 1.5),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.14),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isWin ? Icons.emoji_events_rounded : Icons.crisis_alert_rounded,
                color: accentColor,
                size: 36,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            if (isWin && isNewRecord) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonYellow.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.neonYellow.withValues(alpha: 0.8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: AppColors.neonYellow,
                    ),
                    SizedBox(width: 4),
                    Text(
                      AppStrings.newRecordBadge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.neonYellow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
            ],
            Text(
              isWin ? AppStrings.winTitle : AppStrings.lossTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: accentColor,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              isWin ? AppStrings.winMessage : AppStrings.lossMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm + 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: AppColors.cellClosedBorder.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ResultStat(
                    label: 'SEVİYE',
                    value: config.label,
                    color: config.accentColor,
                  ),
                  _ResultStat(
                    label: AppStrings.elapsedTime,
                    value: _formatDuration(elapsedSeconds),
                    color: AppColors.neonCyan,
                  ),
                  if (bestTimeSeconds != null)
                    _ResultStat(
                      label: AppStrings.bestTimeLabel,
                      value: _formatDuration(bestTimeSeconds!),
                      color: AppColors.neonYellow,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            NeonButton(
              label: AppStrings.playAgain,
              icon: Icons.replay_rounded,
              accentColor: accentColor,
              isPrimary: true,
              height: 48,
              onPressed: onPlayAgain,
            ),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onChangeDifficulty,
                    child: const Text(
                      AppStrings.changeDifficulty,
                      style: TextStyle(color: AppColors.neonCyan),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onMainMenu,
                    child: const Text(
                      AppStrings.mainMenu,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: color,
          ),
        ),
      ],
    );
  }
}
