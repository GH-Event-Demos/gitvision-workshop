import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../widgets/github_connection_widget.dart';
import '../widgets/playlist_display_widget.dart';
import '../widgets/audio_player_widget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitVision - Eurovision Edition'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          print('🏠 [MainScreen] Building with ${appState.commits.length} commits');
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Error Display
                if (appState.lastError != null)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              appState.lastError!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => appState.clearError(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // GitHub Connection Section
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect Repository',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        GitHubConnectionWidget(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Debug test button
                ElevatedButton(
                  onPressed: () {
                    print('🧪 [Test] Manual playlist generation triggered');
                    appState.generatePlaylist();
                  },
                  child: Text('🧪 TEST: Generate Playlist (${appState.commits.length} commits)'),
                ),

                const SizedBox(height: 16),

                // Playlist Section
                if (appState.commits.isNotEmpty) ...[
                  Text('🏠 Found ${appState.commits.length} commits - showing playlist section'),
                  const Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Eurovision Playlist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Expanded(child: PlaylistDisplayWidget()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Audio Player (if playing)
                if (appState.isPlaying || appState.currentlyPlayingIndex != null)
                  const AudioPlayerWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}