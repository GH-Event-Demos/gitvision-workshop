import 'package:flutter/material.dart';
import '../services/github_service.dart';

class GitHubConnectionWidget extends StatefulWidget {
  const GitHubConnectionWidget({super.key});

  @override
  State<GitHubConnectionWidget> createState() => _GitHubConnectionWidgetState();
}

class _GitHubConnectionWidgetState extends State<GitHubConnectionWidget> {
  final _usernameController = TextEditingController();
  final _githubService = GitHubService();
  bool _isLoading = false;
  String? _error;

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
  List<Map<String, dynamic>>? _commits;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _connectToGitHub() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final commits = await _githubService.fetchUserCommits(username);
      setState(() {
        _commits = commits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _error = null),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            hintText: 'Enter GitHub username',
            prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _connectToGitHub(),
        ),

        const SizedBox(height: 16),

        if (_commits != null) ...[
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
                    'Found ${_commits!.length} commits for @${_usernameController.text}',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                children: _commits!.map((commit) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.commit, color: Colors.deepPurple),
                    title: Text(
                      commit['message'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'by ${commit['author']} • ${_formatDate(commit['date'])}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _connectToGitHub,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
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

        Text(
          'Enter your GitHub username to view your recent commits',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}