import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mayin_tarlasi/core/services/storage_service.dart';
import 'package:mayin_tarlasi/models/app_settings.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:mayin_tarlasi/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StatsNotifier & SettingsNotifier', () {
    test('Ayarlar SharedPreferences üzerinde kalıcı olarak saklanır', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container1 = ProviderContainer(
        overrides: [preloadedPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container1.dispose);

      await container1.read(settingsProvider.notifier).setSoundEnabled(false);
      await container1.read(settingsProvider.notifier).setHapticsEnabled(false);
      await container1.read(settingsProvider.notifier).setFirstClickSafety(false);
      await container1
          .read(settingsProvider.notifier)
          .setAccentTheme(NeonThemeAccent.synthwave);

      final container2 = ProviderContainer(
        overrides: [preloadedPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container2.dispose);

      final restored = container2.read(settingsProvider);
      expect(restored.soundEnabled, isFalse);
      expect(restored.hapticsEnabled, isFalse);
      expect(restored.firstClickSafety, isFalse);
      expect(restored.accentTheme, NeonThemeAccent.synthwave);
    });

    test('İstatistikler rekor tespiti, seri hesabı ve sıfırlamayı doğru yönetir',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [preloadedPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(statsProvider.notifier);

      // İlk kazanma yeni rekor olmalı
      final firstWinRecord = await notifier.recordWin(
        difficulty: GameDifficulty.easy,
        elapsedSeconds: 25,
      );
      expect(firstWinRecord, isTrue);

      // Daha yavaş süre rekor kırmaz
      final slowerWinRecord = await notifier.recordWin(
        difficulty: GameDifficulty.easy,
        elapsedSeconds: 30,
      );
      expect(slowerWinRecord, isFalse);

      // Daha hızlı süre yeni rekor kırar
      final fasterWinRecord = await notifier.recordWin(
        difficulty: GameDifficulty.easy,
        elapsedSeconds: 18,
      );
      expect(fasterWinRecord, isTrue);

      var stats = container.read(statsProvider);
      expect(stats.currentStreak, 3);
      expect(stats.bestStreak, 3);
      expect(stats.statsFor(GameDifficulty.easy).bestTimeSeconds, 18);
      expect(stats.statsFor(GameDifficulty.easy).gamesWon, 3);

      // Kayıp aktif seriyi sıfırlar, en iyi seriyi korur
      await notifier.recordLoss(difficulty: GameDifficulty.easy);
      stats = container.read(statsProvider);
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 3);
      expect(stats.statsFor(GameDifficulty.easy).gamesPlayed, 4);

      // Sıfırlama tüm kayıtları temizler
      await notifier.resetStats();
      stats = container.read(statsProvider);
      expect(stats.totalPlayed, 0);
      expect(stats.bestStreak, 0);
    });
  });
}

