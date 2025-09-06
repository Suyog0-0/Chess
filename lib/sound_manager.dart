import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      // Set audio context for web
      if (kIsWeb) {
        await _audioPlayer.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ));
      }
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing audio: $e');
      }
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> playSound(String soundFile) async {
    if (!_soundEnabled) return;

    await _initialize();

    try {
      // Stop any currently playing sound
      await _audioPlayer.stop();

      // Try different asset path formats for compatibility
      final pathsToTry = [
        soundFile, // Direct path
        'sounds/$soundFile', // With sounds folder
        'assets/sounds/$soundFile', // Full asset path
      ];

      bool played = false;
      for (final path in pathsToTry) {
        try {
          await _audioPlayer.play(AssetSource(path));
          played = true;
          break;
        } catch (e) {
          // Continue to next path
          continue;
        }
      }

      if (!played && kDebugMode) {
        debugPrint('Could not play sound: $soundFile');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing sound $soundFile: $e');
      }
    }
  }

  Future<void> playMove() async {
    await playSound('move.mp3');
  }

  Future<void> playCapture() async {
    await playSound('capture.mp3');
  }

  Future<void> playCheck() async {
    await playSound('check.mp3');
  }

  Future<void> playVictory() async {
    await playSound('victory.mp3');
  }

  Future<void> playCastle() async {
    await playSound('castle.mp3');
  }

  Future<void> playHint() async {
    await playSound('hint.mp3');
  }

  Future<void> playPromote() async {
    await playSound('promote.mp3');
  }

  // Alternative method using SystemSound for basic feedback
  Future<void> playSystemSound() async {
    if (!_soundEnabled) return;

    try {
      // You can use Flutter's SystemSound as fallback
      // SystemSound.play(SystemSoundType.click);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing system sound: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
