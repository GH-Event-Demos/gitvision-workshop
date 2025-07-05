import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state_provider.dart';
import '../services/theme_provider.dart';
import '../models/coding_mood.dart';
import '../constants/app_constants.dart';
import '../services/playlist_generator.dart';
import 'modern_share_widget.dart';
import 'song_player_widget.dart';

class PlaylistDisplayWidget extends StatelessWidget {
  const PlaylistDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (appState.generatingPlaylist) {
      return _buildGeneratingState(themeProvider);
    }

    if (!appState.playlistGenerated || appState.playlist.isEmpty) {
      return _buildGenerateButton(appState, themeProvider);
    }

    return _buildPlaylist(appState, themeProvider);
  }

  Widget _buildGeneratingState(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.extraLargeSpacing),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            'Cooking up your soundtrack...',
            style: TextStyle(
              fontSize: AppConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            'Matching your vibe to Eurovision hits 🎤',
            style: TextStyle(
              color: themeProvider.textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(AppStateProvider appState, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(
          color: themeProvider.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.queue_music,
            size: AppConstants.extraLargeIconSize,
            color: themeProvider.primaryColor,
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            'Ready to generate your playlist!',
            style: TextStyle(
              fontSize: AppConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            'We\'ll analyze your commits and create a personalized Eurovision playlist',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeProvider.textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          ElevatedButton(
            onPressed: () => appState.generatePlaylist(),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome),
                const SizedBox(width: AppConstants.smallSpacing),
                Text(
                  'Generate Playlist',
                  style: TextStyle(
                    fontSize: AppConstants.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylist(AppStateProvider appState, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(
          color: themeProvider.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Header with mood
          _buildPlaylistHeader(appState, themeProvider),
          
          // Song list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appState.playlist.length,
            separatorBuilder: (context, index) => Divider(
              color: themeProvider.primaryColor.withValues(alpha: 0.1),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final song = appState.playlist[index];
              return _buildSongTile(
                song,
                index,
                appState,
                themeProvider,
              );
            },
          ),

          // Share widget
          const SizedBox(height: AppConstants.defaultSpacing),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ModernShareWidget(
              playlistData: {
                'playlist': {
                  'mood': appState.detectedVibe?.name ?? 'productive',
                  'songs': appState.playlist
                }
              },
              githubHandle: appState.githubUsername,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistHeader(AppStateProvider appState, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.primaryColor.withValues(alpha: 0.1),
            themeProvider.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getMoodIcon(appState.detectedVibe),
              color: themeProvider.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ YOUR EUROVISION CODING PLAYLIST ✨',
                  style: TextStyle(
                    fontSize: AppConstants.headingFontSize,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  ),
                  child: Text(
                    'CODE VIBE DETECTED: ${appState.detectedVibe?.displayName.toUpperCase() ?? "PRODUCTIVE"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your commits are radiating some serious energy ⚡',
                  style: TextStyle(
                    color: themeProvider.textColor.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  '${appState.playlist.length} Eurovision songs • Based on ${appState.commits.length} commits',
                  style: TextStyle(
                    color: themeProvider.textColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile(
    Map<String, dynamic> song,
    int index,
    AppStateProvider appState,
    ThemeProvider themeProvider,
  ) {
    final isPlaying = appState.currentlyPlayingIndex == index && appState.isPlaying;
    final isCurrentSong = appState.currentlyPlayingIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: isCurrentSong ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentSong ? BorderSide(
          color: themeProvider.primaryColor,
          width: 1.5,
        ) : BorderSide.none,
      ),
      child: Column(
        children: [
          // Album art and song info
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: _buildSongImage(song, themeProvider),
            title: Text(
              song['title'] ?? 'Unknown Title',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentSong 
                    ? themeProvider.primaryColor 
                    : themeProvider.textColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${song['artist'] ?? 'Unknown Artist'} • ${song['country'] ?? 'Unknown'} (${song['year'] ?? 'Unknown'})',
                  style: TextStyle(
                    color: themeProvider.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Reasoning
          if (song['reasoning'] != null && song['reasoning'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                song['reasoning'].toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: themeProvider.textColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          
          // Playback controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SongPlayerWidget(
              song: song,
              playlistGenerator: Provider.of<PlaylistGenerator>(appState.context, listen: false),
            ),
          ),
        ],
      ),
    );
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: themeProvider.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
      trailing: _buildPlayButton(song, index, isPlaying, appState, themeProvider),
      onTap: () => _handleSongTap(song, index, appState),
    );
  }

  Widget _buildSongImage(Map<String, dynamic> song, ThemeProvider themeProvider) {
    final imageUrl = song['imageUrl'] as String?;
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: themeProvider.surfaceColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackIcon(themeProvider);
                },
              )
            : _buildFallbackIcon(themeProvider),
      ),
    );
  }

  Widget _buildFallbackIcon(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.primaryColor.withValues(alpha: 0.1),
            themeProvider.primaryColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.music_note,
            color: themeProvider.primaryColor,
            size: 24,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: themeProvider.primaryColor,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(
    Map<String, dynamic> song,
    int index,
    bool isPlaying,
    AppStateProvider appState,
    ThemeProvider themeProvider,
  ) {
    final hasPreview = song['preview_url'] != null && 
                      (song['preview_url'] as String).isNotEmpty;
    final isCurrentSong = appState.currentlyPlayingIndex == index;
    
    return IconButton(
      icon: Icon(
        (isCurrentSong && isPlaying) ? Icons.pause_circle_filled : Icons.play_circle_filled,
        size: 32,
      ),
      color: hasPreview ? themeProvider.primaryColor : Colors.grey,
      onPressed: () => _handlePlayButtonTap(index, isCurrentSong && isPlaying, appState, song),
    );
  }

  void _handleSongTap(Map<String, dynamic> song, int index, AppStateProvider appState) {
    final hasPreview = song['preview_url'] != null && 
                      (song['preview_url'] as String).isNotEmpty;
    
    if (hasPreview) {
      _handlePlayButtonTap(index, 
          appState.currentlyPlayingIndex == index && appState.isPlaying, 
          appState, song);
    }
  }

  void _handlePlayButtonTap(int index, bool isPlaying, AppStateProvider appState, Map<String, dynamic> song) async {
    final hasPreview = song['preview_url'] != null && 
                      (song['preview_url'] as String).isNotEmpty;
                      
    if (hasPreview) {
      if (isPlaying) {
        appState.pausePlayback();
      } else if (appState.currentlyPlayingIndex == index) {
        appState.resumePlayback();
      } else {
        appState.playSong(index);
      }
    } else {
      final spotifyUrl = song['webPlayerUrl'] as String?;
      if (spotifyUrl != null && spotifyUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(spotifyUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          // Error handled silently for better UX
        }
      }
    }
  }

  IconData _getMoodIcon(CodingMood? mood) {
    switch (mood) {
      case CodingMood.frustrated:
        return Icons.sentiment_dissatisfied;
      case CodingMood.focused:
        return Icons.center_focus_strong;
      case CodingMood.creative:
        return Icons.lightbulb;
      case CodingMood.productive:
        return Icons.trending_up;
      case CodingMood.debugging:
        return Icons.bug_report;
      case CodingMood.experimental:
        return Icons.science;
      default:
        return Icons.code;
    }
  }
}