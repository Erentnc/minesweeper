import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/services/storage_service.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/models/game_stats.dart';

/// Kalıcı oyun istatistiklerini ve rekor süreleri yönetir.
class StatsNotifier extends Notifier<GameStats> {
  static const _storageKey = 'neon_minesweeper_stats_v1';

  @override
  GameStats build() {
    final storage = ref.read(storageServiceProvider);
    final rawSync = storage.readStringSync(_storageKey);
    if (rawSync != null) {
      try {
        return GameStats.decode(rawSync);
      } catch (_) {}
    }

    _hydrateAsync(storage);
    return const GameStats();
  }

  Future<void> _hydrateAsync(StorageService storage) async {
    final raw = await storage.readString(_storageKey);
    if (raw == null || !ref.mounted) return;
    try {
      state = GameStats.decode(raw);
    } catch (_) {}
  }

  Future<void> _persist(GameStats next) async {
    state = next;
    await ref.read(storageServiceProvider).writeString(
          _storageKey,
          next.encode(),
        );
  }

  /// Kazanılan oyunu kaydeder ve bu zorlukta yeni rekor kırılıp kırılmadığını döner.
  Future<bool> recordWin({
    required GameDifficulty difficulty,
    required int elapsedSeconds,
  }) async {
    final prevDiff = state.statsFor(difficulty);
    final canTrackRecord = difficulty != GameDifficulty.custom;
    final previousBest = prevDiff.bestTimeSeconds;
    final isNewRecord = canTrackRecord &&
        (previousBest == null || elapsedSeconds < previousBest);

    final nextBest = canTrackRecord
        ? (isNewRecord ? elapsedSeconds : previousBest)
        : previousBest;

    final updatedDiff = prevDiff.copyWith(
      gamesPlayed: prevDiff.gamesPlayed + 1,
      gamesWon: prevDiff.gamesWon + 1,
      bestTimeSeconds: () => nextBest,
      totalWinTimeSeconds: prevDiff.totalWinTimeSeconds + elapsedSeconds,
    );

    final nextStreak = state.currentStreak + 1;
    final nextBestStreak =
        nextStreak > state.bestStreak ? nextStreak : state.bestStreak;

    final updatedMap = Map<GameDifficulty, DifficultyStats>.from(
      state.byDifficulty,
    )..[difficulty] = updatedDiff;

    await _persist(
      state.copyWith(
        byDifficulty: updatedMap,
        currentStreak: nextStreak,
        bestStreak: nextBestStreak,
      ),
    );

    return isNewRecord;
  }

  /// Kaybedilen oyunu kaydeder ve aktif kazanma serisini sıfırlar.
  Future<void> recordLoss({required GameDifficulty difficulty}) async {
    final prevDiff = state.statsFor(difficulty);
    final updatedDiff = prevDiff.copyWith(
      gamesPlayed: prevDiff.gamesPlayed + 1,
    );

    final updatedMap = Map<GameDifficulty, DifficultyStats>.from(
      state.byDifficulty,
    )..[difficulty] = updatedDiff;

    await _persist(
      state.copyWith(
        byDifficulty: updatedMap,
        currentStreak: 0,
      ),
    );
  }

  /// Tüm kayıtlı istatistikleri sıfırlar.
  Future<void> resetStats() async {
    state = const GameStats();
    await ref.read(storageServiceProvider).remove(_storageKey);
  }
}

final statsProvider = NotifierProvider<StatsNotifier, GameStats>(
  StatsNotifier.new,
);

