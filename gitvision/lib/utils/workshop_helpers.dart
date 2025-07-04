// Workshop helper utilities for GitVision
// These utilities help instructors and participants during the workshop

import 'dart:convert';
import 'package:flutter/services.dart';
import 'demo_data.dart';

class WorkshopHelpers {
  // Test different API endpoints quickly
  static const Map<String, String> apiEndpoints = {
    'github_api': 'https://api.github.com',
    'github_models': 'https://models.github.ai/inference',
    'spotify_auth': 'https://accounts.spotify.com/api/token',
    'spotify_api': 'https://api.spotify.com/v1',
  };
  
  // Quick health check for APIs (for troubleshooting)
  static Future<Map<String, bool>> checkAPIHealth() async {
    final results = <String, bool>{};
    
    // This would typically make actual HTTP requests
    // For workshop, we'll simulate the checks
    for (final endpoint in apiEndpoints.keys) {
      // Simulate API health check
      results[endpoint] = true; // In real implementation, make HTTP request
    }
    
    return results;
  }
  
  // Generate realistic commit messages for testing
  static List<String> generateTestCommits(String mood, {int count = 5}) {
    final commits = DemoData.getSampleCommitsForMood(mood);
    if (commits.length >= count) {
      return commits.take(count).toList();
    }
    
    // If we need more commits, cycle through the list
    final result = <String>[];
    for (int i = 0; i < count; i++) {
      result.add(commits[i % commits.length]);
    }
    return result;
  }
  
  // Validate API token format (without exposing the token)
  static Map<String, bool> validateTokenFormats({
    required String githubToken,
    required String spotifyClientId,
    required String spotifyClientSecret,
  }) {
    return {
      'github_token_format': githubToken.startsWith('ghp_') && githubToken.length > 20,
      'spotify_client_id_format': spotifyClientId.length == 32,
      'spotify_client_secret_format': spotifyClientSecret.length == 32,
    };
  }
  
  // Copy sample API response to clipboard (for debugging)
  static Future<void> copySampleAPIResponse(String type) async {
    late String sampleResponse;
    
    switch (type) {
      case 'github_commits':
        sampleResponse = json.encode([
          {
            'type': 'PushEvent',
            'payload': {
              'commits': [
                {
                  'message': 'Add new feature',
                  'author': {'name': 'Developer'}
                }
              ]
            },
            'created_at': '2024-01-15T10:30:00Z'
          }
        ]);
        break;
        
      case 'ai_eurovision_response':
        sampleResponse = json.encode([
          {
            'title': 'Euphoria',
            'artist': 'Loreen',
            'country': 'Sweden',
            'year': 2012,
            'reasoning': 'Perfect high-energy song for productive coding'
          }
        ]);
        break;
        
      case 'spotify_search_response':
        sampleResponse = json.encode({
          'tracks': {
            'items': [
              {
                'id': 'spotify_track_id',
                'name': 'Euphoria',
                'artists': [{'name': 'Loreen'}],
                'external_urls': {'spotify': 'https://open.spotify.com/track/...'}
              }
            ]
          }
        });
        break;
        
      default:
        sampleResponse = '{"error": "Unknown sample type"}';
    }
    
    await Clipboard.setData(ClipboardData(text: sampleResponse));
  }
  
  // Workshop progress tracker
  static Map<String, dynamic> getWorkshopProgress({
    required bool githubIntegrationWorking,
    required bool aiServiceImplemented,
    required bool spotifyServiceImplemented,
  }) {
    final totalSteps = 3;
    var completedSteps = 0;
    
    if (githubIntegrationWorking) completedSteps++;
    if (aiServiceImplemented) completedSteps++;
    if (spotifyServiceImplemented) completedSteps++;
    
    return {
      'completed_steps': completedSteps,
      'total_steps': totalSteps,
      'percentage': (completedSteps / totalSteps * 100).round(),
      'next_step': _getNextStep(completedSteps),
      'estimated_time_remaining': _getEstimatedTimeRemaining(completedSteps),
    };
  }
  
  static String _getNextStep(int completedSteps) {
    switch (completedSteps) {
      case 0: return 'Setup GitHub API integration';
      case 1: return 'Implement AI Eurovision service';
      case 2: return 'Add Spotify integration';
      default: return 'Workshop complete! 🎉';
    }
  }
  
  static String _getEstimatedTimeRemaining(int completedSteps) {
    switch (completedSteps) {
      case 0: return '120 minutes';
      case 1: return '85 minutes'; 
      case 2: return '35 minutes';
      default: return '0 minutes';
    }
  }
  
  // Common workshop error messages and solutions
  static const Map<String, String> commonErrors = {
    'github_401': '''
GitHub API Error 401: Check your GitHub token
- Ensure token has 'repo' and 'user' scopes
- Verify token is not expired
- Make sure token is correctly set in api_tokens.dart
''',
    'github_403': '''
GitHub API Error 403: Rate limit exceeded
- Wait 1 hour for rate limit reset
- Use a different GitHub token
- Check if token has proper permissions
''',
    'spotify_400': '''
Spotify API Error 400: Bad request
- Check Client ID and Client Secret format
- Verify redirect URI matches Spotify app settings
- Ensure request body is properly formatted
''',
    'flutter_build_error': '''
Flutter build error:
- Run 'flutter clean' then 'flutter pub get'
- Check 'flutter doctor' for issues
- Restart your IDE
- Ensure Flutter SDK is up to date
''',
  };
  
  // Get help text for common errors
  static String getErrorHelp(String errorType) {
    return commonErrors[errorType] ?? 'Unknown error type. Check workshop documentation.';
  }
}