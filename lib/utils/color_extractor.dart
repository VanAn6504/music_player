import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color> getDominantColor(String? imagePath) async {
    if (imagePath == null || !File(imagePath).existsSync()) {
      return const Color(0xFF191414);
    }
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        FileImage(File(imagePath)),
      );
      return paletteGenerator.dominantColor?.color ?? const Color(0xFF191414);
    } catch (e) {
      return const Color(0xFF191414);
    }
  }
}
