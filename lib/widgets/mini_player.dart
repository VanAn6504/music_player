import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final song = provider.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NowPlayingScreen())),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              border: Border(
                  top: BorderSide(color: Colors.grey.shade900, width: 1)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child:
                      song.albumArt != null && File(song.albumArt!).existsSync()
                          ? Image.file(File(song.albumArt!),
                              width: 45, height: 45, fit: BoxFit.cover)
                          : Container(
                              width: 45,
                              height: 45,
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(song.artist,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: provider.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white, size: 30),
                      onPressed: () => provider.playPause(),
                    );
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () => provider.next()),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
