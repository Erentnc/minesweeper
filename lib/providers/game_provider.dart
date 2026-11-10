import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/models/cell_model.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/models/game_state.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';

/// Seçili zorluk yapılandırmasını tutar.
class SelectedDifficultyNotifier extends Notifier<DifficultyConfig> {
  @override
  DifficultyConfig build() => DifficultyConfig.easy;

  void select(DifficultyConfig config) {
    state = config;
  }
}

final selectedDifficultyProvider =
    NotifierProvider<SelectedDifficultyNotifier, DifficultyConfig>(
  SelectedDifficultyNotifier.new,
);

/// Aktif oyunun tüm tahta mantığını, ilk tıklama güvenliğini, bayrakları
/// ve zamanlayıcısını yönetir.
class GameNotifier extends Notifier<GameState> {
  Timer? _timer;
  final Random _random = Random();

  @override
  GameState build() {
    ref.onDispose(_stopTimer);
    final config = ref.watch(selectedDifficultyProvider);
    _stopTimer();
    return _createInitialState(config);
  }

  /// Mevcut zorluk ayarlarıyla yeni bir tahta başlatır.
  void resetGame() {
    _stopTimer();
    state = _createInitialState(state.config);
  }

  /// Kazma ve bayrak koyma modları arasında geçiş yapar.
  void toggleInputMode() {
    if (state.isGameOver) return;
    final nextMode =
        state.inputMode == InputMode.dig ? InputMode.flag : InputMode.dig;
    state = state.copyWith(inputMode: nextMode);
  }

  /// Hücreye kısa dokunuş veya sol tık işlemini yönetir.
  void onCellTap(int row, int col) {
    if (!_isInBounds(row, col) || state.isGameOver) return;

    final cell = state.grid[row][col];
    if (cell.isRevealed) {
      _chordReveal(row, col);
      return;
    }

    if (state.inputMode == InputMode.flag) {
      toggleFlag(row, col);
    } else {
      revealCell(row, col);
    }
  }

  /// Uzun basma veya sağ tık ile bayrak koyma/kaldırma işlemini yapar.
  void onCellSecondaryAction(int row, int col) {
    if (!_isInBounds(row, col) || state.isGameOver) return;
    final cell = state.grid[row][col];
    if (!cell.isRevealed) {
      toggleFlag(row, col);
    }
  }

  /// Hücredeki bayrağı açıp kapatır.
  void toggleFlag(int row, int col) {
    if (!_isInBounds(row, col) || state.isGameOver) return;

    final cell = state.grid[row][col];
    if (cell.isRevealed) return;

    final updatedGrid = _cloneGrid(state.grid);
    final nextFlagged = !cell.isFlagged;
    updatedGrid[row][col] = cell.copyWith(isFlagged: nextFlagged);

    final nextFlaggedCount =
        nextFlagged ? state.flaggedCount + 1 : state.flaggedCount - 1;

    state = state.copyWith(
      grid: updatedGrid,
      flaggedCount: nextFlaggedCount,
      lastRevealCount: 0,
    );
  }

  /// Hücreyi açar; ilk tıklama güvenliği aktifse mayınları ilk hamleye göre
  /// güvenli biçimde yerleştirir ve boş alanları iteratif BFS ile açar.
  void revealCell(int row, int col) {
    if (!_isInBounds(row, col) || state.isGameOver) return;

    var workingGrid = _cloneGrid(state.grid);
    final tapped = workingGrid[row][col];
    if (tapped.isRevealed || tapped.isFlagged) return;

    var placedNow = state.minesPlaced;
    if (!placedNow) {
      workingGrid = _populateMines(
        workingGrid,
        state.config,
        safeRow: row,
        safeCol: col,
      );
      placedNow = true;
    }

    final cell = workingGrid[row][col];
    if (cell.isMine) {
      _handleMineHit(
        [cell],
        workingGrid: workingGrid,
        originRow: row,
        originCol: col,
      );
      return;
    }

    final newlyRevealed = _floodFillSafeCells(workingGrid, [(row, col)]);
    _commitSafeReveal(
      workingGrid,
      newlyRevealed,
      minesPlaced: placedNow,
      originRow: row,
      originCol: col,
    );
  }

