import 'dart:io';
import 'package:flutter/material.dart';

class AlbumArt extends StatelessWidget {
  final String? imagePath;
  final double size;
  final double borderRadius;
  final bool hasShadow;

  const AlbumArt({
    super.key,
    required this.imagePath,
    this.size = 50.0,
    this.borderRadius = 4.0,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imagePath != null && File(imagePath!).existsSync()
            ? Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.music_note,
      size: size * 0.5,
      color: Colors.grey[600],
    );
  }
}
