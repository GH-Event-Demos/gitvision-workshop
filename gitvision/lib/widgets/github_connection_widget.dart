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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'Enter GitHub username',
            prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            appState.updateGitHubUsername(value);
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _connectToUser(appState);
            }
          },
        ),

        const SizedBox(height: 16),

        // Repository status
        if (appState.commits.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connected! Found ${appState.commits.length} commits for @${appState.githubUsername}',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Connect button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: appState.githubUsername.isNotEmpty && !appState.isConnecting
                ? () => _connectToUser(appState)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: appState.isConnecting
                ? const Row(
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
                      SizedBox(width: 12),
                      Text('Connecting...'),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link),
                      SizedBox(width: 8),
                      Text('Connect to GitHub'),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Help text
        Text(
          'Enter your GitHub username to analyze your recent commits',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _connectToUser(AppStateProvider appState) {
    appState.connectToGitHubUser();
  }
}