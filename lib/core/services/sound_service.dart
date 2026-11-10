import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Oyunda çalınabilen ses efektleri.
enum SoundEffect {
  reveal('audio/reveal.wav'),
  cascade('audio/cascade.wav'),
  flag('audio/flag.wav'),
  explosion('audio/explosion.wav'),
  win('audio/win.wav');

  const SoundEffect(this.assetPath);
  final String assetPath;
}

/// Ses efektleri oynatma soyutlaması (testlerde kolayca taklit edilebilir).
abstract class SoundService {
  Future<void> play(SoundEffect effect);
  void dispose();
}

/// `audioplayers` kullanarak varlıklardan düşük gecikmeli ses çalan servis.
class AudioPlayersSoundService implements SoundService {
  final Map<SoundEffect, AudioPlayer> _players = {};
  bool _disposed = false;

  @override
  Future<void> play(SoundEffect effect) async {
    if (_disposed) return;

    try {
      final player = _players.putIfAbsent(effect, () {
        final instance = AudioPlayer();
        instance.setPlayerMode(PlayerMode.lowLatency);
        return instance;
      });
      await player.stop();
      await player.play(AssetSource(effect.assetPath));
    } catch (e) {
      // Test ortamı veya ses kanalı olmayan platformlarda sessizce yoksay
      debugPrint('SoundService play ignored: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final player in _players.values) {
      try {
        player.dispose();
      } catch (_) {}
    }
    _players.clear();
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = AudioPlayersSoundService();
  ref.onDispose(service.dispose);
  return service;
});

