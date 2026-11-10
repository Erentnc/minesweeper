import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';

/// Tek bir zorluk seviyesine ait oynanış istatistikleri.
@immutable
class DifficultyStats {
  const DifficultyStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.bestTimeSeconds,
    this.totalWinTimeSeconds = 0,
  });

  final int gamesPlayed;
  final int gamesWon;
  final int? bestTimeSeconds;
  final int totalWinTimeSeconds;

  double get winRatePercent =>
      gamesPlayed == 0 ? 0.0 : (gamesWon / gamesPlayed) * 100.0;

  int? get averageWinTimeSeconds =>
      gamesWon == 0 ? null : (totalWinTimeSeconds / gamesWon).round();

  DifficultyStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? Function()? bestTimeSeconds,
    int? totalWinTimeSeconds,
  }) {
    return DifficultyStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestTimeSeconds:
          bestTimeSeconds != null ? bestTimeSeconds() : this.bestTimeSeconds,
      totalWinTimeSeconds: totalWinTimeSeconds ?? this.totalWinTimeSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'bestTimeSeconds': bestTimeSeconds,
        'totalWinTimeSeconds': totalWinTimeSeconds,
      };

  factory DifficultyStats.fromJson(Map<String, dynamic> json) {
    return DifficultyStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      bestTimeSeconds: json['bestTimeSeconds'] as int?,
      totalWinTimeSeconds: json['totalWinTimeSeconds'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DifficultyStats &&
        other.gamesPlayed == gamesPlayed &&
        other.gamesWon == gamesWon &&
        other.bestTimeSeconds == bestTimeSeconds &&
        other.totalWinTimeSeconds == totalWinTimeSeconds;
  }

  @override
  int get hashCode => Object.hash(
        gamesPlayed,
        gamesWon,
        bestTimeSeconds,
        totalWinTimeSeconds,
      );
}

/// Oyuncunun tüm zorluk seviyelerindeki kalıcı istatistik özeti.
@immutable
class GameStats {
  const GameStats({
    this.byDifficulty = const {},
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  final Map<GameDifficulty, DifficultyStats> byDifficulty;
  final int currentStreak;
  final int bestStreak;

  DifficultyStats statsFor(GameDifficulty difficulty) {
    return byDifficulty[difficulty] ?? const DifficultyStats();
  }

  int get totalPlayed =>
      byDifficulty.values.fold(0, (sum, item) => sum + item.gamesPlayed);

  int get totalWon =>
      byDifficulty.values.fold(0, (sum, item) => sum + item.gamesWon);

  double get overallWinRatePercent =>
      totalPlayed == 0 ? 0.0 : (totalWon / totalPlayed) * 100.0;

  GameStats copyWith({
    Map<GameDifficulty, DifficultyStats>? byDifficulty,
    int? currentStreak,
    int? bestStreak,
  }) {
    return GameStats(
      byDifficulty: byDifficulty ?? this.byDifficulty,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'byDifficulty': {
          for (final entry in byDifficulty.entries)
            entry.key.name: entry.value.toJson(),
        },
      };

  String encode() => jsonEncode(toJson());

  factory GameStats.fromJson(Map<String, dynamic> json) {
    final rawMap = json['byDifficulty'] as Map<String, dynamic>? ?? {};
    final parsedMap = <GameDifficulty, DifficultyStats>{};

    for (final entry in rawMap.entries) {
      final difficulty = GameDifficulty.values.cast<GameDifficulty?>().firstWhere(
            (item) => item?.name == entry.key,
            orElse: () => null,
          );
      if (difficulty != null && entry.value is Map<String, dynamic>) {
        parsedMap[difficulty] =
            DifficultyStats.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    return GameStats(
      byDifficulty: parsedMap,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }

  static GameStats decode(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return GameStats.fromJson(map);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStats &&
        mapEquals(other.byDifficulty, byDifficulty) &&
        other.currentStreak == currentStreak &&
        other.bestStreak == bestStreak;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(byDifficulty.entries),
        currentStreak,
        bestStreak,
      );
}

