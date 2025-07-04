import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? _detectedMood;

  Future<void> _analyzeGitHubProfile() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage =
            '🎵 Please enter a GitHub username to start the Eurovision magic!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _commitMessages = [];
      _detectedMood = null;
    });

    try {
      await _fetchGitHubCommits(username);
      _analyzeCommitSentiment();
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
    // Real GitHub API integration - Phase 1 complete implementation
    final uri = Uri.parse('https://api.github.com/users/$username/events');

    final headers = {
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'GitVision-Eurovision-App',
    };

    try {
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              '🎵 Eurovision timeout! Even the best performances need good timing. Please try again!');
        },
      );

      if (response.statusCode == 403) {
        throw Exception(
            '🎵 Eurovision break time! GitHub API rate limit exceeded. Even Eurovision has intermissions - try again in an hour!');
      } else if (response.statusCode == 404) {
        throw Exception(
            '🔍 This GitHub user is more elusive than a Eurovision winner prediction! Please check the username.');
      } else if (response.statusCode != 200) {
        throw Exception(
            '🎭 GitHub API drama! Status code: ${response.statusCode}');
      }

      final List<dynamic> events = jsonDecode(response.body);
      final List<String> commits = [];

      for (final event in events) {
        if (event['type'] == 'PushEvent' &&
            event['payload']?['commits'] != null) {
          for (final commit in event['payload']['commits']) {
            if (commit['message'] != null) {
              commits.add(commit['message']);
              if (commits.length >= 10) break; // Limit to 10 commits
            }
          }
        }
        if (commits.length >= 10) break;
      }

      if (commits.isEmpty) {
        throw Exception(
            '🎵 No recent commits found! This user is as mysterious as Eurovision\'s voting system.');
      }

      setState(() {
        _commitMessages = commits;
      });
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection failed')) {
        throw Exception(
            '🌐 Eurovision needs the internet! Please check your connection and try again.');
      } else {
        rethrow;
      }
    }
  }

  void _analyzeCommitSentiment() {
    // Eurovision-themed sentiment analysis - Phase 1 implementation
    final allText = _commitMessages.join(' ').toLowerCase();

    final moodKeywords = {
      'productive': [
        'add',
        'implement',
        'create',
        'feature',
        'update',
        'build',
        'develop'
      ],
      'debugging': [
        'fix',
        'bug',
        'issue',
        'error',
        'crash',
        'debug',
        'resolve'
      ],
      'creative': [
        'design',
        'style',
        'ui',
        'animation',
        'theme',
        'experiment',
        'refactor'
      ],
      'victory': [
        'release',
        'deploy',
        'complete',
        'finish',
        'milestone',
        'ship',
        'merge'
      ],
      'reflective': [
        'cleanup',
        'organize',
        'document',
        'improve',
        'optimize',
        'review'
      ],
    };

    String detectedMood = 'productive'; // default
    int maxCount = 0;

    moodKeywords.forEach((mood, keywords) {
      int count = 0;
      for (final keyword in keywords) {
        count += keyword.allMatches(allText).length;
      }
      if (count > maxCount) {
        maxCount = count;
        detectedMood = mood;
      }
    });

    setState(() {
      _detectedMood = detectedMood;
    });
  }

  String _getEurovisionMoodDescription(String mood) {
    switch (mood) {
      case 'productive':
        return '🎵 Productive Flow - Like Eurovision upbeat anthems! (Euphoria vibes)';
      case 'debugging':
        return '🔥 Debugging Intensity - Like Eurovision power ballads! (Rise Like a Phoenix)';
      case 'creative':
        return '🎨 Creative Experimental - Like unique Eurovision entries! (Epic Sax Guy energy)';
      case 'victory':
        return '🏆 Victory Breakthrough - Like Eurovision winners! (Waterloo moment)';
      case 'reflective':
        return '💭 Reflective Cleanup - Like emotional Eurovision songs! (Arcade feels)';
      default:
        return '🎵 Eurovision coding vibes detected!';
    }
  }

  Widget _buildCommitsList() {
    if (_commitMessages.isEmpty) return const SizedBox.shrink();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_detectedMood != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🇪🇺 Eurovision Coding Mood Detected:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getEurovisionMoodDescription(_detectedMood!),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.commit, color: Colors.deepPurple),
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
                  'Enter a GitHub username to analyze commit patterns and discover your Eurovision coding vibe:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
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
                            Text('Analyzing Eurovision vibes...'),
                          ],
                        )
                      : const Text('🎵 Analyze GitHub Profile'),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
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
