import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Basic GitHub API Integration Service for Phase 1
class GitHubService {

  /// Fetch commits for a GitHub user
  Future<List<Map<String, dynamic>>> fetchUserCommits(String username) async {
    if (username.trim().isEmpty) {
      throw Exception('Please enter a GitHub username');
    }

    try {
      final uri = Uri.parse('${ApiConfig.githubApiEndpoint}/users/$username/events');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': ApiConfig.userAgent,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 404) {
        throw Exception('User not found. Please check the username.');
      } else if (response.statusCode != 200) {
        throw Exception('Error accessing GitHub API: ${response.statusCode}');
      }

      final List<dynamic> events = jsonDecode(response.body);
      final commits = <Map<String, dynamic>>[];

      for (final event in events) {
        if (event['type'] == 'PushEvent') {
          final payload = event['payload'];
          if (payload != null && payload['commits'] != null) {
            for (final commit in payload['commits']) {
              if (commit['message'] != null) {
                commits.add({
                  'message': commit['message'],
                  'author': commit['author']?['name'] ?? username,
                  'date': event['created_at'],
                });
              }
            }
          }
        }
        if (commits.length >= 5) break; // Limit to 5 commits for phase 1
      }

      if (commits.isEmpty) {
        throw Exception('No commits found for this user');
      }

      return commits;
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your connection.');
      }
      rethrow;
    }
  }
}