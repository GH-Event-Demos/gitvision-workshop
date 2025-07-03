import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../services/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.primaryColor.withValues(alpha: 0.2),
        ),
      ),
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
                color: themeProvider.primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryColor,
                  width: 2,
                ),
              ),
            ),
            style: TextStyle(color: themeProvider.textColor),
            onChanged: (value) {
              print('DEBUG: TextField onChanged called with: $value');
              appState.updateGitHubUsername(value);
            },
            onSubmitted: (value) {
              print('DEBUG: TextField onSubmitted called with: $value');
              if (value.isNotEmpty) {
                _connectToUser(appState);
              }
            },
          ),

          const SizedBox(height: 16),

          // Repository status
          _buildRepositoryStatus(appState, themeProvider),

          const SizedBox(height: 16),

          // Connect button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: appState.githubUsername.isNotEmpty && !appState.isConnecting
                  ? () => _connectToUser(appState)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: appState.isConnecting
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
            _buildUserInfo(appState, themeProvider),
        ],
      ),
    );
  }

  Widget _buildRepositoryStatus(AppStateProvider appState, ThemeProvider themeProvider) {
    // Only show status after user has tried to connect
    if (appState.githubUsername.isEmpty || (!appState.isConnecting && appState.commits.isEmpty && appState.lastError == null)) {
      return const SizedBox.shrink();
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (appState.isConnecting) {
      statusColor = Colors.orange;
      statusIcon = Icons.sync;
      statusText = 'Digging through your commits...';
    } else if (appState.commits.isNotEmpty) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Found ${appState.commits.length} recent commits';
    } else if (appState.lastError != null) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = appState.lastError!;
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

  Widget _buildUserInfo(AppStateProvider appState, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: themeProvider.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '@${appState.githubUsername}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.commit,
                color: themeProvider.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${appState.commits.length} recent commits analyzed',
                style: TextStyle(
                  color: themeProvider.textColor.withValues(alpha: 0.8),
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
    await appState.connectToGitHubUser();
    
    // Generate playlist automatically if commits are loaded
    if (appState.commits.isNotEmpty) {
      await appState.generatePlaylist();
    }
  }
}