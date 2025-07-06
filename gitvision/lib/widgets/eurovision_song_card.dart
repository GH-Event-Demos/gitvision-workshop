import 'package:flutter/material.dart';
import '../models/eurovision_song.dart';

class EurovisionSongCard extends StatelessWidget {
  final EurovisionSong song;

  const EurovisionSongCard({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.artist} • ${song.country} (${song.year})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                _buildPlaybackControls(),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                song.reasoning ?? 'Eurovision song for your coding mood',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    if ((song.previewUrl?.isEmpty ?? true) &&
        (song.spotifyUrl?.isEmpty ?? true)) {
      return IconButton(
        icon: const Icon(Icons.music_note),
        onPressed: null,
      );
    }

    if (song.previewUrl?.isEmpty ?? true) {
      return TextButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: const Text('Spotify'),
        onPressed: (song.spotifyUrl?.isNotEmpty ?? false)
            ? () => launchUrlString(song.spotifyUrl!)
            : null,
      );
    }

    if (isPlaying) {
      return IconButton(
        icon: const Icon(Icons.pause_circle_filled),
        iconSize: 48,
        onPressed: onPausePressed,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.play_circle_filled),
        iconSize: 48,
        onPressed: onPlayPressed,
      );
    }
  }
}
