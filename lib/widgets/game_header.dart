import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/models/game_state.dart';

/// Oyun ekranının üst kısmında kalan mayın sayacı, canlı emoji göstergesi,
/// ilerleme çubuğu, süre ve Kaz/Bayrak mod geçişini gösteren bilgi paneli.
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.gameState,
    required this.onReset,
    required this.onToggleInputMode,
    this.isPressingCell = false,
  });

  final GameState gameState;
  final VoidCallback onReset;
  final VoidCallback onToggleInputMode;
  final bool isPressingCell;

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isFlagMode = gameState.inputMode == InputMode.flag;
    final statusColor = switch (gameState.status) {
      GameStatus.won => AppColors.neonGreen,
      GameStatus.lost => AppColors.neonRed,
      GameStatus.playing => AppColors.neonCyan,
      GameStatus.idle => gameState.config.accentColor,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatCounter(
                    icon: Icons.flag_rounded,
                    label: AppStrings.remainingMines,
                    value: gameState.remainingMines.toString().padLeft(2, '0'),
                    color: gameState.remainingMines < 0
                        ? AppColors.neonOrange
                        : AppColors.neonRed,
                  ),
                  _EmojiStatusButton(
                    status: gameState.status,
                    isPressingCell: isPressingCell,
                    color: statusColor,
                    onTap: onReset,
                  ),
                  _StatCounter(
                    icon: Icons.timer_outlined,
                    label: AppStrings.elapsedTime,
                    value: _formatTime(gameState.elapsedSeconds),
                    color: AppColors.neonCyan,
                    alignEnd: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              _NeonProgressBar(
                progress: gameState.progress,
                color: statusColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.sm + 4),
        Row(
          children: [
            Expanded(
              child: _ModeToggleBar(
                isFlagMode: isFlagMode,
                onToggle: onToggleInputMode,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm + 4,
                vertical: AppDimensions.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: AppColors.cellClosedBorder.withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                '${gameState.revealedSafeCount}/${gameState.totalSafeCells}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NeonProgressBar extends StatelessWidget {
  const _NeonProgressBar({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 4,
        width: double.infinity,
        color: AppColors.background.withValues(alpha: 0.7),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    AppColors.neonIndigo,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.7),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCounter extends StatelessWidget {
  const _StatCounter({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!alignEnd) ...[
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppDimensions.sm),
        ],
        Column(
          crossAxisAlignment:
              alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: color,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (alignEnd) ...[
          const SizedBox(width: AppDimensions.sm),
          Icon(icon, color: color, size: 22),
        ],
      ],
    );
  }
}

class _EmojiStatusButton extends StatelessWidget {
  const _EmojiStatusButton({
    required this.status,
    required this.isPressingCell,
    required this.color,
    required this.onTap,
  });

  final GameStatus status;
  final bool isPressingCell;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final emoji = switch (status) {
      GameStatus.won => '😎',
      GameStatus.lost => '😵',
      _ => isPressingCell ? '😮' : '🙂',
    };

    return Tooltip(
      message: AppStrings.restartGame,
      child: Material(
        color: color.withValues(alpha: 0.14),
        shape: CircleBorder(
          side: BorderSide(color: color.withValues(alpha: 0.7), width: 1.6),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              child: Text(
                emoji,
                key: ValueKey(emoji),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggleBar extends StatelessWidget {
  const _ModeToggleBar({
    required this.isFlagMode,
    required this.onToggle,
  });

  final bool isFlagMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.cellClosedBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeOption(
              icon: Icons.touch_app_rounded,
              label: AppStrings.digMode,
              selected: !isFlagMode,
              activeColor: AppColors.neonCyan,
              onTap: isFlagMode ? onToggle : null,
            ),
          ),
          Expanded(
            child: _ModeOption(
              icon: Icons.flag_rounded,
              label: AppStrings.flagMode,
              selected: isFlagMode,
              activeColor: AppColors.neonOrange,
              onTap: !isFlagMode ? onToggle : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm + 2),
          border: selected
              ? Border.all(color: activeColor.withValues(alpha: 0.65))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? activeColor : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? activeColor : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
