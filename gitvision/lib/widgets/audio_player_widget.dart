import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import '../providers/app_state_provider.dart';
import '../services/theme_provider.dart';
import '../utils/accessibility_helpers.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (appState.currentlyPlayingIndex == null) {
      return const SizedBox.shrink();
    }

    final currentSong = appState.playlist[appState.currentlyPlayingIndex!];

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Semantics(
              label: AccessibilityConstants.progressBarLabel,
              slider: true,
              value: appState.currentPosition.inSeconds.toDouble(),
              increasedValue: (appState.currentPosition.inSeconds + 10).toDouble(),
              decreasedValue: (appState.currentPosition.inSeconds - 10).toDouble(),
              child: ProgressBar(
                progress: appState.currentPosition,
                total: appState.currentDuration,
                progressBarColor: themeProvider.primaryColor,
                baseBarColor: themeProvider.primaryColor.withValues(alpha: 0.2),
                bufferedBarColor: themeProvider.primaryColor.withValues(alpha: 0.4),
                thumbColor: themeProvider.primaryColor,
                barHeight: 4.0,
                thumbRadius: 8.0,
                onSeek: (duration) {
                  // TODO: Implement seek functionality
                },
              ),
            ),
          ),

          // Player controls
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                // Album art
                _buildAlbumArt(currentSong, themeProvider),

                const SizedBox(width: 16),

                // Song info
                Expanded(
                  child: Semantics(
                    label: 'Currently playing: ${currentSong['title'] ?? 'Unknown Title'} by ${currentSong['artist'] ?? 'Unknown Artist'}',
                    header: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong['title'] ?? 'Unknown Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${currentSong['artist'] ?? 'Unknown Artist'} • ${currentSong['country'] ?? 'Unknown'}',
                          style: TextStyle(
                            color: themeProvider.textColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Controls
                Semantics(
                  label: 'Audio playback controls',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Previous button
                      AccessibilityHelpers.accessibleIconButton(
                        icon: Icons.skip_previous,
                        onPressed: appState.currentlyPlayingIndex! > 0
                            ? () => _playPrevious(appState)
                            : null,
                        semanticLabel: AccessibilityConstants.previousTrackLabel,
                        color: themeProvider.primaryColor,
                      ),

                      // Play/Pause button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeProvider.primaryColor,
                        ),
                        child: AccessibilityHelpers.accessibleIconButton(
                          icon: appState.isPlaying ? Icons.pause : Icons.play_arrow,
                          onPressed: () => _togglePlayPause(appState),
                          semanticLabel: appState.isPlaying 
                              ? AccessibilityConstants.pauseButtonLabel 
                              : AccessibilityConstants.playButtonLabel,
                          color: Colors.white,
                        ),
                      ),

                      // Next button
                      AccessibilityHelpers.accessibleIconButton(
                        icon: Icons.skip_next,
                        onPressed: appState.currentlyPlayingIndex! < appState.playlist.length - 1
                            ? () => _playNext(appState)
                            : null,
                        semanticLabel: AccessibilityConstants.nextTrackLabel,
                        color: themeProvider.primaryColor,
                      ),

                      // Close button
                      AccessibilityHelpers.accessibleIconButton(
                        icon: Icons.close,
                        onPressed: () => appState.stopPlayback(),
                        semanticLabel: 'Close audio player',
                        color: themeProvider.textColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(Map<String, dynamic> song, ThemeProvider themeProvider) {
    final imageUrl = song['imageUrl'] as String?;
    final title = song['title'] as String? ?? 'Unknown Title';
    final artist = song['artist'] as String? ?? 'Unknown Artist';
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: themeProvider.primaryColor.withValues(alpha: 0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? AccessibilityHelpers.accessibleImage(
                imageUrl: imageUrl,
                altText: AccessibilityConstants.albumArtLabel(title, artist),
                width: 48,
                height: 48,
                errorWidget: Icon(
                  Icons.music_note,
                  color: themeProvider.primaryColor,
                  size: 24,
                  semanticLabel: AccessibilityConstants.musicNoteIcon,
                ),
              )
            : Icon(
                Icons.music_note,
                color: themeProvider.primaryColor,
                size: 24,
                semanticLabel: AccessibilityConstants.musicNoteIcon,
              ),
      ),
    );
  }

  void _togglePlayPause(AppStateProvider appState) {
    if (appState.isPlaying) {
      appState.pausePlayback();
    } else {
      appState.resumePlayback();
    }
  }

  void _playPrevious(AppStateProvider appState) {
    final currentIndex = appState.currentlyPlayingIndex!;
    if (currentIndex > 0) {
      appState.playSong(currentIndex - 1);
    }
  }

  void _playNext(AppStateProvider appState) {
    final currentIndex = appState.currentlyPlayingIndex!;
    if (currentIndex < appState.playlist.length - 1) {
      appState.playSong(currentIndex + 1);
    }
  }
}