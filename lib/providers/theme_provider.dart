import 'package:flutter/material.dart';
import '../utils/color_extractor.dart';

class ThemeProvider extends ChangeNotifier {
  Color _dominantColor = const Color(0xFF191414);

  Color get dominantColor => _dominantColor;

  Future<void> updateTheme(String? imagePath) async {
    _dominantColor = await ColorExtractor.getDominantColor(imagePath);
    notifyListeners();
  }
}
