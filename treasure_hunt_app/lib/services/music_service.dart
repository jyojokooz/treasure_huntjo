// ===============================
// FILE NAME: music_service.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\services\music_service.dart
// ===============================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  MusicService._();
  static final instance = MusicService._();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer =
      AudioPlayer(); // NEW player for sound effects

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future<void> playBackgroundMusic() async {
    if (_isPlaying) return;
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource('audio/background_music.mp3'));
      _isPlaying = true;
    } catch (e) {
      debugPrint("Error playing background music: $e");
      _isPlaying = false;
    }
  }

  // NEW METHOD for victory sound
  Future<void> playVictoryFanfare() async {
    try {
      // We don't loop sound effects
      await _soundEffectPlayer.setReleaseMode(ReleaseMode.release);
      await _soundEffectPlayer.play(AssetSource('audio/victory.mp3'));
    } catch (e) {
      debugPrint("Error playing victory fanfare: $e");
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_isPlaying) return;
    try {
      await _backgroundPlayer.pause();
    } catch (e) {
      debugPrint("Error pausing background music: $e");
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isPlaying) return;
    try {
      await _backgroundPlayer.resume();
    } catch (e) {
      debugPrint("Error resuming background music: $e");
    }
  }

  Future<void> dispose() async {
    try {
      await _backgroundPlayer.dispose();
      await _soundEffectPlayer.dispose(); // NEW
      _isPlaying = false;
    } catch (e) {
      debugPrint("Error disposing music players: $e");
    }
  }
}
