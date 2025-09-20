import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

// Using a Singleton pattern to ensure only one instance of the music player exists.
class MusicService {
  // Private constructor
  MusicService._();

  // The single, static instance of the service
  static final instance = MusicService._();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // A flag to track if music is already playing or has been started.
  bool _isPlaying = false;

  // A public getter to check the status from other parts of the app.
  bool get isPlaying => _isPlaying;

  // This method will now only attempt to play the music once.
  Future<void> playBackgroundMusic() async {
    // Only try to play if it's not already playing.
    // This prevents errors and multiple instances of the music.
    if (_isPlaying) return;

    try {
      // Set the release mode to loop to make the music repeat indefinitely.
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Play the audio from the assets/audio/ folder.
      await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
      // Update the flag on success so we don't try to play it again.
      _isPlaying = true;
    } catch (e) {
      debugPrint("Error playing background music: $e");
      // If it fails, keep the flag as false.
      _isPlaying = false;
    }
  }

  Future<void> pauseBackgroundMusic() async {
    // Only try to pause if music is actually supposed to be playing.
    if (!_isPlaying) return;
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint("Error pausing background music: $e");
    }
  }

  Future<void> resumeBackgroundMusic() async {
    // Only try to resume if music was already started.
    // This is important for the app lifecycle management.
    if (!_isPlaying) return;
    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Error resuming background music: $e");
    }
  }

  // Call this when the app is completely closed to release resources.
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isPlaying = false;
    } catch (e) {
      debugPrint("Error disposing music player: $e");
    }
  }
}
