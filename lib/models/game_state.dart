import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:mayin_tarlasi/models/cell_model.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';

/// Oyunun mevcut yaşam döngüsü durumu.
enum GameStatus {
  /// Tahta hazır, henüz ilk hücre açılmadı.
  idle,

  /// Oyun aktif olarak devam ediyor ve sayaç çalışıyor.
  playing,

  /// Tüm güvenli hücreler açıldı, oyun kazanıldı.
  won,

  /// Bir mayına basıldı, oyun kaybedildi.
  lost,
}

/// Hücreye tek dokunuşta uygulanacak işlem modu.
enum InputMode {
  /// Hücreyi açar.
  dig,

  /// Hücreye bayrak koyar veya kaldırır.
  flag,
}

/// Tüm oyun tahtasının ve sayaçların değişmez (immutable) anlık görüntüsü.
@immutable
class GameState {
  const GameState({
    required this.config,
    required this.grid,
    this.status = GameStatus.idle,
    this.inputMode = InputMode.dig,
    this.elapsedSeconds = 0,
    this.flaggedCount = 0,
    this.revealedSafeCount = 0,
    this.minesPlaced = true,
    this.lastActionRow,
    this.lastActionCol,
    this.lastRevealCount = 0,
  });

  final DifficultyConfig config;
  final List<List<CellModel>> grid;
  final GameStatus status;
  final InputMode inputMode;
  final int elapsedSeconds;
  final int flaggedCount;
  final int revealedSafeCount;

  /// İlk tıklama güvenliği aktifken ilk açma hamlesine kadar `false` olur.
  final bool minesPlaced;

  /// Zincirleme açılış dalga animasyonu için son hamle koordinatları.
  final int? lastActionRow;
  final int? lastActionCol;

  /// Son açma hamlesinde açılan güvenli hücre sayısı (ses seçimi için).
  final int lastRevealCount;

  /// Toplam mayından yerleştirilen bayrak sayısı düşülerek hesaplanan kalan mayın.
  int get remainingMines => config.mineCount - flaggedCount;

  /// Açılması gereken toplam güvenli hücre sayısı.
  int get totalSafeCells => config.safeCells;

  /// Tamamlanma oranı (0.0 - 1.0).
  double get progress => totalSafeCells == 0
      ? 0.0
      : (revealedSafeCount / totalSafeCells).clamp(0.0, 1.0);

  /// Oyunun kazanılıp veya kaybedilip sonlandığını belirtir.
  bool get isGameOver =>
      status == GameStatus.won || status == GameStatus.lost;

  /// Son hamlenin merkezine olan Chebyshev mesafesini döner (animasyon dalgası için).
  int waveDistanceTo(int row, int col) {
    if (lastActionRow == null || lastActionCol == null) return 0;
    return math.max(
      (row - lastActionRow!).abs(),
      (col - lastActionCol!).abs(),
    );
  }

  /// Kayıp durumunda patlayan ilk mayın hücresini bulur.
  CellModel? get explodedCell {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isExploded) return cell;
      }
    }
    return null;
  }

  GameState copyWith({
    DifficultyConfig? config,
    List<List<CellModel>>? grid,
    GameStatus? status,
    InputMode? inputMode,
    int? elapsedSeconds,
    int? flaggedCount,
    int? revealedSafeCount,
    bool? minesPlaced,
    int? lastActionRow,
    int? lastActionCol,
    int? lastRevealCount,
  }) {
    return GameState(
      config: config ?? this.config,
      grid: grid ?? this.grid,
      status: status ?? this.status,
      inputMode: inputMode ?? this.inputMode,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      flaggedCount: flaggedCount ?? this.flaggedCount,
      revealedSafeCount: revealedSafeCount ?? this.revealedSafeCount,
      minesPlaced: minesPlaced ?? this.minesPlaced,
      lastActionRow: lastActionRow ?? this.lastActionRow,
      lastActionCol: lastActionCol ?? this.lastActionCol,
      lastRevealCount: lastRevealCount ?? this.lastRevealCount,
    );
  }
}
