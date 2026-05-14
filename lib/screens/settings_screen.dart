import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Playback Options',
              style: TextStyle(
                  color: Color(0xFF1DB954), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.white),
            title: const Text('Sleep Timer',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Stop audio after a specified time',
                style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showSleepTimerDialog(context),
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 10),
          const Text('About',
              style: TextStyle(
                  color: Color(0xFF1DB954), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.white),
            title: Text('Version', style: TextStyle(color: Colors.white)),
            subtitle: Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    final provider = context.read<AudioProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Set Sleep Timer',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          _buildTimerOption(context, provider, '15 Minutes', 15),
          _buildTimerOption(context, provider, '30 Minutes', 30),
          _buildTimerOption(context, provider, '60 Minutes', 60),
          _buildTimerOption(context, provider, 'Turn Off Timer', 0),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimerOption(
      BuildContext context, AudioProvider provider, String title, int minutes) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center),
      onTap: () {
        if (minutes > 0) {
          provider.audioService.startSleepTimer(Duration(minutes: minutes));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Music will fade out and stop in $minutes minutes.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sleep timer cancelled.')));
        }
        Navigator.pop(context);
      },
    );
  }
}
