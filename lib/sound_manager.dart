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
      if (kIsWeb) {
        await _audioPlayer.setAudioContext(const AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.mixWithOthers,
            ],
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
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
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
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

  Future<void> playGameStart() async {
    await playSound('game_start.mp3');
  }

  Future<void> playVictory() async {
    await playSound('victory.mp3');
  }

  Future<void> playCastle() async {
    await playSound('castle.mp3');
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