  /// Testlerde deterministik senaryolar kurmak için önceden tanımlanmış bir ızgara yükler.
  @visibleForTesting
  void loadTestBoard({
    required DifficultyConfig config,
    required List<List<CellModel>> grid,
    bool minesPlaced = true,
  }) {
    _stopTimer();
    state = GameState(
      config: config,
      grid: _cloneGrid(grid),
      status: GameStatus.idle,
      minesPlaced: minesPlaced,
    );
  }

  void _chordReveal(int row, int col) {
    final cell = state.grid[row][col];
    if (!cell.isRevealed || cell.neighborMines == 0) return;

    final neighbors = _neighborsOf(row, col);
    final adjacentFlags = neighbors.where((n) => n.isFlagged).length;
    if (adjacentFlags != cell.neighborMines) return;

    final targets = neighbors
        .where((n) => !n.isRevealed && !n.isFlagged)
        .toList(growable: false);
    if (targets.isEmpty) return;

    final hitMines = targets.where((n) => n.isMine).toList(growable: false);
    if (hitMines.isNotEmpty) {
      _handleMineHit(
        hitMines,
        workingGrid: _cloneGrid(state.grid),
        originRow: hitMines.first.row,
        originCol: hitMines.first.col,
      );
      return;
    }

    final updatedGrid = _cloneGrid(state.grid);
    final seeds = targets.map((n) => (n.row, n.col)).toList(growable: false);
    final newlyRevealed = _floodFillSafeCells(updatedGrid, seeds);
    _commitSafeReveal(
      updatedGrid,
      newlyRevealed,
      minesPlaced: state.minesPlaced,
      originRow: row,
      originCol: col,
    );
  }

  void _commitSafeReveal(
    List<List<CellModel>> updatedGrid,
    int newlyRevealed, {
    required bool minesPlaced,
    required int originRow,
    required int originCol,
  }) {
    final totalSafeRevealed = state.revealedSafeCount + newlyRevealed;

    if (totalSafeRevealed >= state.totalSafeCells) {
      _stopTimer();
      var autoFlaggedMines = 0;

      for (var r = 0; r < updatedGrid.length; r++) {
        for (var c = 0; c < updatedGrid[r].length; c++) {
          final cell = updatedGrid[r][c];
          if (cell.isMine) {
            if (!cell.isFlagged) {
              updatedGrid[r][c] = cell.copyWith(isFlagged: true);
            }
            autoFlaggedMines++;
          }
        }
      }

      state = state.copyWith(
        grid: updatedGrid,
        status: GameStatus.won,
        revealedSafeCount: totalSafeRevealed,
        flaggedCount: autoFlaggedMines,
        minesPlaced: minesPlaced,
        lastActionRow: originRow,
        lastActionCol: originCol,
        lastRevealCount: newlyRevealed,
      );
      return;
    }

    if (state.status == GameStatus.idle) {
      _startTimer();
    }

    state = state.copyWith(
      grid: updatedGrid,
      status: GameStatus.playing,
      revealedSafeCount: totalSafeRevealed,
      minesPlaced: minesPlaced,
      lastActionRow: originRow,
      lastActionCol: originCol,
      lastRevealCount: newlyRevealed,
    );
  }

  void _handleMineHit(
    List<CellModel> explodedMines, {
    required List<List<CellModel>> workingGrid,
    required int originRow,
    required int originCol,
  }) {
    _stopTimer();
    final explodedCoords = {
      for (final mine in explodedMines) (mine.row, mine.col),
    };

    for (var r = 0; r < workingGrid.length; r++) {
      for (var c = 0; c < workingGrid[r].length; c++) {
        final cell = workingGrid[r][c];
        if (explodedCoords.contains((r, c))) {
          workingGrid[r][c] = cell.copyWith(
            isRevealed: true,
            isExploded: true,
          );
        } else if (cell.isMine && !cell.isFlagged) {
          workingGrid[r][c] = cell.copyWith(isRevealed: true);
        }
      }
    }

    state = state.copyWith(
      grid: workingGrid,
      status: GameStatus.lost,
      minesPlaced: true,
      lastActionRow: originRow,
      lastActionCol: originCol,
      lastRevealCount: 0,
    );
  }

