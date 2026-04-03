// This is a stub sound service. Replace with actual .mp3 files in assets/sounds/
// Free sound resources: freesound.org | mixkit.co | pixabay.com/sound-effects

import 'package:programming_learn_app/data/services/preferences_service.dart';

class SoundService {
  static bool _soundEnabled = true;
  static final _preferencesService = PreferencesService();

  static Future<void> init() async {
    _soundEnabled = await _preferencesService.isSoundEnabled();
  }

  static Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    await _preferencesService.toggleSound(enabled);
  }

  static bool get isSoundEnabled => _soundEnabled;

  // Replace with actual .mp3 file in assets/sounds/correct.mp3
  static Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    try {
      // AudioPlayer instance would play the sound here
      // await _player.play(AssetSource('sounds/correct.mp3'));
      _log('Playing: correct.mp3');
    } catch (e) {
      _log('Error playing correct sound: $e');
    }
  }

  // Replace with actual .mp3 file in assets/sounds/wrong.mp3
  static Future<void> playWrong() async {
    if (!_soundEnabled) return;
    try {
      // await _player.play(AssetSource('sounds/wrong.mp3'));
      _log('Playing: wrong.mp3');
    } catch (e) {
      _log('Error playing wrong sound: $e');
    }
  }

  // Replace with actual .mp3 file in assets/sounds/xp_gain.mp3
  static Future<void> playXP() async {
    if (!_soundEnabled) return;
    try {
      // await _player.play(AssetSource('sounds/xp_gain.mp3'));
      _log('Playing: xp_gain.mp3');
    } catch (e) {
      _log('Error playing XP sound: $e');
    }
  }

  // Replace with actual .mp3 file in assets/sounds/streak.mp3
  static Future<void> playStreak() async {
    if (!_soundEnabled) return;
    try {
      // await _player.play(AssetSource('sounds/streak.mp3'));
      _log('Playing: streak.mp3');
    } catch (e) {
      _log('Error playing streak sound: $e');
    }
  }

  // Replace with actual .mp3 file in assets/sounds/complete.mp3
  static Future<void> playComplete() async {
    if (!_soundEnabled) return;
    try {
      // await _player.play(AssetSource('sounds/complete.mp3'));
      _log('Playing: complete.mp3');
    } catch (e) {
      _log('Error playing complete sound: $e');
    }
  }

  // Replace with actual .mp3 file in assets/sounds/tap.mp3
  static Future<void> playTap() async {
    if (!_soundEnabled) return;
    try {
      // await _player.play(AssetSource('sounds/tap.mp3'));
      _log('Playing: tap.mp3');
    } catch (e) {
      _log('Error playing tap sound: $e');
    }
  }

  static void _log(String message) {
    // Replace with actual debug logging if needed
    // debugPrint(message);
  }
}
