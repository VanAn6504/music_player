import 'package:on_audio_query/on_audio_query.dart' as q;
import '../models/song_model.dart';

class PlaylistService {
  final q.OnAudioQuery _audioQuery = q.OnAudioQuery();

  Future<List<SongModel>> getAllSongs() async {
    try {
      final List<q.SongModel> audioList = await _audioQuery.querySongs(
        sortType: null,
        orderType: q.OrderType.ASC_OR_SMALLER,
        uriType: q.UriType.EXTERNAL,
        ignoreCase: true,
      );
      return audioList.map((audio) => SongModel.fromAudioQuery(audio)).toList();
    } catch (e) {
      throw Exception('Error loading songs: $e');
    }
  }

  Future<List<SongModel>> getSongsByIds(List<String> ids) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => ids.contains(song.id)).toList();
  }
}
