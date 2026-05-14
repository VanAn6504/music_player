import 'package:flutter/material.dart';
import '../providers/audio_provider.dart';
import '../models/playback_state_model.dart';
import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  final AudioProvider provider;
  const ProgressBar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: provider.playbackStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final position = state?.position ?? Duration.zero;
        final duration = state?.duration ?? Duration.zero;

        return Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: const Color(0xFF1DB954),
                inactiveTrackColor: Colors.grey[800],
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF1DB954).withOpacity(0.3),
              ),
              child: Slider(
                value: position.inMilliseconds.toDouble().clamp(
                    0.0,
                    duration.inMilliseconds.toDouble() > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1.0),
                min: 0.0,
                max: duration.inMilliseconds.toDouble() > 0
                    ? duration.inMilliseconds.toDouble()
                    : 1.0,
                onChanged: (value) =>
                    provider.seek(Duration(milliseconds: value.toInt())),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(position),
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(formatDuration(duration),
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        );
      },
    );
  }
}
