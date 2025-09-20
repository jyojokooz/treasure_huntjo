import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

// Using a Singleton pattern to ensure only one instance of the music player exists.
class MusicService {
  // Private constructor
  MusicService._();

  // The single, static instance of the service
  static final instance = MusicService._();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playBackgroundMusic() async {
    try {
      // Set the release mode to loop to make the music repeat
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Play the audio from the assets folder
      await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      debugPrint("Error playing background music: $e");
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint("Error pausing background music: $e");
    }
  }

  Future<void> resumeBackgroundMusic() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Error resuming background music: $e");
    }
  }

  // Call this when the app is completely closed
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      debugPrint("Error disposing music player: $e");
    }
  }
}
