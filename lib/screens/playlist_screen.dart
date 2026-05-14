import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist_card.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/playlist_service.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title:
            const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter playlist name',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<PlaylistProvider>()
                    .createPlaylist(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Create',
                style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          if (provider.playlists.isEmpty) {
            return const Center(
              child: Text('No playlists yet. Create one!',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            itemCount: provider.playlists.length,
            itemBuilder: (context, index) {
              return PlaylistCard(
                playlist: provider.playlists[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistDetailScreen(
                        playlist: provider.playlists[index],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistService _playlistService = PlaylistService();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final songs =
          await _playlistService.getSongsByIds(widget.playlist.songIds);
      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading playlist songs: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRemoveSongDialog(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title:
              const Text('Remove Song', style: TextStyle(color: Colors.white)),
          content: Text('Remove "${song.title}" from this playlist?',
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<PlaylistProvider>()
                    .removeSongFromPlaylist(widget.playlist.id, song.id);
                setState(() {
                  _songs.removeWhere((s) => s.id == song.id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed ${song.title}')),
                );
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final updatedPlaylist =
        context.watch<PlaylistProvider>().playlists.firstWhere(
              (p) => p.id == widget.playlist.id,
              orElse: () => widget.playlist,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedPlaylist.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : _songs.isEmpty
              ? const Center(
                  child: Text('Playlist is empty',
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    return SongTile(
                      song: song,
                      onTap: () {
                        context
                            .read<AudioProvider>()
                            .setPlaylist(_songs, index);
                      },
                      onMoreTap: () => _showRemoveSongDialog(context, song),
                    );
                  },
                ),
    );
  }
}
