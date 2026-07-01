import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AudioService {
  final AudioPlayer _buyPlayer = AudioPlayer();
  final AudioPlayer _prestigePlayer = AudioPlayer();

  bool _soundEnabled = true;
  double _volume = 0.7;

  AudioService() {
    final box = Hive.box('settings');
    _soundEnabled = box.get('soundEnabled', defaultValue: true) as bool;
    _volume = (box.get('volume', defaultValue: 0.7) as num).toDouble();
    _init();
  }

  Future<void> _init() async {
    // Low-latency mode uses the native short-sound engine (SoundPool on
    // Android) and the samples are pre-loaded once, so effects fire instantly
    // instead of preparing a MediaPlayer on every play.
    try {
      await _buyPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _prestigePlayer.setPlayerMode(PlayerMode.lowLatency);
      await _buyPlayer.setReleaseMode(ReleaseMode.stop);
      await _prestigePlayer.setReleaseMode(ReleaseMode.stop);
      await _buyPlayer.setVolume(_volume);
      await _prestigePlayer.setVolume(_volume);
      await _buyPlayer.setSource(AssetSource('sounds/buy.mp3'));
      await _prestigePlayer.setSource(AssetSource('sounds/prestige.mp3'));
    } catch (e) {
      print('audio init error: $e');
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    Hive.box('settings').put('soundEnabled', enabled);
  }

  void setVolume(double volume) {
    _volume = volume;
    Hive.box('settings').put('volume', volume);
    _buyPlayer.setVolume(volume);
    _prestigePlayer.setVolume(volume);
  }

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  Future<void> playTap() async {}

  Future<void> playBuy() async {
    if (!_soundEnabled) return;
    try {
      // In low-latency mode the player stays in a completed state after the
      // first play, so stop() first to reset it, otherwise it only fires once.
      await _buyPlayer.stop();
      await _buyPlayer.play(AssetSource('sounds/buy.mp3'), volume: _volume);
    } catch (e) {
      print('playBuy error: $e');
    }
  }

  Future<void> playPrestige() async {
    if (!_soundEnabled) return;
    try {
      await _prestigePlayer.stop();
      await _prestigePlayer.play(AssetSource('sounds/prestige.mp3'), volume: _volume);
    } catch (e) {
      print('playPrestige error: $e');
    }
  }

  void dispose() {
    _buyPlayer.dispose();
    _prestigePlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final svc = AudioService();
  ref.onDispose(svc.dispose);
  return svc;
});
