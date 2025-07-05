import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/playlist_generator.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final playlistGenerator = Provider.of<PlaylistGenerator>(context, listen: false);

    if (!appState.playlistGenerated || appState.playlist.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentSong = appState.playlist[appState.currentlyPlayingIndex ?? 0];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and artist
            ListTile(
              title: Text(
                currentSong['title'] ?? 'Unknown Title',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${currentSong['artist']} • ${currentSong['country']} (${currentSong['year']})',
              ),
            ),
            
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (appState.isPlaying) {
                      playlistGenerator.pausePlayback();
                    } else {
                      playlistGenerator.playSong(currentSong);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => playlistGenerator.stop(),
                ),
                if (currentSong['webPlayerUrl'] != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => playlistGenerator.playSong(currentSong),
                    tooltip: 'Open in Spotify',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
