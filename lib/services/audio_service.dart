import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage all audio effects in the game
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static AudioService get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;
  bool _isInitialized = false;

  // Audio file paths
  static const String _blockSound = 'audio/block_2.mp3';
  static const String _clickSound = 'audio/mouse_click_5.mp3';
  static const String _winSound = 'audio/win_2.mp3';
  static const String _moveSound = 'audio/move_7.mp3';
  static const String _hintSound = 'audio/other_4.mp3';

  /// Initialize the audio service
  Future<void> initialize() async {
    try {
      // Load sound preference from storage
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
      
      // Set audio player settings
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.setVolume(1.0);
      
      _isInitialized = true;
    } catch (e) {
      _isSoundEnabled = true; // Default to enabled
      _isInitialized = true; // Still mark as initialized
    }
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _isSoundEnabled;

  /// Toggle sound on/off
  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _isSoundEnabled);
    } catch (e) {
      // Silent fail - preference will default to enabled
    }
  }

  /// Play a sound effect
  Future<void> _playSound(String assetPath) async {
    if (!_isInitialized || !_isSoundEnabled) return;

    try {
      // Stop any currently playing sound first
      await _audioPlayer.stop();
      // Play the new sound
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Silent fail - audio will not play if there's an error
    }
  }

  /// Play sound when user can't place a number (invalid move)
  Future<void> playBlockSound() async {
    await _playSound(_blockSound);
  }

  /// Play sound when player clicks on any button or card
  Future<void> playClickSound() async {
    await _playSound(_clickSound);
  }

  /// Play sound when puzzle is successfully solved
  Future<void> playWinSound() async {
    await _playSound(_winSound);
  }

  /// Play sound when player places a number
  Future<void> playMoveSound() async {
    await _playSound(_moveSound);
  }

  /// Play sound for hint button
  Future<void> playHintSound() async {
    await _playSound(_hintSound);
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
