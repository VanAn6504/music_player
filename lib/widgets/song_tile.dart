import 'dart:io';
import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onMoreTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: song.albumArt != null && File(song.albumArt!).existsSync()
            ? Image.file(File(song.albumArt!),
                width: 50, height: 50, fit: BoxFit.cover)
            : Container(
                width: 50,
                height: 50,
                color: const Color(0xFF282828),
                child: const Icon(Icons.music_note, color: Colors.grey)),
      ),
      title: Text(song.title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist,
          style: const TextStyle(color: Colors.grey), maxLines: 1),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: onMoreTap,
      ),
      onTap: onTap,
    );
  }
}
