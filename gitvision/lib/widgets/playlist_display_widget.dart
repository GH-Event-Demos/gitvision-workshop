import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state_provider.dart';
import '../models/coding_mood.dart';
import '../services/playlist_generator.dart';
import 'song_player_widget.dart';

class PlaylistDisplayWidget extends StatelessWidget {
  const PlaylistDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    
    print('🎼 [PlaylistWidget] Building UI - commits: ${appState.commits.length}, generating: ${appState.generatingPlaylist}, generated: ${appState.playlistGenerated}, songs: ${appState.playlist.length}');

    if (appState.generatingPlaylist) {
      print('🎼 [PlaylistWidget] Showing generating state');
      return _buildGeneratingState();
    }

    if (!appState.playlistGenerated || appState.playlist.isEmpty) {
      print('🎼 [PlaylistWidget] Showing generate button');
      return _buildGenerateButton(appState);
    }

    print('🎼 [PlaylistWidget] Showing playlist with ${appState.playlist.length} songs');
    return _buildPlaylist(appState);
  }

  Widget _buildGeneratingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Generating your Eurovision playlist...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Analyzing your commits 🎤'),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(AppStateProvider appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.queue_music,
            size: 64,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to generate your playlist!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll analyze your commits and create a personalized Eurovision playlist',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              print('🎼 [PlaylistWidget] Generate button clicked!');
              appState.generatePlaylist();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Playlist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylist(AppStateProvider appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getMoodIcon(appState.detectedVibe),
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Eurovision Playlist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Mood: ${appState.detectedVibe?.displayName ?? "Productive"}',
                style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${appState.playlist.length} songs • Based on ${appState.commits.length} commits',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Song list
        Expanded(
          child: ListView.builder(
            itemCount: appState.playlist.length,
            itemBuilder: (context, index) {
              final song = appState.playlist[index];
              return _buildSongTile(song, index, appState);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongTile(Map<String, dynamic> song, int index, AppStateProvider appState) {
    final isCurrentSong = appState.currentlyPlayingIndex == index;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrentSong ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song['title'] ?? 'Unknown Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isCurrentSong ? Colors.deepPurple : null,
                        ),
                      ),
                      Text(
                        '${song['artist'] ?? 'Unknown Artist'} • ${song['country'] ?? 'Unknown'} (${song['year'] ?? 'Unknown'})',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // First try to play in-app if preview URL exists
                    if (song['preview_url'] != null && song['preview_url'].toString().isNotEmpty) {
                      print('🎵 Playing song with preview: ${song['preview_url']}');
                      appState.playSong(index);
                    } else {
                      // Try different URL sources
                      final webUrl = song['webPlayerUrl'] ?? song['spotifyUrl'];
                      final title = song['title'] ?? '';
                      final artist = song['artist'] ?? '';
                      
                      print('🎵 Song data: $song');
                      print('🎵 Trying to open: $webUrl');
                      
                      if (webUrl != null && webUrl.toString().isNotEmpty) {
                        try {
                          final url = Uri.parse(webUrl.toString());
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                            print('🎵 Opened Spotify URL: $webUrl');
                          } else {
                            print('🎵 Cannot launch URL: $webUrl');
                          }
                        } catch (e) {
                          print('🎵 Error launching URL: $e');
                        }
                      } else {
                        // Fallback: Search on Spotify web
                        final searchUrl = 'https://open.spotify.com/search/${Uri.encodeComponent('$title $artist')}';
                        try {
                          final url = Uri.parse(searchUrl);
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                          print('🎵 Opened Spotify search: $searchUrl');
                        } catch (e) {
                          print('🎵 Error opening Spotify search: $e');
                        }
                      }
                    }
                  },
                  icon: Icon(
                    song['preview_url'] != null && song['preview_url'].toString().isNotEmpty
                        ? (isCurrentSong && appState.isPlaying ? Icons.pause : Icons.play_arrow)
                        : Icons.open_in_new
                  ),
                  label: Text(
                    song['preview_url'] != null && song['preview_url'].toString().isNotEmpty
                        ? (isCurrentSong && appState.isPlaying ? 'Pause' : 'Play')
                        : 'Spotify'
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: song['preview_url'] != null && song['preview_url'].toString().isNotEmpty
                        ? Colors.deepPurple
                        : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            if (song['reasoning'] != null && song['reasoning'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                song['reasoning'].toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
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