import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/api_config.dart';
import '../services/logging_service.dart';

/// 🔗 PHASE 1: GitHub API Integration Service
/// 
/// This service demonstrates:
/// - RESTful API integration with GitHub
/// - Error handling and user feedback
/// - Data processing and transformation
/// - Network connectivity checks
/// 
/// Basic GitHub API Integration Service
class GitHubService {
  final LoggingService _logger;
  final Connectivity _connectivity;

  GitHubService({required LoggingService logger}) 
    : _logger = logger,
      _connectivity = Connectivity();
  
  /// Check for internet connectivity
  Future<bool> checkConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// 📊 Fetch public commits for a given GitHub handle
  /// 
  /// This method demonstrates the complete API integration flow:
  /// 1. Input validation
  /// 2. Connectivity check  
  /// 3. HTTP request with proper headers
  /// 4. Response handling and error processing
  /// 5. Data transformation for the app
  /// 
  /// Returns a map containing commit messages and structured commit data
  Future<Map<String, dynamic>> fetchUserCommits(String githubHandle) async {
    // Debug: print('🔗 [GitHub API] Fetching commits for: $githubHandle');
    if (githubHandle.trim().isEmpty) {
      throw Exception('Please enter a GitHub handle');
    }

    // Check for connectivity first
    // Debug: print('🌐 [GitHub API] Checking connectivity...');
    bool isConnected = await checkConnectivity();
    if (!isConnected) {
      // Debug: print('❌ [GitHub API] No internet connection detected');
      throw Exception('No internet connection. Please check your network settings and try again.');
    }
    // Debug: print('✅ [GitHub API] Connection established');

    try {
      // Use search API to find user's commits
      final uri = Uri.parse('https://api.github.com/search/commits?q=author:$githubHandle&sort=author-date&order=desc');
      
      final headers = {
        'Accept': 'application/vnd.github.cloak-preview+json',
        'User-Agent': ApiConfig.userAgent,
        if (ApiConfig.hasValidTokens)
          'Authorization': 'token ${ApiConfig.githubToken}',
      };
      print('🚀 [GitHub API] Making request to: ${uri.toString()}');

      // Use timeout to avoid hanging on slow connections
      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out. Please try again later.');
            },
          );

      // Workshop: Demonstrate HTTP status code handling
      print('📊 [GitHub API] Response status: ${response.statusCode}');
      print('📊 [GitHub API] Response body preview: ${response.body.length > 100 ? "${response.body.substring(0, 100)}..." : response.body}');
      
