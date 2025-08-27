import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/eurovision_song.dart';
import '../utils/accessibility_helpers.dart';

class EurovisionSongCard extends StatelessWidget {
  final EurovisionSong song;
  final bool isPlaying;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onPausePressed;

  const EurovisionSongCard({
    super.key,
    required this.song,
    this.isPlaying = false,
    this.onPlayPressed,
    this.onPausePressed,
  });

  @override
  Widget build(BuildContext context) {
    final cardLabel = AccessibilityConstants.songCardLabel(
      song.title, 
      song.artist, 
      song.country, 
      song.year
    );
    
    return AccessibilityHelpers.accessibleCard(
      semanticLabel: cardLabel,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (song.imageUrl != null && song.imageUrl!.isNotEmpty) ...[
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AccessibilityHelpers.accessibleImage(
                      imageUrl: song.imageUrl!,
                      altText: AccessibilityConstants.albumArtLabel(song.title, song.artist),
                      width: 60,
                      height: 60,
                      placeholder: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AccessibilityHelpers.accessibleLoadingIndicator(
                          description: 'Loading album artwork for ${song.title}',
                        ),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.music_note, 
                          size: 32,
                          semanticLabel: AccessibilityConstants.musicNoteIcon,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        semanticsLabel: 'Song title: ${song.title}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.artist} • ${song.country} (${song.year})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        semanticsLabel: 'Artist: ${song.artist}, Country: ${song.country}, Year: ${song.year}',
                      ),
                    ],
                  ),
                ),
              ),
              _buildPlaybackControls(),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Song recommendation reason',
            child: Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    if ((song.previewUrl?.isEmpty ?? true) &&
        (song.spotifyUrl?.isEmpty ?? true)) {
      return AccessibilityHelpers.accessibleIconButton(
        icon: Icons.music_note,
        onPressed: null,
        semanticLabel: 'No preview available for ${song.title}',
      );
    }

    if (song.previewUrl?.isEmpty ?? true) {
      return Semantics(
        label: 'Open ${song.title} on Spotify',
        button: true,
        child: TextButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: const Text('Spotify'),
          onPressed: (song.spotifyUrl?.isNotEmpty ?? false)
              ? () => launchUrlString(song.spotifyUrl!)
              : null,
        ),
      );
    }

    if (isPlaying) {
      return AccessibilityHelpers.accessibleIconButton(
        icon: Icons.pause_circle_filled,
        onPressed: onPausePressed,
        semanticLabel: '${AccessibilityConstants.pauseButtonLabel}: ${song.title}',
        size: AccessibilityConstants.preferredTouchTargetSize,
      );
    } else {
      return AccessibilityHelpers.accessibleIconButton(
        icon: Icons.play_circle_filled,
        onPressed: onPlayPressed,
        semanticLabel: '${AccessibilityConstants.playButtonLabel}: ${song.title}',
        size: AccessibilityConstants.preferredTouchTargetSize,
      );
    }
  }
}