  /// İteratif BFS kullanarak 0 komşulu tüm bağlantılı güvenli hücreleri açar.
  int _floodFillSafeCells(
    List<List<CellModel>> grid,
    List<(int, int)> initialSeeds,
  ) {
    final queue = Queue<(int, int)>.from(initialSeeds);
    var revealedCount = 0;

    while (queue.isNotEmpty) {
      final (r, c) = queue.removeFirst();
      if (!_isInBounds(r, c)) continue;

      final current = grid[r][c];
      if (current.isRevealed || current.isFlagged || current.isMine) continue;

      grid[r][c] = current.copyWith(isRevealed: true);
      revealedCount++;

      if (current.neighborMines == 0) {
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = r + dr;
            final nc = c + dc;
            if (_isInBounds(nr, nc) &&
                !grid[nr][nc].isRevealed &&
                !grid[nr][nc].isFlagged &&
                !grid[nr][nc].isMine) {
              queue.add((nr, nc));
            }
          }
        }
      }
    }

    return revealedCount;
  }

  GameState _createInitialState(DifficultyConfig config) {
    final rows = config.rows;
    final cols = config.cols;
    final firstClickSafe = ref.read(settingsProvider).firstClickSafety;

    var grid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => CellModel(row: r, col: c),
      ),
    );

    if (!firstClickSafe) {
      grid = _populateMines(grid, config);
    }

    return GameState(
      config: config,
      grid: grid,
      status: GameStatus.idle,
      inputMode: InputMode.dig,
      minesPlaced: !firstClickSafe,
    );
  }

  /// Mayınları tahtaya dağıtır ve komşu sayılarını hesaplar.
  /// [safeRow] ve [safeCol] verilirse 3×3 güvenli bölge (sığmıyorsa en az
  /// tıklanan hücre) mayından arındırılır.
  List<List<CellModel>> _populateMines(
    List<List<CellModel>> grid,
    DifficultyConfig config, {
    int? safeRow,
    int? safeCol,
  }) {
    final rows = config.rows;
    final cols = config.cols;
    final targetMines = config.mineCount.clamp(0, rows * cols - 1);

    final outsideNeighborhood = <(int, int)>[];
    final outsideSafeCell = <(int, int)>[];

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (safeRow == null || safeCol == null) {
          outsideNeighborhood.add((r, c));
          continue;
        }
        final isTappedCell = r == safeRow && c == safeCol;
        if (!isTappedCell) {
          outsideSafeCell.add((r, c));
        }
        final in3x3Zone =
            (r - safeRow).abs() <= 1 && (c - safeCol).abs() <= 1;
        if (!in3x3Zone) {
          outsideNeighborhood.add((r, c));
        }
      }
    }

    final candidates = outsideNeighborhood.length >= targetMines
        ? outsideNeighborhood
        : outsideSafeCell;
    candidates.shuffle(_random);

    final mineSet = candidates.take(targetMines).toSet();

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final isMine = mineSet.contains((r, c));
        grid[r][c] = grid[r][c].copyWith(isMine: isMine, neighborMines: 0);
      }
    }

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (grid[r][c].isMine) continue;
        var count = 0;
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = r + dr;
            final nc = c + dc;
            if (nr >= 0 &&
                nr < rows &&
                nc >= 0 &&
                nc < cols &&
                grid[nr][nc].isMine) {
              count++;
            }
          }
        }
        grid[r][c] = grid[r][c].copyWith(neighborMines: count);
      }
    }

    return grid;
  }

  List<CellModel> _neighborsOf(int row, int col) {
    final neighbors = <CellModel>[];
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (_isInBounds(nr, nc)) {
          neighbors.add(state.grid[nr][nc]);
        }
      }
    }
    return neighbors;
  }

  bool _isInBounds(int row, int col) {
    return row >= 0 &&
        row < state.config.rows &&
        col >= 0 &&
        col < state.config.cols;
  }

  List<List<CellModel>> _cloneGrid(List<List<CellModel>> source) {
    return [
      for (final row in source) [...row],
    ];
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

final gameProvider = NotifierProvider.autoDispose<GameNotifier, GameState>(
  GameNotifier.new,
);
