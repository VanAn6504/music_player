import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../providers/audio_provider.dart';
import '../models/song_model.dart';
import '../widgets/song_tile.dart';
import '../providers/playlist_provider.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();

  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _hasPermission = await _permissionService.requestStoragePermission();
    if (_hasPermission) {
      await _loadSongs();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      if (mounted) {
        setState(() => _songs = songs);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showAddToPlaylistBottomSheet(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (context) {
        return Consumer<PlaylistProvider>(
          builder: (context, provider, child) {
            if (provider.playlists.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No playlists available.',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: provider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = provider.playlists[index];
                return ListTile(
                  leading: const Icon(Icons.playlist_add, color: Colors.white),
                  title: Text(playlist.name,
                      style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    provider.addSongToPlaylist(playlist.id, song.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to ${playlist.name}')),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Music',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : !_hasPermission
              ? _buildPermissionDenied()
              : _songs.isEmpty
                  ? const Center(
                      child: Text('No Music Found on Device',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        return SongTile(
                          song: _songs[index],
                          onTap: () {
                            context
                                .read<AudioProvider>()
                                .setPlaylist(_songs, index);
                          },
                          onMoreTap: () => _showAddToPlaylistBottomSheet(
                              context, _songs[index]),
                        );
                      },
                    ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Storage Permission Required',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954)),
            onPressed: _initializeApp,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
