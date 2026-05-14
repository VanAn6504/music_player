import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import '../models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _sleepTimer;
  Timer? _fadeTimer;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;

  Stream<PlaybackState> get playbackStateStream {
    return Rx.combineLatest3<Duration, Duration?, bool, PlaybackState>(
      positionStream,
      durationStream,
      playingStream,
      (position, duration, isPlaying) => PlaybackState(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: isPlaying,
      ),
    );
  }

  Future<void> loadAudio({
    required String filePath,
    required String id,
    required String title,
    required String artist,
    String? album,
    String? artUri,
  }) async {
    try {
      final source = AudioSource.uri(
        Uri.file(filePath),
        tag: MediaItem(
          id: id,
          title: title,
          artist: artist,
          album: album,
          artUri: artUri != null ? Uri.parse(artUri) : null,
        ),
      );
      await _audioPlayer.setAudioSource(source);
    } catch (e) {
      throw Exception('Error loading audio: $e');
    }
  }

  Future<void> play() async => await _audioPlayer.play();
  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> stop() async => await _audioPlayer.stop();
  Future<void> seek(Duration position) async =>
      await _audioPlayer.seek(position);
  Future<void> setVolume(double volume) async =>
      await _audioPlayer.setVolume(volume);
  Future<void> setSpeed(double speed) async =>
      await _audioPlayer.setSpeed(speed);
  Future<void> setLoopMode(LoopMode loopMode) async =>
      await _audioPlayer.setLoopMode(loopMode);

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();

    _sleepTimer = Timer(duration - const Duration(seconds: 10), () {
      _startFadeOut();
    });
  }

  void _startFadeOut() {
    double vol = _audioPlayer.volume;
    _fadeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      vol -= 0.1;
      if (vol <= 0.1) {
        setVolume(0.0);
        pause();
        timer.cancel();
        setVolume(1.0);
      } else {
        setVolume(vol);
      }
    });
  }

  void dispose() {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _audioPlayer.dispose();
  }
}
