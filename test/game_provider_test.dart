import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mayin_tarlasi/models/cell_model.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/models/game_state.dart';
import 'package:mayin_tarlasi/providers/game_provider.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testlerde deterministik ızgaralar oluşturmak için yardımcı fonksiyon.
List<List<CellModel>> buildDeterministicBoard(
  int size,
  Set<(int, int)> mineCoords,
) {
  final grid = List.generate(
    size,
    (r) => List.generate(
      size,
      (c) => CellModel(
        row: r,
        col: c,
        isMine: mineCoords.contains((r, c)),
      ),
    ),
  );

  for (var r = 0; r < size; r++) {
    for (var c = 0; c < size; c++) {
      if (grid[r][c].isMine) continue;
      var count = 0;
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = r + dr;
          final nc = c + dc;
          if (nr >= 0 &&
              nr < size &&
              nc >= 0 &&
              nc < size &&
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameNotifier', () {
    test('İlk tıklama güvenliği kapalıyken tahta başlangıçta mayınları yerleştirir',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(settingsProvider.notifier).setFirstClickSafety(false);
      container.read(selectedDifficultyProvider.notifier).select(
            DifficultyConfig.medium,
          );

      final state = container.read(gameProvider);
      expect(state.grid.length, 8);
      expect(state.grid.first.length, 8);
      expect(state.minesPlaced, isTrue);

      final mineCount = state.grid
          .expand((row) => row)
          .where((cell) => cell.isMine)
          .length;
      expect(mineCount, 10);
      expect(state.status, GameStatus.idle);
      expect(state.remainingMines, 10);
    });

    test('İlk tıklama güvenliği açıkken ilk hamlede 3x3 bölge korunur ve kaybedilmez',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(gameProvider, (_, __) {});
      addTearDown(sub.close);

      container.read(selectedDifficultyProvider.notifier).select(
            DifficultyConfig.medium,
          );

      var state = container.read(gameProvider);
      expect(state.minesPlaced, isFalse);

      // İlk tıklamadan önce koyulan bayrak korunmalı
      container.read(gameProvider.notifier).toggleFlag(0, 0);
      container.read(gameProvider.notifier).revealCell(4, 4);

      state = container.read(gameProvider);
      expect(state.minesPlaced, isTrue);
      expect(state.status, GameStatus.playing);
      expect(state.grid[0][0].isFlagged, isTrue);
      expect(state.grid[4][4].isMine, isFalse);
      expect(state.grid[4][4].neighborMines, 0);

      final mineCount = state.grid
          .expand((row) => row)
          .where((cell) => cell.isMine)
          .length;
      expect(mineCount, 10);
    });

    test('Bayrak koyma ve kaldırma kalan mayın sayısını günceller ve açmayı engeller',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(gameProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(gameProvider.notifier);
      final config = DifficultyConfig.custom(gridSize: 6, mineCount: 3);
      notifier.loadTestBoard(
        config: config,
        grid: buildDeterministicBoard(6, {(5, 5), (5, 4), (4, 5)}),
      );

      notifier.toggleFlag(0, 0);
      var state = container.read(gameProvider);
      expect(state.grid[0][0].isFlagged, isTrue);
      expect(state.flaggedCount, 1);
      expect(state.remainingMines, 2);

      // Bayraklı hücre kazma modunda açılmamalı
      notifier.onCellTap(0, 0);
      state = container.read(gameProvider);
      expect(state.grid[0][0].isRevealed, isFalse);

      // Bayrak moduna geçip dokunarak bayrağı kaldır
      notifier.toggleInputMode();
      notifier.onCellTap(0, 0);
      state = container.read(gameProvider);
      expect(state.grid[0][0].isFlagged, isFalse);
      expect(state.remainingMines, 3);
    });

    test('Boş hücre zincirleme açılışı tüm güvenli alanı temizleyince oyunu kazandırır',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(gameProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(gameProvider.notifier);
      final config = DifficultyConfig.custom(gridSize: 6, mineCount: 3);
      // Mayınları tek bir köşeye kümelersek (0,0) tıklaması tüm kalan güvenli alanı açar
      notifier.loadTestBoard(
        config: config,
        grid: buildDeterministicBoard(6, {(5, 5), (5, 4), (4, 5)}),
      );

      notifier.revealCell(0, 0);
      final state = container.read(gameProvider);

      expect(state.status, GameStatus.won);
      expect(state.revealedSafeCount, 33);
      expect(state.grid[5][5].isFlagged, isTrue);
      expect(state.remainingMines, 0);
    });

    test('Mayına basıldığında sadece basılan mayın patlar ve oyun kaybedilir', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(gameProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(gameProvider.notifier);
      final config = DifficultyConfig.custom(gridSize: 6, mineCount: 3);
      notifier.loadTestBoard(
        config: config,
        grid: buildDeterministicBoard(6, {(0, 0), (5, 5), (4, 4)}),
      );

      notifier.revealCell(0, 0);
      final state = container.read(gameProvider);

      expect(state.status, GameStatus.lost);
      expect(state.grid[0][0].isExploded, isTrue);
      expect(state.grid[0][0].isRevealed, isTrue);
      expect(state.explodedCell?.row, 0);
      expect(state.explodedCell?.col, 0);
      expect(state.lastActionRow, 0);
      expect(state.lastActionCol, 0);
      expect(state.waveDistanceTo(2, 3), 3);
      expect(state.grid[5][5].isRevealed, isTrue);
      expect(state.grid[5][5].isExploded, isFalse);
      expect(state.grid[1][1].isRevealed, isFalse);
    });

    test('Açık sayıya dokunarak hızlı açma (chording) doğru bayraklarla komşuları açar',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(gameProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(gameProvider.notifier);
      final config = DifficultyConfig.custom(gridSize: 6, mineCount: 3);
      notifier.loadTestBoard(
        config: config,
        grid: buildDeterministicBoard(6, {(0, 0), (5, 5), (4, 5)}),
      );

      // (1, 1) komşusu sadece (0, 0) mayını -> neighborMines == 1
      notifier.revealCell(1, 1);
      expect(container.read(gameProvider).grid[1][1].isRevealed, isTrue);
      expect(container.read(gameProvider).grid[1][1].neighborMines, 1);

      // (0, 0) hücresini bayrakla
      notifier.toggleFlag(0, 0);

      // (1, 1) üzerine tekrar dokun -> komşu boş hücreler zincirleme açılır ve kazanılır
      notifier.onCellTap(1, 1);
      final state = container.read(gameProvider);
      expect(state.status, GameStatus.won);
      expect(state.grid[0][1].isRevealed, isTrue);
      expect(state.grid[1][0].isRevealed, isTrue);
    });
  });
}

