import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../widgets/github_connection_widget.dart';
import '../widgets/playlist_display_widget.dart';
import '../widgets/audio_player_widget.dart';
import '../services/theme_provider.dart';
import '../widgets/glassmorphic_container.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, themeProvider),
                
                // Main Content
                Expanded(
                  child: _buildMainContent(context, appState, themeProvider),
                ),
                
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

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: themeProvider.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: GlassmorphicContainer(
        borderRadius: 24,
        blur: 10,
        opacity: 0.1,
        color: Colors.white,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.8),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'GitVision',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Action buttons group
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.palette_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => themeProvider.randomizeTheme(),
                      tooltip: 'Randomize theme colors',
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                      tooltip: 'Toggle dark/light mode',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🎵 Your commits have been busy... let\'s see what they sound like',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    AppStateProvider appState,
    ThemeProvider themeProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error Display
          if (appState.lastError != null)
            _buildErrorCard(context, appState, themeProvider),

          // GitHub Connection Section
          _buildSection(
            title: 'Connect Repository',
            icon: Icons.code,
            child: const GitHubConnectionWidget(),
            themeProvider: themeProvider,
          ),

          const SizedBox(height: 24),

          // Playlist Section
          if (appState.commits.isNotEmpty)
            _buildSection(
              title: 'Your Eurovision Playlist',
              icon: Icons.queue_music,
              child: const PlaylistDisplayWidget(),
              themeProvider: themeProvider,
            ),

          const SizedBox(height: 24),

          // Stats Section
          if (appState.playlistGenerated)
            _buildStatsSection(context, appState, themeProvider),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    AppStateProvider appState,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
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
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: themeProvider.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    AppStateProvider appState,
    ThemeProvider themeProvider,
  ) {
    return _buildSection(
      title: 'Playlist Stats',
      icon: Icons.analytics,
      themeProvider: themeProvider,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            _buildStatRow(
              'Songs Generated',
              '${appState.playlist.length}',
              Icons.music_note,
              themeProvider,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Detected Mood',
              appState.detectedVibe?.displayName ?? 'Unknown',
              Icons.mood,
              themeProvider,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Commits Analyzed',
              '${appState.commits.length}',
              Icons.commit,
              themeProvider,
            ),
            if (appState.playlistAnalysis != null) ...[
              const SizedBox(height: 16),
              Text(
                'Analysis',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appState.playlistAnalysis!,
                style: TextStyle(
                  color: themeProvider.textColor.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: themeProvider.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: themeProvider.textColor.withValues(alpha: 0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
      ],
    );
  }
}