import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../services/playlist_service.dart';
import 'theme_provider.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService audioService;
  final StorageService storageService;
  final ThemeProvider themeProvider;

  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  AudioProvider(this.audioService, this.storageService, this.themeProvider) {
    _init();
  }

  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;

  Stream<Duration> get positionStream => audioService.positionStream;
  Stream<Duration?> get durationStream => audioService.durationStream;
  Stream<bool> get playingStream => audioService.playingStream;
  Stream<PlaybackState> get playbackStateStream =>
      audioService.playbackStateStream;

  Future<void> _init() async {
    _isShuffleEnabled = await storageService.getShuffleState();
    final repeatMode = await storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatMode];

    await audioService.setLoopMode(_loopMode);
    final volume = await storageService.getVolume();
    await audioService.setVolume(volume);

    final lastPlayedId = await storageService.getLastPlayed();
    if (lastPlayedId != null) {
      try {
        final playlistService = PlaylistService();
        final songs = await playlistService.getAllSongs();
        final index = songs.indexWhere((s) => s.id == lastPlayedId);
        if (index != -1) {
          _playlist = songs;
          _currentIndex = index;
          final song = songs[index];

          await themeProvider.updateTheme(song.albumArt);
          await audioService.loadAudio(
            filePath: song.filePath,
            id: song.id,
            title: song.title,
            artist: song.artist,
            album: song.album,
            artUri: song.albumArt,
          );

          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error loading last played song: $e');
      }
    }
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= playlist.length) return;
    _currentIndex = index;
    final song = playlist[index];

    await themeProvider.updateTheme(song.albumArt);

    await audioService.loadAudio(
      filePath: song.filePath,
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      artUri: song.albumArt,
    );
    await audioService.play();
    await storageService.saveLastPlayed(song.id);
    notifyListeners();
  }

  Future<void> playPause() async {
    if (audioService.isPlaying) {
      await audioService.pause();
    } else {
      await audioService.play();
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await audioService.stop();
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (audioService.currentPosition.inSeconds > 3) {
      await audioService.seek(Duration.zero);
    } else {
      if (_isShuffleEnabled) {
        _currentIndex = _getRandomIndex();
      } else {
        _currentIndex =
            (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }
      await _playSongAtIndex(_currentIndex);
    }
  }

  Future<void> seek(Duration position) async =>
      await audioService.seek(position);

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await audioService.setLoopMode(_loopMode);
    await storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  int _getRandomIndex() {
    return DateTime.now().millisecondsSinceEpoch % _playlist.length;
  }

  @override
  void dispose() {
    audioService.dispose();
    super.dispose();
  }
}
