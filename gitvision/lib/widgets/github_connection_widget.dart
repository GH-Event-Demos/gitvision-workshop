import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class GitHubConnectionWidget extends StatefulWidget {
  const GitHubConnectionWidget({super.key});

  @override
  State<GitHubConnectionWidget> createState() => _GitHubConnectionWidgetState();
}

class _GitHubConnectionWidgetState extends State<GitHubConnectionWidget> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Input field
          TextField(
            controller: _urlController,
            enabled: true,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'your-github-username',
              prefixIcon: Icon(
                Icons.alternate_email,
                color: Colors.deepPurple,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              appState.updateUsername(value);
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _connectToUser(appState);
              }
            },
          ),

          const SizedBox(height: 16),

          // Repository status
          _buildRepositoryStatus(appState),

          const SizedBox(height: 16),

          // Connect button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: appState.githubUsername.isNotEmpty && !appState.isLoading
                  ? () => _connectToUser(appState)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: appState.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Connecting...'),
                      ],
                    )
                  : Text(
                      appState.commits.isNotEmpty ? 'Reconnect to GitHub' : 'Connect to GitHub',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          // User info
          if (appState.githubUsername.isNotEmpty && appState.commits.isNotEmpty)
            _buildUserInfo(appState),

          // Eurovision Suggestions
          if (appState.songSuggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '🎵 Eurovision Song Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            ...appState.songSuggestions.map((song) => _buildSongSuggestion(song)),
          ],
        ],
      ),
    ),
  );
}  Widget _buildSongSuggestion(Map<String, dynamic> song) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${song['title']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${song['artist']} • ${song['country']} ${song['year']}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${song['reasoning']}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildRatingChip(String label, num value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.deepPurple.shade100),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.deepPurple.shade700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${value.toInt()}/10',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade900,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildRepositoryStatus(AppStateProvider appState) {
    // Only show status after user has tried to connect
    if (appState.githubUsername.isEmpty || (!appState.isLoading && appState.commits.isEmpty && appState.error == null)) {
      return const SizedBox.shrink();
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (appState.isLoading) {
      statusColor = Colors.orange;
      statusIcon = Icons.sync;
      statusText = 'Digging through your commits...';
    } else if (appState.commits.isNotEmpty) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Found ${appState.commits.length} recent commits';
    } else if (appState.error != null) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = appState.error!;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(AppStateProvider appState) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '@${appState.githubUsername}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.commit,
                color: Colors.deepPurple,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${appState.commits.length} recent commits analyzed',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _connectToUser(AppStateProvider appState) async {
    await appState.analyzeMood();
  }
}