      if (response.statusCode == 403) {
        // Debug: print('⚠️ [GitHub API] Rate limit exceeded');
        throw Exception('GitHub API rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 404) {
        // Debug: print('❌ [GitHub API] User not found');
        throw Exception('GitHub user not found. Please check the handle.');
      } else if (response.statusCode != 200) {
        // Debug: print('❌ [GitHub API] Unexpected status code: ${response.statusCode}');
        throw Exception('Error accessing GitHub API: ${response.statusCode}');
      }
      // Debug: print('✅ [GitHub API] Request successful');

      final Map<String, dynamic> searchResult;
      try {
        searchResult = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Error parsing GitHub response');
      }

      return _processCommitSearch(searchResult, githubHandle);
    } catch (e) {
      // Handle network errors with user-friendly messages
      print('❌ [GitHub API] Exception occurred: $e');
      String errorMsg = e.toString();
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('Connection failed') ||
          errorMsg.contains('ClientException') ||
          errorMsg.contains('Operation not permitted')) {
        throw Exception('Network connection error: The app is having trouble connecting to GitHub.\n\nPlease check your internet connection and try again.');
      } else if (errorMsg.contains('404')) {
        throw Exception('GitHub API Error: User not found. Please check the handle and try again.');
      } else if (errorMsg.contains('403')) {
        throw Exception('GitHub API Rate Limit: Too many requests. Please try again later.');
      } else if (errorMsg.contains('401')) {
        throw Exception('Authentication Error: API token may be invalid. Please check the configuration.');
      } else {
        rethrow;
      }
    }
  }

  /// 🔄 Process GitHub events and extract commit data
  /// 
  /// Process commit search results from GitHub Search API
  Map<String, dynamic> _processCommitSearch(Map<String, dynamic> searchResult, String githubHandle) {
    print('🔍 [GitHub API] Processing search results...');
    final List<String> commitMessages = [];
    final List<Map<String, dynamic>> commitData = [];

    if (searchResult['items'] == null) {
      throw Exception('No commits found for this user');
    }

    final List<dynamic> commits = searchResult['items'];
    print('🔍 [GitHub API] Found ${commits.length} commits in search results');

    for (final commit in commits) {
      if (commit['commit'] != null && commit['commit']['message'] != null) {
        final message = commit['commit']['message'];
        final author = commit['commit']['author']?['name'] ?? githubHandle;
        final date = commit['commit']['author']?['date'] ?? DateTime.now().toIso8601String();

        commitMessages.add(message);
        commitData.add({
          'message': message,
          'author': author,
          'date': date,
        });

        print('🔍 [GitHub API] Added commit: ${message.length > 50 ? message.substring(0, 50) + "..." : message}');

        if (commitMessages.length >= 50) break;
      }
    }

    print('📈 [GitHub API] Found ${commitMessages.length} commit messages');

    if (commitMessages.isEmpty) {
      throw Exception('No public commits found for this user');
    }

    return {
      'commitMessages': commitMessages,
      'commitData': commitData,
    };
  }

  /// Workshop: This method shows how to:
  /// - Parse complex JSON structures
  /// - Filter relevant data from API responses
  /// - Transform data for app consumption
  Map<String, dynamic> _processCommitEvents(List<dynamic> events, String githubHandle) {
    print('🔍 [GitHub API] Processing ${events.length} events for $githubHandle...');
    final List<String> commitMessages = [];
    final List<Map<String, dynamic>> commitData = [];

    for (final event in events) {
      print('🔍 [GitHub API] Event type: ${event['type']}');
      if (event['type'] == 'PushEvent') {
        print('🔍 [GitHub API] Found PushEvent, checking payload...');
        print('🔍 [GitHub API] Payload: ${event['payload']}');
        if (event['payload'] != null && event['payload']['commits'] != null) {
          for (final commit in event['payload']['commits']) {
            if (commit['message'] != null) {
              commitMessages.add(commit['message']);

              // Add to structured commit data for playlist generator
              commitData.add({
                'message': commit['message'],
                'author': commit['author']?['name'] ?? githubHandle,
                'date': event['created_at'] ?? DateTime.now().toIso8601String(),
              });

              if (commitMessages.length >= 50) break;
            }
          }
        }
      }
      if (commitMessages.length >= 50) break;
    }

    print('📈 [GitHub API] Found ${commitMessages.length} commits');

    if (commitMessages.isEmpty) {
      print('❌ [GitHub API] No commits found for user');
      throw Exception('No public commits found for this user');
    }

    // Debug: print('✅ [GitHub API] Data processing complete');
    return {
      'commitMessages': commitMessages,
      'commitData': commitData,
    };
  }

  /// Get commits from a specific repository
  Future<List<Map<String, dynamic>>> getCommits({
    required String owner,
    required String repo,
    String? branch,
    int? limit,
    DateTime? since,
    DateTime? until,
  }) async {
    final url = 'https://api.github.com/repos/$owner/$repo/commits';
    final queryParams = <String, String>{};
    
    if (branch != null) queryParams['sha'] = branch;
    if (limit != null) queryParams['per_page'] = limit.toString();
    if (since != null) queryParams['since'] = since.toIso8601String();
    if (until != null) queryParams['until'] = until.toIso8601String();
    
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitVision-App',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> commits = json.decode(response.body);
        return commits.map((commit) => {
          'message': commit['commit']['message'],
          'author': commit['commit']['author']['name'],
          'date': commit['commit']['author']['date'],
          'sha': commit['sha'],
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Repository not found');
      } else {
        throw Exception('Failed to fetch commits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching commits: $e');
    }
  }

  /// Check if a repository exists and is accessible
  Future<bool> repositoryExists({
    required String owner,
    required String repo,
  }) async {
    final url = 'https://api.github.com/repos/$owner/$repo';
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitVision-App',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get repository information
  Future<Map<String, dynamic>> getRepositoryInfo({
    required String owner,
    required String repo,
  }) async {
    final url = 'https://api.github.com/repos/$owner/$repo';
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitVision-App',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'name': data['name'],
          'full_name': data['full_name'],
          'description': data['description'],
          'stars': data['stargazers_count'],
          'forks': data['forks_count'],
          'language': data['language'],
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        };
      } else {
        throw Exception('Failed to fetch repository info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching repository info: $e');
    }
  }

  /// Get branches for a repository
  Future<List<String>> getBranches({
    required String owner,
    required String repo,
  }) async {
    final url = 'https://api.github.com/repos/$owner/$repo/branches';
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitVision-App',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> branches = json.decode(response.body);
        return branches.map((branch) => branch['name'] as String).toList();
      } else {
        throw Exception('Failed to fetch branches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching branches: $e');
    }
  }
}