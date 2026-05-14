import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';
import '../utils/constants.dart';

class StorageService {
  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = playlists.map((p) => p.toJson()).toList();
    await prefs.setString(
        AppConstants.playlistsKey, json.encode(playlistsJson));
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsString = prefs.getString(AppConstants.playlistsKey);
    if (playlistsString != null) {
      final List<dynamic> playlistsJson = json.decode(playlistsString);
      return playlistsJson.map((json) => PlaylistModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveLastPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.lastPlayedKey, songId);
  }

  Future<String?> getLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.lastPlayedKey);
  }

  Future<void> saveShuffleState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.shuffleKey, enabled);
  }

  Future<bool> getShuffleState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.shuffleKey) ?? false;
  }

  Future<void> saveRepeatMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.repeatKey, mode);
  }

  Future<int> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.repeatKey) ?? 0;
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.volumeKey, volume);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(AppConstants.volumeKey) ?? 1.0;
  }
}
