import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/eurovision_song.dart';

class PlaylistGenerator {
  final String _githubToken;
  final String _endpoint;
  final String _model;
  
  PlaylistGenerator({
    required String githubToken,
    String endpoint = "https://models.github.ai/inference/chat/completions",
    String model = "gpt-4",
  }) : assert(githubToken.isNotEmpty, 'GitHub token cannot be empty'),
       _githubToken = githubToken,
       _endpoint = endpoint,
       _model = model {
    _debugLog('Initializing PlaylistGenerator with model: $_model');
  }

  // Debug utility - only prints in debug mode
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[PlaylistGenerator] $message');
    }
  }

  Future<Map<String, dynamic>> generatePlayablePlaylist(
      List<Map<String, dynamic>> commits) async {
    _debugLog('🎵 EUROVISION: Starting playlist generation from ${commits.length} commits');
    
    try {
      final commitMessages = _extractCommitMessages(commits);
      final moodData = await _analyzeMood(commitMessages);
      final mood = moodData['mood'];

      _debugLog('Mood analysis result: $mood (${moodData['reasoning']})');

      final playlistText = await _generatePlaylistWithRetry(commitMessages);
      final List<EurovisionSong> playlist = _parsePlaylistFromText(playlistText);
      
      final playlistJson = playlist.map((song) => song.toJson()).toList();
      
      return _buildPlaylistResult(commits, mood, moodData, playlistJson);
    } catch (e) {
      _debugLog('ERROR: Failed to generate playlist: $e');
      return _buildFallbackPlaylistResult(commits);
    }
  }

  List<String> _extractCommitMessages(List<Map<String, dynamic>> commits) {
    final messages = commits.map((c) => c['message'] as String).toList();
    _debugLog('Extracted ${messages.length} commit messages for analysis');
    return messages;
  }

  String _getEarliestDate(List<Map<String, dynamic>> commits) {
    final dates = commits.map((c) => DateTime.parse(c['date'] as String)).toList();
    final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    return earliest.toIso8601String();
  }

  String _getLatestDate(List<Map<String, dynamic>> commits) {
    final dates = commits.map((c) => DateTime.parse(c['date'] as String)).toList();
    final latest = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    return latest.toIso8601String();
  }

  Future<Map<String, dynamic>> _analyzeMood(List<String> commitMessages) async {
    _debugLog('Making GitHub Models API request for mood analysis');
    
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_githubToken',
        'Content-Type': 'application/json',
        'X-Request-Type': 'JSON',
        'X-GitHub-Api-Version': '2022-11-28'
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a Eurovision music expert that helps match commit sentiments to appropriate Eurovision songs.'
          },
          {
            'role': 'user',
            'content': _buildMoodAnalysisPrompt(commitMessages.join("\n"))
          }
        ],
        'temperature': 0.3,
        'top_p': 1,
        'n': 1,
        'stream': false,
      }),
    );

    return _processGitHubModelsResponse(response);
  }

  Future<Map<String, dynamic>> _processGitHubModelsResponse(
      http.Response response) async {
    if (response.statusCode != 200) {
      _debugLog('ERROR: GitHub Models API failed with status ${response.statusCode}');
      _debugLog('Response body: ${response.body}');
      throw GitHubModelsException('GitHub Models API request failed',
          statusCode: response.statusCode, response: response.body);
    }

    try {
      final jsonData = json.decode(response.body);
      final content = jsonData['choices'][0]['message']['content'];

      try {
        final mood = json.decode(content);
        return {
          'mood': _normalizeMoodCategory(mood['mood']),
          'reasoning': mood['reasoning']
        };
      } catch (e) {
        return {
          'mood': _normalizeMoodCategory(content.trim()),
          'reasoning': 'Detected from commit analysis'
        };
      }
    } on FormatException {
      throw GitHubModelsException('Failed to parse API response');
    }
  }

  Future<String> _generatePlaylistWithRetry(List<String> commitMessages) async {
    _debugLog('🎵 EUROVISION: Making playlist generation request');
    
    int retries = 0;
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);
    
    while (true) {
      try {
        final playlistResponse = await http.post(
          Uri.parse(_endpoint),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_githubToken',
            'Content-Type': 'application/json',
            'X-Request-Type': 'JSON',
            'X-GitHub-Api-Version': '2022-11-28'
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are an AI assistant that creates Eurovision playlists based on developer coding moods.'
              },
              {
                'role': 'user',
                'content': _buildPlaylistGenerationPrompt(commitMessages.join("\n"))
              }
            ],
            'temperature': 0.7,
            'max_tokens': 1000,
            'n': 1,
            'stream': false,
          }),
        ).timeout(const Duration(seconds: 30));
        
        if (playlistResponse.statusCode == 200) {
          _debugLog('🎵 EUROVISION: ✅ API call successful!');
          return _extractPlaylistTextFromResponse(playlistResponse);
        }
        
        if (playlistResponse.statusCode == 429) {
          if (retries >= maxRetries) {
            throw Exception('Rate limit exceeded after $maxRetries retries');
          }
          final delay = baseDelay * pow(2, retries);
          _debugLog('Rate limited, waiting ${delay.inSeconds}s before retry ${retries + 1}/$maxRetries');
          await Future.delayed(delay);
          retries++;
          continue;
        }
        
        throw Exception('Failed to generate playlist: ${playlistResponse.statusCode}');
      } catch (e) {
        if (retries >= maxRetries) {
          throw Exception('Failed to generate playlist after $maxRetries attempts: $e');
        }
        final delay = baseDelay * pow(2, retries);
        _debugLog('Request failed, retrying in ${delay.inSeconds}s (attempt ${retries + 1}/$maxRetries)');
        await Future.delayed(delay);
        retries++;
      }
    }
  }

  String _extractPlaylistTextFromResponse(http.Response response) {
    _debugLog('Extracting playlist from response');
    try {
      final playlistData = json.decode(response.body.trim());
      return playlistData['choices'][0]['message']['content'].toString().trim();
    } catch (e) {
      throw Exception('Failed to parse playlist response: $e');
    }
  }

  List<EurovisionSong> _parsePlaylistFromText(String text) {
    _debugLog('Parsing playlist text');

    try {
      String cleanText = text.trim();
      
      if (cleanText.startsWith('\uFEFF')) {
        cleanText = cleanText.substring(1).trim();
      }
      
      if (cleanText.contains('```json')) {
        final startIndex = cleanText.indexOf('```json') + 7;
        final endIndex = cleanText.lastIndexOf('```');
        if (endIndex > startIndex) {
          cleanText = cleanText.substring(startIndex, endIndex).trim();
        }
      } else if (cleanText.contains('```')) {
        final startIndex = cleanText.indexOf('```') + 3;
        final endIndex = cleanText.lastIndexOf('```');
        if (endIndex > startIndex) {
          cleanText = cleanText.substring(startIndex, endIndex).trim();
        }
      }
      
      while (cleanText.isNotEmpty && !cleanText.startsWith('[')) {
        cleanText = cleanText.substring(1);
      }
      
      int lastBracketIndex = cleanText.lastIndexOf(']');
      if (lastBracketIndex > 0) {
        cleanText = cleanText.substring(0, lastBracketIndex + 1);
      }
      
      cleanText = cleanText
        .replaceAll('\u200B', '')
        .replaceAll('\u200C', '')
        .replaceAll('\u200D', '')
        .replaceAll(',]', ']');
      
      if (cleanText.startsWith('[') && cleanText.endsWith(']')) {
        List<dynamic> jsonList = jsonDecode(cleanText);
        final songs = jsonList.map((json) {
          return EurovisionSong.fromJson(json as Map<String, dynamic>);
        }).toList();

        if (songs.length < 5) {
          _debugLog('Not enough songs (${songs.length}), adding fallback songs');
          songs.addAll(_getFallbackSongs().take(5 - songs.length));
        }

        return songs;
      }
      
      _debugLog('Invalid playlist format, using fallback songs');
      return _getFallbackSongs();
    } catch (e) {
      _debugLog('ERROR: Failed to parse playlist: $e');
      return _getFallbackSongs();
    }
  }



  Map<String, dynamic> _buildPlaylistResult(
    List<Map<String, dynamic>> commits,
    String mood,
    Map<String, dynamic> moodData,
    List<Map<String, dynamic>> playlist,
  ) {
    return {
      'mood': mood,
      'fullAnalysis': moodData['reasoning'],
      'songs': playlist,
      'generatedAt': DateTime.now().toIso8601String(),
      'stats': {
        'commitCount': commits.length,
        'earliestCommit': _getEarliestDate(commits),
        'latestCommit': _getLatestDate(commits),
        'totalSongs': playlist.length,
      }
    };
  }

  Map<String, dynamic> _buildFallbackPlaylistResult(List<Map<String, dynamic>> commits) {
    final List<EurovisionSong> fallbackSongs = _getFallbackSongs();
    
    return {
      'mood': 'productive',
      'fullAnalysis': 'Fallback analysis due to API error',
      'songs': fallbackSongs.map((song) => song.toJson()).toList(),
      'generatedAt': DateTime.now().toIso8601String(),
      'stats': {
        'commitCount': commits.length,
        'earliestCommit': commits.isNotEmpty ? _getEarliestDate(commits) : DateTime.now().toIso8601String(),
        'latestCommit': commits.isNotEmpty ? _getLatestDate(commits) : DateTime.now().toIso8601String(),
        'playableSongs': fallbackSongs.where((s) => s.isPlayable).length,
        'totalSongs': fallbackSongs.length,
      },
      'playableLinks': {
        'enabled': true,
        'fallbacksAvailable': fallbackSongs.any((s) => s.isPlayable),
      }
    };
  }

  String _buildMoodAnalysisPrompt(String commitText) => '''
    Analyze the following commit message and categorize its mood:
    "$commitText"

    Choose the most appropriate category from:
    - Productive: Like "Euphoria" (Sweden 2012) - energetic, accomplishment
    - Intense: Like "Rise Like a Phoenix" (Austria 2014) - powerful, determined
    - Confident: Like "Heroes" (Sweden 2015) - victorious, milestone achievements
    - Creative: Like "Shum" (Ukraine 2021) - innovative, experimental
    - Reflective: Like "Arcade" (Netherlands 2019) - thoughtful, introspective

    Return format:
    {
      "mood": "category",
      "reasoning": "brief explanation"
    }

    Consider technical context and emotional tone.
  ''';

  String _buildPlaylistGenerationPrompt(String commitText) => '''
    Create a playlist of EXACTLY 5 Eurovision songs based on these commit messages:
    
    $commitText
    
    IMPORTANT: Return ONLY a JSON array with exactly 5 songs.
    NO text before or after the array. Format:

    [
      {
        "title": "SONG_TITLE",
        "artist": "ARTIST_NAME", 
        "country": "COUNTRY_NAME",
        "year": YEAR_NUMBER,
        "reasoning": "Why this song matches the coding mood"
      },
      ... exactly 4 more songs ...
    ]

    Song Selection Rules:
    1. All songs must be actual Eurovision entries (1956-2024)
    2. Mix different decades and countries
    3. Match the detected mood from commit messages
    4. Use accurate historical data
    5. Must return exactly 5 songs
  ''';

  List<EurovisionSong> _getFallbackSongs() => [
        EurovisionSong(
          title: 'Waterloo',
          artist: 'ABBA',
          country: 'Sweden',
          year: 1974,
          reasoning: 'The most iconic Eurovision winner',
        ),
        EurovisionSong(
          title: 'Euphoria',
          artist: 'Loreen',
          country: 'Sweden',
          year: 2012,
          reasoning: 'Modern Eurovision classic',
        ),
        EurovisionSong(
          title: 'Rise Like a Phoenix',
          artist: 'Conchita Wurst',
          country: 'Austria',
          year: 2014,
          reasoning: 'Powerful Eurovision anthem',
        ),
        EurovisionSong(
          title: 'Heroes',
          artist: 'Måns Zelmerlöw',
          country: 'Sweden',
          year: 2015,
          reasoning: 'Determined coding energy',
          spotifyUrl: 'https://open.spotify.com/track/1eQ8Lz52BJDLhGNqQ8CCxY',
          previewUrl: 'https://p.scdn.co/mp3-preview/f4ebc94b8e67c00c1bbf2332c8ca06ea9dd1359f',
        ),
        EurovisionSong(
          title: 'Fuego',
          artist: 'Eleni Foureira',
          country: 'Cyprus',
          year: 2018,
          reasoning: 'High-energy productivity vibes',
          spotifyUrl: 'https://open.spotify.com/track/4cxvludVmQxryrnx1m9FBJ',
          previewUrl: 'https://p.scdn.co/mp3-preview/2741de3c852e8628c6f193f4b879fb41a2a54647',
        ),
      ];

  String _normalizeMoodCategory(String rawMood) {
    final validCategories = {
      'productive': 'Productive',
      'intense': 'Intense',
      'confident': 'Confident',
      'creative': 'Creative',
      'reflective': 'Reflective'
    };

    final cleaned = rawMood.toLowerCase().trim();
    return validCategories[cleaned] ?? 'Productive';
  }
}

class GitHubModelsException implements Exception {
  final String message;
  final int? statusCode;
  final String? response;

  GitHubModelsException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'GitHubModelsException: $message (Status: $statusCode)';
}