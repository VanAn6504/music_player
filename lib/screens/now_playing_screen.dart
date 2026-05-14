import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, ThemeProvider>(
      builder: (context, audioProvider, themeProvider, child) {
        final song = audioProvider.currentSong;
        if (song == null)
          return const Scaffold(body: Center(child: Text('No song playing')));

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeProvider.dominantColor.withOpacity(0.8),
                  const Color(0xFF121212),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, audioProvider),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gesture Control
                          GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! < 0) {
                                audioProvider.next();
                              } else if (details.primaryVelocity! > 0) {
                                audioProvider.previous();
                              }
                            },
                            child: _buildAlbumArt(song.albumArt),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            song.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            song.artist,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          ProgressBar(provider: audioProvider),
                          const SizedBox(height: 20),
                          PlayerControls(provider: audioProvider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, AudioProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('Now Playing',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          // Sleep Timer
          PopupMenuButton<int>(
            icon: const Icon(Icons.timer_outlined, color: Colors.white),
            color: const Color(0xFF282828),
            onSelected: (minutes) {
              provider.audioService.startSleepTimer(Duration(minutes: minutes));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Music will fade out and stop in $minutes minutes.')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 1,
                  child: Text('1 Minute (Test)',
                      style: TextStyle(color: Colors.white))),
              const PopupMenuItem(
                  value: 15,
                  child: Text('15 Minutes',
                      style: TextStyle(color: Colors.white))),
              const PopupMenuItem(
                  value: 30,
                  child: Text('30 Minutes',
                      style: TextStyle(color: Colors.white))),
              const PopupMenuItem(
                  value: 60,
                  child: Text('60 Minutes',
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String? albumArt) {
    return Hero(
      tag: 'album_art',
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: albumArt != null && File(albumArt).existsSync()
              ? Image.file(File(albumArt), fit: BoxFit.cover)
              : Container(
                  color: const Color(0xFF282828),
                  child: const Icon(Icons.music_note,
                      size: 100, color: Colors.grey),
                ),
        ),
      ),
    );
  }
}
