import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService() {
    _sfx.setPlayerMode(PlayerMode.lowLatency);
  }

  final AudioPlayer _sfx = AudioPlayer(playerId: 'sfx');
  final AudioPlayer _bgm = AudioPlayer(playerId: 'bgm');
  bool _bgmStarted = false;

  Future<void> startBackground() async {
    if (_bgmStarted) return;
    _bgmStarted = true;
    await _bgm.setReleaseMode(ReleaseMode.loop);
    await _bgm.setVolume(0.18);
    await _bgm.play(AssetSource('audio/bgm_loop.wav'));
  }

  Future<void> stopBackground() async {
    _bgmStarted = false;
    await _bgm.stop();
  }

  Future<void> playTap() async {
    await _sfx.stop();
    await _sfx.play(AssetSource('audio/tap.wav'), volume: 0.7);
  }

  Future<void> playCorrect() async {
    await _sfx.stop();
    await _sfx.play(AssetSource('audio/correct.wav'), volume: 1.0);
  }

  Future<void> playWrong() async {
    await _sfx.stop();
    await _sfx.play(AssetSource('audio/wrong.wav'), volume: 1.0);
  }

  Future<void> playGoalReached() async {
    await _sfx.stop();
    await _sfx.play(AssetSource('audio/goal.wav'), volume: 1.0);
  }

  Future<void> dispose() async {
    await _sfx.dispose();
    await _bgm.dispose();
  }
}
