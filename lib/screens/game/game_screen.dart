import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/animations/confetti_animation.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/core/router/app_router.dart';
import 'package:mayin_tarlasi/core/services/sound_service.dart';
import 'package:mayin_tarlasi/core/utils/haptic_helper.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/models/game_state.dart';
import 'package:mayin_tarlasi/providers/game_provider.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:mayin_tarlasi/providers/stats_provider.dart';
import 'package:mayin_tarlasi/widgets/game_board.dart';
import 'package:mayin_tarlasi/widgets/game_header.dart';
import 'package:mayin_tarlasi/widgets/game_result_dialog.dart';
import 'package:mayin_tarlasi/widgets/neon_background.dart';

/// Tüm zorluk seviyelerini parametrik olarak çalıştıran tek oyun ekranı.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _isPressingCell = false;
  bool _isNewRecord = false;
  Timer? _resultDialogTimer;

  @override
  void dispose() {
    _resultDialogTimer?.cancel();
    super.dispose();
  }

  void _handleReset() {
    _resultDialogTimer?.cancel();
    if (_isPressingCell || _isNewRecord) {
      setState(() {
        _isPressingCell = false;
        _isNewRecord = false;
      });
    }
    ref.read(gameProvider.notifier).resetGame();
  }

  void _playSound(SoundEffect effect) {
    final settings = ref.read(settingsProvider);
    if (settings.soundEnabled) {
      ref.read(soundServiceProvider).play(effect);
    }
  }

  Future<void> _onGameStateChanged(GameState? previous, GameState next) async {
    if (previous == null) return;
    final settings = ref.read(settingsProvider);

    if (previous.status != next.status && next.status == GameStatus.won) {
      _playSound(SoundEffect.win);
      unawaited(HapticHelper.onWin(enabled: settings.hapticsEnabled));

      final isRecord = await ref.read(statsProvider.notifier).recordWin(
            difficulty: next.config.difficulty,
            elapsedSeconds: next.elapsedSeconds,
          );
      if (!mounted || ref.read(gameProvider).status != GameStatus.won) {
        return;
      }
      setState(() {
        _isNewRecord = isRecord;
      });
      _scheduleResultDialog(GameStatus.won);
      return;
    }

    if (previous.status != next.status && next.status == GameStatus.lost) {
      _playSound(SoundEffect.explosion);
      unawaited(HapticHelper.onExplosion(enabled: settings.hapticsEnabled));
      unawaited(
        ref.read(statsProvider.notifier).recordLoss(
              difficulty: next.config.difficulty,
            ),
      );
      _scheduleResultDialog(GameStatus.lost);
      return;
    }

    if (next.revealedSafeCount > previous.revealedSafeCount) {
      _playSound(
        next.lastRevealCount > 1 ? SoundEffect.cascade : SoundEffect.reveal,
      );
      unawaited(HapticHelper.onReveal(enabled: settings.hapticsEnabled));
      return;
    }

    if (next.flaggedCount != previous.flaggedCount &&
        next.status == previous.status) {
      _playSound(SoundEffect.flag);
      unawaited(HapticHelper.onFlag(enabled: settings.hapticsEnabled));
    }
  }

  void _scheduleResultDialog(GameStatus targetStatus) {
    _resultDialogTimer?.cancel();
    final delay = targetStatus == GameStatus.lost
        ? const Duration(milliseconds: 560)
        : const Duration(milliseconds: 450);

    _resultDialogTimer = Timer(delay, () {
      if (!mounted) return;
      final currentState = ref.read(gameProvider);
      if (currentState.status != targetStatus) return;
      _showResultDialog(currentState);
    });
  }

  void _showResultDialog(GameState gameState) {
    final isWin = gameState.status == GameStatus.won;
    final stats = ref.read(statsProvider);
    final bestTime = gameState.config.difficulty == GameDifficulty.custom
        ? null
        : stats.statsFor(gameState.config.difficulty).bestTimeSeconds;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameResultDialog(
        isWin: isWin,
        elapsedSeconds: gameState.elapsedSeconds,
        config: gameState.config,
        isNewRecord: _isNewRecord,
        bestTimeSeconds: bestTime,
        onPlayAgain: () {
          Navigator.of(dialogContext).pop();
          _handleReset();
        },
        onChangeDifficulty: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).popUntil(
            (route) =>
                route.settings.name == AppRoutes.difficulty || route.isFirst,
          );
        },
        onMainMenu: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameProvider, _onGameStateChanged);

    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return NeonBackground(
      accentColor: gameState.config.accentColor,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                '${gameState.config.label} • ${gameState.config.rows}×${gameState.config.cols}',
              ),
              actions: [
                IconButton(
                  tooltip: AppStrings.restartGame,
                  onPressed: _handleReset,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.boardMaxWidth + AppDimensions.lg,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
                    child: Column(
                      children: [
                        GameHeader(
                          gameState: gameState,
                          isPressingCell: _isPressingCell,
                          onReset: _handleReset,
                          onToggleInputMode: notifier.toggleInputMode,
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Expanded(
                          child: GameBoard(
                            gameState: gameState,
                            onCellTap: notifier.onCellTap,
                            onCellSecondaryAction:
                                notifier.onCellSecondaryAction,
                            onPressChanged: (pressing) {
                              if (_isPressingCell != pressing) {
                                setState(() {
                                  _isPressingCell = pressing;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        const Text(
                          AppStrings.gameControlsHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (gameState.status == GameStatus.won)
            const Positioned.fill(
              child: ConfettiOverlay(),
            ),
        ],
      ),
    );
  }
}
