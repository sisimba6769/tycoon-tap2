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
  }
 
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    Hive.box('settings').put('soundEnabled', enabled);
  }
 
  void setVolume(double volume) {
    _volume = volume;
    Hive.box('settings').put('volume', volume);
  }
 
  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;
 
  Future<void> playBuy() async {
    if (!_soundEnabled) return;
    try {
      await _buyPlayer.setVolume(_volume);
      await _buyPlayer.play(AssetSource('sounds/buy.mp3'));
    } catch (_) {}
  }
 
  Future<void> playPrestige() async {
    if (!_soundEnabled) return;
    try {
      await _prestigePlayer.setVolume(_volume);
      await _prestigePlayer.play(AssetSource('sounds/prestige.mp3'));
    } catch (_) {}
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