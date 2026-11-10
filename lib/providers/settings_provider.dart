import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/services/storage_service.dart';
import 'package:mayin_tarlasi/models/app_settings.dart';

/// Kullanıcı ayarlarını Riverpod ve SharedPreferences üzerinden yönetir.
class SettingsNotifier extends Notifier<AppSettings> {
  static const _storageKey = 'neon_minesweeper_settings_v1';

  @override
  AppSettings build() {
    final storage = ref.read(storageServiceProvider);
    final rawSync = storage.readStringSync(_storageKey);
    if (rawSync != null) {
      try {
        return AppSettings.decode(rawSync);
      } catch (_) {}
    }

    _hydrateAsync(storage);
    return const AppSettings();
  }

  Future<void> _hydrateAsync(StorageService storage) async {
    final raw = await storage.readString(_storageKey);
    if (raw == null || !ref.mounted) return;
    try {
      state = AppSettings.decode(raw);
    } catch (_) {}
  }

  Future<void> _persist(AppSettings next) async {
    state = next;
    await ref.read(storageServiceProvider).writeString(
          _storageKey,
          next.encode(),
        );
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _persist(state.copyWith(soundEnabled: enabled));
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _persist(state.copyWith(hapticsEnabled: enabled));
  }

  Future<void> setFirstClickSafety(bool enabled) async {
    await _persist(state.copyWith(firstClickSafety: enabled));
  }

  Future<void> setAccentTheme(NeonThemeAccent accent) async {
    await _persist(state.copyWith(accentTheme: accent));
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

