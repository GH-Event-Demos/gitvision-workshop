import 'package:flutter/material.dart';
import 'models/sentiment_result.dart';
import 'widgets/commit_analysis_display.dart';
import 'sentiment_analyzer.dart';

void main() {
  runApp(const GitVisionApp());
}

class GitVisionApp extends StatelessWidget {
  const GitVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitVision - Eurovision Edition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GitHubAnalyzerScreen(),
    );
  }
}

class GitHubAnalyzerScreen extends StatefulWidget {
  const GitHubAnalyzerScreen({super.key});

  @override
  State<GitHubAnalyzerScreen> createState() => _GitHubAnalyzerScreenState();
}

class _GitHubAnalyzerScreenState extends State<GitHubAnalyzerScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _commitMessages = [];

  Future<void> _analyzeGitHubProfile() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a GitHub username';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _commitMessages = [];
    });

    try {
      // Workshop TODO: Students will implement GitHub API integration here
      // For now, this is a simplified demo version
      await _fetchGitHubCommits(username);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchGitHubCommits(String username) async {
    // Workshop TODO: Implement real GitHub API call
    // This is a placeholder for Phase 1 starting point
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock data for workshop starting point
    setState(() {
      _commitMessages = [
        'Fix critical bug in authentication',
        'Add new feature for user profiles',
        'Refactor database connection logic',
        'Update documentation and README',
        'Implement error handling for API calls'
      ];
    });
  }

  Widget _buildCommitsList() {
    if (_commitMessages.isEmpty) return const SizedBox.shrink();
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recent Commits:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _commitMessages.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.commit),
                    title: Text(_commitMessages[index]),
                    subtitle: Text('Commit #${index + 1}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          children: [
            Text('🎵 GitVision - Eurovision Edition'),
            SizedBox(width: 8),
            Text('🇪🇺', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Enter a GitHub username to analyze commit patterns:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'GitHub Username',
                    hintText: 'e.g., octocat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _analyzeGitHubProfile,
                  child: _isLoading 
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Analyzing...'),
                        ],
                      )
                    : const Text('Analyze GitHub Profile'),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          _buildCommitsList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
