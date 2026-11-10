import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama başlangıcında önceden yüklenebilen SharedPreferences sağlayıcısı.
/// Testlerde veya ön yükleme yapılmadığında `null` kalabilir.
final preloadedPrefsProvider = Provider<SharedPreferences?>((ref) => null);

/// Yerel anahtar-değer depolama erişimini yöneten servis.
class StorageService {
  StorageService(this._preloaded);

  final SharedPreferences? _preloaded;

  Future<SharedPreferences?> _prefs() async {
    if (_preloaded != null) return _preloaded;
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  String? readStringSync(String key) {
    return _preloaded?.getString(key);
  }

  Future<String?> readString(String key) async {
    final prefs = await _prefs();
    return prefs?.getString(key);
  }

  Future<void> writeString(String key, String value) async {
    final prefs = await _prefs();
    await prefs?.setString(key, value);
  }

  Future<void> remove(String key) async {
    final prefs = await _prefs();
    await prefs?.remove(key);
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(preloadedPrefsProvider));
});
