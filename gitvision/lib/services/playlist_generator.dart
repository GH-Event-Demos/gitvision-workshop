import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/eurovision_song.dart';
import 'spotify_service.dart';

class PlaylistGenerator {
  final String _githubToken;
  final SpotifyService? spotifyService;
  final String _endpoint;
  final String _model;
  
  PlaylistGenerator({
    required String githubToken,
    required this.spotifyService,
    String endpoint = "https://models.github.ai/inference/chat/completions",
    String model = "gpt-4o-mini",
  })  : _githubToken = githubToken,
        _endpoint = endpoint,
        _model = model;

  Future<Map<String, dynamic>> generatePlayablePlaylist(
      List<Map<String, dynamic>> commits) async {
    try {
      final commitMessages = _extractCommitMessages(commits);
      final moodData = await _analyzeMood(commitMessages);
      final mood = moodData['mood'];

      final playlistText = await _generatePlaylistWithRetry(commitMessages);
      final List<EurovisionSong> playlist = _parsePlaylistFromText(playlistText);
      
      final playlistJson = playlist.map((song) => song.toJson()).toList();
      
      return {
        'mood': mood,
        'fullAnalysis': moodData['reasoning'],
        'songs': playlistJson,
        'generatedAt': DateTime.now().toIso8601String(),
        'stats': {
          'commitCount': commits.length,
          'earliestCommit': _getEarliestDate(commits),
          'latestCommit': _getLatestDate(commits),
          'totalSongs': playlistJson.length,
        }
      };
    } catch (e) {
      return _buildFallbackPlaylistResult(commits);
    }
  }

  List<String> _extractCommitMessages(List<Map<String, dynamic>> commits) {
    return commits.map((c) => c['message'] as String).toList();
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
      throw Exception('GitHub Models API request failed');
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
    } catch (e) {
      throw Exception('Failed to parse API response');
    }
  }

  Future<String> _generatePlaylistWithRetry(List<String> commitMessages) async {
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
    );
    
    if (response.statusCode == 200) {
      return _extractPlaylistTextFromResponse(response);
    } else {
      throw Exception('Failed to generate playlist');
    }
  }

  String _extractPlaylistTextFromResponse(http.Response response) {
    try {
      final playlistData = json.decode(response.body.trim());
      return playlistData['choices'][0]['message']['content'].toString().trim();
    } catch (e) {
      throw Exception('Failed to parse playlist response');
    }
  }

  List<EurovisionSong> _parsePlaylistFromText(String text) {
    try {
      String cleanText = text.trim();
      
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
      
      if (cleanText.startsWith('[') && cleanText.endsWith(']')) {
        List<dynamic> jsonList = jsonDecode(cleanText);
        final songs = jsonList.map((json) {
          return EurovisionSong.fromJson(json as Map<String, dynamic>);
        }).toList();

        if (songs.length < 5) {
          songs.addAll(_getFallbackSongs().take(5 - songs.length));
        }

        return songs;
      }
      
      return _getFallbackSongs();
    } catch (e) {
      return _getFallbackSongs();
    }
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
        'totalSongs': fallbackSongs.length,
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
        ),
        EurovisionSong(
          title: 'Fuego',
          artist: 'Eleni Foureira',
          country: 'Cyprus',
          year: 2018,
          reasoning: 'High-energy productivity vibes',
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

  Future<void> _initAudioPlayer() async {
    // Configure audio player
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    // Don't initialize with empty source - wait for actual playback

    // Set up player event listeners with proper subscription storage
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      _debugLog('AudioPlayer state changed to: $state');
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      _debugLog('AudioPlayer playback completed');
    });

    // Set default playback configurations
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.setPlaybackRate(1.0);
  }

  /// Audio playback methods
  Future<void> playSong(Map<String, dynamic> song) async {
    _debugLog(
        'Attempting to play song: ${song['title']} by ${song['artist']}');

    final String? previewUrl = song['preview_url'] ?? song['previewUrl'];
    final String? webPlayerUrl = song['webPlayerUrl'] ?? song['spotifyUrl'];

    if (previewUrl != null && previewUrl.isNotEmpty) {
      _debugLog('Playing preview URL: $previewUrl');
      await _audioPlayer.stop();
      await _audioPlayer.setSourceUrl(previewUrl);
      await _audioPlayer.resume();
    } else if (webPlayerUrl != null && webPlayerUrl.isNotEmpty) {
      _debugLog('Opening web player URL: $webPlayerUrl');
      final url = Uri.parse(webPlayerUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Spotify URL');
      }
    } else {
      _debugLog('ERROR: No playable URLs found for song: ${song['title']}');
      throw Exception('No playable URLs found for this song');
    }
  }

  Future<void> pausePlayback() async {
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> searchAndPlaySong(String query) async {
    final results = await spotifyService.searchTracks(query);
    if (results.isEmpty) {
      throw Exception('No search results found');
    }

    final firstTrack = results.first;
    if (firstTrack['preview_url'] != null) {
      await playSong(firstTrack);
    } else if (firstTrack['webPlayerUrl'] != null) {
      final url = Uri.parse(firstTrack['webPlayerUrl']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Spotify URL');
      }
    } else {
      throw Exception('No playable URLs found for this song');
    }
  }

  Future<void> dispose() async {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    await _audioPlayer.dispose();
  }

  Future<Map<String, dynamic>> _processGitHubModelsResponse(
      http.Response response) async {
    if (response.statusCode != 200) {
      _debugLog('ERROR: GitHub Models API failed with status ${response.statusCode}');
      print('Response body: ${response.body}');
      throw GitHubModelsException('GitHub Models API request failed',
          statusCode: response.statusCode, response: response.body);
    }

    try {
      final jsonData = json.decode(response.body);
      final content = jsonData['choices'][0]['message']['content'];

      // Try to parse the response content as JSON
      try {
        final mood = json.decode(content);
        return {
          'mood': _normalizeMoodCategory(mood['mood']),
          'reasoning': mood['reasoning']
        };
      } catch (e) {
        // If JSON parsing fails, use the normalized category from the text
        return {
          'mood': _normalizeMoodCategory(content.trim()),
          'reasoning': 'Detected from commit analysis'
        };
      }
    } on FormatException {
      throw GitHubModelsException('Failed to parse API response');
    }
  }

  /// Parse playlist text into structured data
  List<EurovisionSong> _parsePlaylistFromText(String text) {
    _debugLog('Parsing playlist text: ${text.substring(0, min(100, text.length))}...');

    try {
      // Clean the text and try to parse as JSON first
      String cleanText = text.trim();
      
      // Remove BOM if present
      if (cleanText.startsWith('\uFEFF')) {
        cleanText = cleanText.substring(1).trim();
        _debugLog('Removed BOM character from playlist text');
      }
      
      // Remove markdown formatting if present
      if (cleanText.contains('```json')) {
        final startIndex = cleanText.indexOf('```json') + 7;
        final endIndex = cleanText.lastIndexOf('```');
        if (endIndex > startIndex) {
          cleanText = cleanText.substring(startIndex, endIndex).trim();
          _debugLog('Extracted JSON from code block');
        }
      } else if (cleanText.contains('```')) {
        final startIndex = cleanText.indexOf('```') + 3;
        final endIndex = cleanText.lastIndexOf('```');
        if (endIndex > startIndex) {
          cleanText = cleanText.substring(startIndex, endIndex).trim();
          _debugLog('Extracted from generic code block');
        }
      }
      
      // Remove any leading/trailing non-JSON characters
      while (cleanText.isNotEmpty && !cleanText.startsWith('[')) {
        cleanText = cleanText.substring(1);
      }
      
      int lastBracketIndex = cleanText.lastIndexOf(']');
      if (lastBracketIndex > 0) {
        cleanText = cleanText.substring(0, lastBracketIndex + 1);
      }
      
      // Fix common JSON issues
      if (cleanText.contains(',]')) {
        cleanText = cleanText.replaceAll(',]', ']');
        _debugLog('Fixed trailing comma');
      }
      
      // Remove special characters that might interfere
      cleanText = cleanText.replaceAll('\u200B', ''); // Zero-width space
      cleanText = cleanText.replaceAll('\u200C', ''); // Zero-width non-joiner
      cleanText = cleanText.replaceAll('\u200D', ''); // Zero-width joiner
      
      _debugLog('Cleaned text for parsing: ${cleanText.substring(0, min(100, cleanText.length))}...');
      
      if (cleanText.startsWith('[') && cleanText.endsWith(']')) {
        List<dynamic> jsonList;
        try {
          jsonList = jsonDecode(cleanText);
          _debugLog('Successfully parsed JSON list with ${jsonList.length} songs');
        } catch (jsonError) {
          _debugLog('ERROR: JSON parsing failed: $jsonError');
          _debugLog('ERROR: Problematic JSON: $cleanText');
          // Return fallback songs instead of crashing
          return _getFallbackSongs();
        }

        // Convert JSON objects to EurovisionSongs
        final songs = jsonList.map((json) {
          return EurovisionSong.fromJson(json as Map<String, dynamic>);
        }).toList();

        if (songs.length < 5) {
          print(
              'DEBUG: Not enough songs in response (${songs.length}), adding fallback songs');
          songs.addAll(_getFallbackSongs().take(5 - songs.length));
        }

        _debugLog('Returning ${songs.length} songs');
        return songs;
      }

      // If not JSON, try parsing as text blocks
      _debugLog('Attempting to parse as text blocks');
      final blocks = text.split('\n\n');
      final songs = <EurovisionSong>[];

      for (final block in blocks) {
        try {
          final title = _extractValue(block, 'title');
          if (title == null) continue;

          songs.add(EurovisionSong(
              title: title,
              artist: _extractValue(block, 'artist') ?? 'Eurovision Artist',
              country: _extractValue(block, 'country') ?? 'Europe',
              year: int.tryParse(_extractValue(block, 'year') ?? '') ?? 2024,
              reasoning: _extractValue(block, 'reasoning') ??
                  'Matches the development mood'));
        } catch (e) {
          print('Error parsing song block: $e');
        }
      }

      // Ensure we have exactly 5 songs
      if (songs.isEmpty) {
        _debugLog('No songs parsed, using fallback songs');
        return _getFallbackSongs();
      } else if (songs.length < 5) {
        print(
            'DEBUG: Not enough songs (${songs.length}), adding fallback songs');
        songs.addAll(_getFallbackSongs().take(5 - songs.length));
      }

      _debugLog('Returning ${songs.length} songs');
      return songs;
    } catch (e) {
      _debugLog('ERROR: Failed to parse playlist text: $e');
      _debugLog('Using fallback songs due to parsing error');
      return _getFallbackSongs();
    }
  }

  /// Extract value from text block
  String? _extractValue(String text, String key) {
    final regex = RegExp('$key:?\\s*([^\\n]+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim();
  }

  /// Get fallback songs when API fails
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
        ),
        EurovisionSong(
          title: 'Fuego',
          artist: 'Eleni Foureira',
          country: 'Cyprus',
          year: 2018,
          reasoning: 'High-energy productivity vibes',
        ),
      ];

  /// Get earliest commit date
  String _getEarliestDate(List<Map<String, dynamic>> commits) {
    final dates =
        commits.map((c) => DateTime.parse(c['date'] as String)).toList();
    final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    _debugLog('Earliest commit date: $earliest');
    return earliest.toIso8601String();
  }

  /// Get latest commit date
  String _getLatestDate(List<Map<String, dynamic>> commits) {
    final dates =
        commits.map((c) => DateTime.parse(c['date'] as String)).toList();
    final latest = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    _debugLog('Latest commit date: $latest');
    return latest.toIso8601String();
  }

  /// Extract commit messages from commits data
  List<String> _extractCommitMessages(List<Map<String, dynamic>> commits) {
    final messages = commits.map((c) => c['message'] as String).toList();
    _debugLog('Extracted ${messages.length} commit messages for analysis');
    return messages;
  }

  /// Analyze mood from commit messages
  Future<Map<String, dynamic>> _analyzeMood(List<String> commitMessages) async {
    _debugLog('Making GitHub Models API request to $_endpoint');
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

    return await _processGitHubModelsResponse(response);
  }

  /// Generate playlist with retry mechanism
  Future<String> _generatePlaylistWithRetry(List<String> commitMessages) async {
    _debugLog('🎵 EUROVISION: Making playlist generation request to $_endpoint');
    _debugLog('🎵 EUROVISION: Using model: $_model');
    _debugLog('🎵 EUROVISION: Processing ${commitMessages.length} commit messages');
    
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
          _debugLog('🎵 EUROVISION: ✅ GitHub Models API call successful!');
          _debugLog('🎵 EUROVISION: Response received, extracting Eurovision playlist...');
          return _extractPlaylistTextFromResponse(playlistResponse);
        }
        
        // Handle rate limiting and retries
        if (playlistResponse.statusCode == 429) {
          if (retries >= maxRetries) {
            _debugLog('ERROR: Rate limit exceeded after $maxRetries retries');
            throw Exception('Rate limit exceeded after $maxRetries retries');
          }
          
          final delay = baseDelay * pow(2, retries);
          _debugLog('Rate limited, waiting ${delay.inSeconds}s before retry ${retries + 1}/$maxRetries');
          await Future.delayed(delay);
          retries++;
          continue;
        }
        
        // For other errors
        _debugLog('🎵 EUROVISION: ❌ GitHub Models API request failed with status ${playlistResponse.statusCode}');
        _debugLog('🎵 EUROVISION: Error details: ${playlistResponse.reasonPhrase}');
        _debugLog('🎵 EUROVISION: Response body: ${playlistResponse.body}');
        if (retries >= maxRetries) {
          throw Exception('Failed to generate playlist after $maxRetries attempts: API returned ${playlistResponse.statusCode}');
        }
        
        final delay = baseDelay * pow(2, retries);
        _debugLog('Request failed, retrying in ${delay.inSeconds}s (attempt ${retries + 1}/$maxRetries)');
        await Future.delayed(delay);
        retries++;
        
      } on TimeoutException {
        if (retries >= maxRetries) {
          throw Exception('Request timeout after $maxRetries retries');
        }
        
        final delay = baseDelay * pow(2, retries);
        _debugLog('Request timeout, retrying in ${delay.inSeconds}s (attempt ${retries + 1}/$maxRetries)');
        await Future.delayed(delay);
        retries++;
        continue;
      }
    }
  }

  /// Extract playlist text from API response
  String _extractPlaylistTextFromResponse(http.Response response) {
    _debugLog('Raw playlist response body: ${response.body.substring(0, min(200, response.body.length))}...');
    
    try {
      // Clean the response body
      String cleanPlaylistBody = response.body.trim();
      if (cleanPlaylistBody.startsWith('\uFEFF')) {
        cleanPlaylistBody = cleanPlaylistBody.substring(1);
        _debugLog('Removed BOM character from playlist response');
      }
      
      final playlistData = json.decode(cleanPlaylistBody);
      
      if (!playlistData.containsKey('choices') || 
          playlistData['choices'] == null || 
          playlistData['choices'].isEmpty) {
        _debugLog('ERROR: Playlist response missing choices field');
        throw Exception('Invalid playlist API response format: missing choices');
      }
      
      final dynamic firstChoice = playlistData['choices'][0];
      if (!firstChoice.containsKey('message') || 
          firstChoice['message'] == null || 
          !firstChoice['message'].containsKey('content')) {
        _debugLog('ERROR: Playlist response missing message.content');
        throw Exception('Invalid playlist API response format: missing message content');
      }
      
      final playlistText = firstChoice['message']['content'].toString().trim();
      _debugLog('Generated raw playlist text: ${playlistText.substring(0, min(100, playlistText.length))}...');
      return playlistText;
    } catch (jsonError) {
      _debugLog('ERROR: Failed to parse playlist response JSON: $jsonError');
      throw Exception('Failed to parse playlist response: $jsonError');
    }
  }

  /// Generate a playable playlist from commits
  Future<Map<String, dynamic>> generatePlayablePlaylist(
      List<Map<String, dynamic>> commits) async {
    _debugLog('🎵 EUROVISION: 🚀 Starting Eurovision playlist generation from ${commits.length} commits');
    _debugLog('🎵 EUROVISION: Will call GitHub Models API at: $_endpoint');
    _debugLog('🎵 EUROVISION: GitHub token length: ${_githubToken.length} characters');
    _debugLog('🎵 EUROVISION: Using model: $_model');
    try {
      // Extract commit messages and analyze mood
      final commitMessages = _extractCommitMessages(commits);
      _debugLog('🎵 EUROVISION: Extracted ${commitMessages.length} commit messages');
      _debugLog('🎵 EUROVISION: Sample commit: ${commitMessages.isNotEmpty ? commitMessages.first : "No commits"}');
      
      final moodData = await _analyzeMood(commitMessages);
      final mood = moodData['mood'];
      _debugLog('Mood analysis result: $mood (${moodData['reasoning']})');

      // Generate playlist based on mood
      final playlistText = await _generatePlaylistWithRetry(commitMessages);

      // Parse and enhance playlist
      final List<EurovisionSong> playlist = _parsePlaylistFromText(playlistText);
      _debugLog('Parsed ${playlist.length} songs from response');
      
      final List<Map<String, dynamic>> enhancedPlaylist =
          await _enhancePlaylist(playlist.map((song) => song.toJson()).toList());
      _debugLog('Enhanced playlist with Spotify data');

      return _buildPlaylistResult(commits, mood, moodData, enhancedPlaylist);
    } catch (e) {
      _debugLog('ERROR: Failed to generate playlist: $e');
      return _buildFallbackPlaylistResult(commits);
    }
  }

  /// Build the final playlist result
  Map<String, dynamic> _buildPlaylistResult(
    List<Map<String, dynamic>> commits,
    String mood,
    Map<String, dynamic> moodData,
    List<Map<String, dynamic>> enhancedPlaylist,
  ) {
    return {
      'mood': mood,
      'fullAnalysis': moodData['reasoning'],
      'songs': enhancedPlaylist,
      'generatedAt': DateTime.now().toIso8601String(),
      'stats': {
        'commitCount': commits.length,
        'earliestCommit': _getEarliestDate(commits),
        'latestCommit': _getLatestDate(commits),
        'playableSongs': enhancedPlaylist.where((s) => s['isPlayable'] as bool? ?? false).length,
        'totalSongs': enhancedPlaylist.length,
      },
      'playableLinks': {
        'enabled': true,
        'fallbacksAvailable': enhancedPlaylist.any((s) => s['isPlayable'] as bool? ?? false),
      }
    };
  }

  /// Build fallback playlist result when generation fails
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

  String _buildPlaylistPrompt(String mood) => '''
    Create a playlist of EXACTLY 5 Eurovision songs that match a $mood coding mood.

    IMPORTANT: Return ONLY a JSON array with exactly 5 songs.
    NO text before or after the array. Format:

    [
      {
        "title": "SONG_TITLE",
        "artist": "ARTIST_NAME",
        "country": "COUNTRY_NAME",
        "year": YEAR_NUMBER,
        "reasoning": "Why this song matches $mood mood"
      },
      ... exactly 4 more songs ...
    ]

    Song Selection Rules:
    1. All songs must be actual Eurovision entries (1956-2024)
    2. Mix different decades and countries
    3. For $mood mood, consider:
       - Productive → Energetic anthems (Euphoria, Fuego)
       - Intense → Power songs (Rise Like a Phoenix)
       - Creative → Unique entries (Shum, Dancing Lasha Tumbai)
       - Confident → Winners (Heroes, Toy)
       - Reflective → Emotional songs (Arcade, Soldi)
    4. Use accurate historical data
    5. Must return exactly 5 songs
  ''';

  Future<List<Map<String, dynamic>>> _enhancePlaylist(
      List<Map<String, dynamic>> playlist) async {
    _debugLog('Enhancing playlist with Spotify data');

    try {
      // Build search variations for each song to maximize chances of finding preview URLs
      final queries = playlist.map((song) {
        return [
          '${song['title']} ${song['artist']}', // Exact match
          '${song['title']} ${song['artist']} eurovision', // With eurovision
          '${song['title']} eurovision ${song['year']}', // With year
          song['title'], // Just the title as fallback
        ];
      }).toList();
      _debugLog('Searching for ${queries.length} songs on Spotify with multiple queries per song');

      final spotifyTracks = await Future.wait(
        queries.map((songQueries) async {
          // Try each query variation until we find a result with preview URL
          for (final query in songQueries) {
            final searchResults = await spotifyService.searchTracks([query]);
            if (searchResults.isEmpty) continue;

            // Look for a result with preview URL
            final trackWithPreview = searchResults.firstWhere(
              (track) => track['preview_url'] != null && track['preview_url'].isNotEmpty,
              orElse: () => searchResults.first,
            );
            
            if (trackWithPreview['preview_url'] != null) {
              _debugLog('Found preview URL for query: $query');
              return trackWithPreview;
            }
          }
          
          // If no preview URL found with any query, return first result of first query
          final fallbackResults = await spotifyService.searchTracks([songQueries.first]);
          return fallbackResults.isEmpty ? null : fallbackResults.first;
        }),
      );
      _debugLog('Found ${spotifyTracks.where((t) => t != null).length} Spotify tracks');

      // Create a map of indices to Spotify tracks for easier lookup
      final trackMap = Map.fromIterables(
        List.generate(playlist.length, (i) => i),
        spotifyTracks,
      );

      // Combine Eurovision and Spotify data, preserving all original songs
      return playlist.asMap().map((index, eurovisionData) {
        final spotifyData = trackMap[index];

        _debugLog('Processing song ${eurovisionData['title']} - ${eurovisionData['artist']}');
        _debugLog('Found Spotify match: ${spotifyData != null}');

        // Always preserve the original Eurovision data and prioritize working preview URLs
        final originalPreviewUrl = eurovisionData['previewUrl'] as String?;
        final spotifyPreviewUrl = spotifyData?['preview_url'] as String?;
        
        // Extract album image URL with proper fallback chain
        final spotifyImages = spotifyData?['album']?['images'] as List?;
        final albumImageUrl = spotifyImages?.isNotEmpty == true
            ? spotifyImages![0]['url']
            : spotifyData?['imageUrl'] ??
              eurovisionData['imageUrl'];

        // Use the working preview URL - prefer original if it exists, otherwise use Spotify
        final bestPreviewUrl =
            (originalPreviewUrl != null && originalPreviewUrl.isNotEmpty)
                ? originalPreviewUrl
                : spotifyPreviewUrl;

        final enhancedSong = {
          ...eurovisionData, // Keep all original Eurovision data
          'preview_url': bestPreviewUrl,
          'webPlayerUrl': spotifyData?['webPlayerUrl'] ?? eurovisionData['spotifyUrl'],
          'imageUrl': albumImageUrl,
          'isPlayable': bestPreviewUrl != null && bestPreviewUrl.isNotEmpty,
          'spotifyId': spotifyData?['id'],
          'duration': spotifyData?['duration_ms'] ?? 180000,
          'album': spotifyData?['album'] ?? {'name': eurovisionData['title']},
        };

        _debugLog('Enhanced song ${enhancedSong['title']}: preview_url=${enhancedSong['preview_url']}, isPlayable=${enhancedSong['isPlayable']}, imageUrl=${enhancedSong['imageUrl']}');
        return MapEntry(index, enhancedSong);
      }).values.toList();
    } catch (e) {
      print('Error enhancing playlist: $e');
      // Return original songs with minimal enhancement if Spotify fails
      return playlist.map((song) => {
        ...song,
        'preview_url': song['previewUrl'], // Use existing preview URL if available
        'webPlayerUrl': song['spotifyUrl'], // Use existing Spotify URL if available
        'imageUrl': song['album']?['images']?.firstOrNull?['url'] ?? 
                   song['imageUrl'] ?? 
                   'https://via.placeholder.com/300x300.png?text=Eurovision',
        'isPlayable': song['previewUrl'] != null && song['previewUrl'].isNotEmpty,
        'duration': song['duration_ms'] ?? 180000,
        'album': song['album'] ?? {'name': song['title']},
      }).toList();
    }
  }

  String _normalizeMoodCategory(String rawMood) {
    final validCategories = {
      'productive': 'Productive',
      'intense': 'Intense',
      'confident': 'Confident',
      'creative': 'Creative',
      'reflective': 'Reflective'
    };

    final cleaned = rawMood.toLowerCase().trim();
    return validCategories[cleaned] ??
        'Productive'; // Default to Productive if no match
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

class AIPlaylistService {
  final String _githubToken;
  final String _endpoint = 'https://models.github.ai/inference/chat/completions';
  final String _model = ApiConfig.aiModel;

  AIPlaylistService({required String githubToken}) : _githubToken = githubToken;

  // Debug utility - only prints in debug mode
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[AIPlaylistService] $message');
    }
  }

  Future<List<EurovisionSong>> generateEurovisionPlaylist(
      SentimentResult sentiment) async {
    _debugLog('Generating Eurovision playlist for mood: ${sentiment.mood}');
    final prompt = _buildEurovisionPrompt(sentiment);

    try {
      final response = await _callGitHubModelsAPI(prompt);
      final songs = _parseAIResponse(response);
      _debugLog('Generated ${songs.length} songs');
      return songs;
    } catch (e) {
      _debugLog('ERROR: AI Playlist Service failed: $e');
      return _getFallbackEurovisionSongs(sentiment.mood.name);
    }
  }

  String _buildEurovisionPrompt(SentimentResult sentiment) {
    return '''
    Create a Eurovision playlist of EXACTLY 5 songs that match a ${sentiment.mood} coding mood.
    Confidence: ${sentiment.confidence}
    
    CULTURAL CONTEXT: Eurovision is Europe's beloved song contest celebrating diversity, 
    creativity, and unity through music. Each song represents a country's cultural 
    identity and artistic expression. Consider both musical energy and cultural significance.
    
    IMPORTANT: Return ONLY a JSON array with exactly 5 songs.
    NO text before or after the array. Format:

    [
      {
        "title": "SONG_TITLE",
        "artist": "ARTIST_NAME",
        "country": "COUNTRY_NAME",
        "year": YEAR_NUMBER,
        "reasoning": "Why this song matches ${sentiment.mood} mood and its cultural significance"
      },
      ... exactly 4 more songs ...
    ]

    Song Selection Rules:
    1. All songs must be actual Eurovision entries (1956-2025)
    2. Mix different decades and countries for cultural diversity
    3. For ${sentiment.mood} mood, consider:
       - Productive → Energetic anthems (Euphoria-Sweden 2012, Fuego-Cyprus 2018)
       - Intense/Debug → Power songs (Rise Like a Phoenix-Austria 2014, 1944-Ukraine 2016)
       - Creative → Unique entries (Shum-Ukraine 2021, Dancing Lasha Tumbai-Ukraine 2007)
       - Victory → Winners (Heroes-Sweden 2015, Waterloo-Sweden 1974)
       - Reflective → Emotional songs (Arcade-Netherlands 2019, Soldi-Italy 2019)
    4. Include cultural diversity: Nordic efficiency, Eastern European passion, 
       Mediterranean warmth, British innovation, etc.
    5. Use accurate historical data and consider the song's impact on Eurovision history
    6. Must return exactly 5 songs

    Keywords from commits: ${sentiment.keywords.join(', ')}
    ''';
  }

  Future<String> _callGitHubModelsAPI(String prompt) async {
    _debugLog('Calling GitHub Models API');
    int retries = 0;
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);

    while (true) {
      try {
        final response = await http
            .post(
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
                'temperature': 0.7,
                'messages': [
                  {
                    'role': 'system',
                    'content':
                        '''You are a Eurovision music expert with deep cultural knowledge. Analyze commit messages and suggest songs that match their mood.
Always return a JSON array with EXACTLY 5 Eurovision songs. Each song must be a real Eurovision entry with:
- title: Song title
- artist: Artist name
- country: Country represented (must be valid Eurovision participant)
- year: Competition year (1956-2025)
- reasoning: Brief explanation connecting coding mood to song's cultural significance'''
                  },
                  {'role': 'user', 'content': prompt}
                ],
                'max_tokens': 1000,
                'stream': false
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['choices'] != null && result['choices'].isNotEmpty) {
            final content = result['choices'][0]['message']['content'];
            if (content != null) {
              return content;
            }
          }
          throw Exception('Invalid response format from GitHub Models API');
        } else if (response.statusCode == 429) {
          // Rate limit
          if (retries >= maxRetries) {
            throw Exception('Rate limit exceeded after $maxRetries retries');
          }
          final delay = baseDelay * pow(2, retries);
          print(
              'DEBUG: Rate limited, waiting ${delay.inSeconds}s before retry');
          await Future.delayed(delay);
          retries++;
          continue;
        } else {
          print(
              'ERROR: GitHub Models API failed with status ${response.statusCode}');
          print('Response: ${response.body}');
          throw Exception(
              'GitHub Models API request failed: ${response.statusCode}');
        }
      } on TimeoutException {
        if (retries >= maxRetries) {
          throw Exception(
              'GitHub Models API timeout after $maxRetries retries');
        }
        final delay = baseDelay * pow(2, retries);
        print(
            'DEBUG: Request timeout, waiting ${delay.inSeconds}s before retry');
        await Future.delayed(delay);
        retries++;
        continue;
      } catch (e) {
        _debugLog('ERROR: Unexpected error calling GitHub Models API: $e');
        throw Exception('GitHub Models API request failed: $e');
      }
    }
  }

  List<EurovisionSong> _parseAIResponse(String response) {
    _debugLog('Parsing AI response');
    try {
      final cleanText = response.trim();
      if (cleanText.startsWith('[') && cleanText.endsWith(']')) {
        final List<dynamic> jsonList = jsonDecode(cleanText);
        print(
            'DEBUG: Successfully parsed JSON list with ${jsonList.length} songs');

        final songs = jsonList.map((json) {
          return EurovisionSong.fromJson(json as Map<String, dynamic>);
        }).toList();

        if (songs.length < 5) {
          print(
              'DEBUG: Not enough songs in response (${songs.length}), adding fallback songs');
          songs.addAll(
              _getFallbackEurovisionSongs('productive').take(5 - songs.length));
        }

        return songs;
      } else {
        _debugLog('ERROR: Response is not a valid JSON array');
        return _getFallbackEurovisionSongs('productive');
      }
    } catch (e) {
      _debugLog('ERROR: Failed to parse AI response: $e');
      return _getFallbackEurovisionSongs('productive');
    }
  }

  // Fallback Eurovision songs for different moods
  List<EurovisionSong> _getFallbackEurovisionSongs(String mood) {
    switch (mood.toLowerCase()) {
      case 'frustrated':
      case 'debugging':
        return [
          EurovisionSong(
            title: 'Rise Like a Phoenix',
            artist: 'Conchita Wurst',
            country: 'Austria',
            year: 2014,
            reasoning: 'Rising above debugging challenges like a phoenix 🇦🇹',
            spotifyUrl: 'https://open.spotify.com/track/1nqzQEQJ5TvX5NoZBxTnaV',
            previewUrl:
                'https://p.scdn.co/mp3-preview/b2839485e2736d3ba7419ded6f7d30b2dfbdef3f',
          ),
          EurovisionSong(
            title: '1944',
            artist: 'Jamala',
            country: 'Ukraine',
            year: 2016,
            reasoning: 'Powerful emotions for tackling tough bugs 🇺🇦',
            spotifyUrl: 'https://open.spotify.com/track/79DKr9qKzKVQL9InS7KKQD',
            previewUrl:
                'https://p.scdn.co/mp3-preview/c158b2d6ca5a53dec644d74498d49c010d121c16',
          ),
          EurovisionSong(
            title: 'Hard Rock Hallelujah',
            artist: 'Lordi',
            country: 'Finland',
            year: 2006,
            reasoning:
                'Heavy metal energy to power through debugging sessions 🇫🇮',
            spotifyUrl: 'https://open.spotify.com/track/7bZl4g4EvF5gL9C2D3e6F8',
            previewUrl:
                'https://p.scdn.co/mp3-preview/f5g9c2e6d4b8a1e7c3f6a2d5e8b1f4e7c2d5e8a',
          ),
          EurovisionSong(
            title: 'Sound of Silence',
            artist: 'Dami Im',
            country: 'Australia',
            year: 2016,
            reasoning:
                'Intense focus and determination for complex debugging 🇦🇺',
            spotifyUrl:
                'https://open.spotify.com/track/2e5A7d1c8F6b9E2a5D8c1F4',
            previewUrl:
                'https://p.scdn.co/mp3-preview/c8f6b9e2a5d8c1f4e7a3d6e9c2f5a8d1e4c7f2e',
          ),
          EurovisionSong(
            title: 'Spirit in the Sky',
            artist: 'Keiino',
            country: 'Norway',
            year: 2019,
            reasoning:
                'Uplifting spirit to overcome debugging frustrations 🇳🇴',
            spotifyUrl:
                'https://open.spotify.com/track/4a7D2e5F8c1e4A7d2E5f8C1',
            previewUrl:
                'https://p.scdn.co/mp3-preview/e4a7d2e5f8c1e4a7d2e5f8c1e4a7d2e5f8c1e4a',
          ),
        ];

      case 'productive':
      case 'flow':
        return [
          EurovisionSong(
            title: 'Euphoria',
            artist: 'Loreen',
            country: 'Sweden',
            year: 2012,
            reasoning: 'The euphoria of productive coding flow 🇸🇪',
            spotifyUrl: 'https://open.spotify.com/track/3Yrp3hBg4iEcLEYgZkHVgh',
            previewUrl:
                'https://p.scdn.co/mp3-preview/cad6841f50b565a0e241917e95a4263380859384',
          ),
          EurovisionSong(
            title: 'Fuego',
            artist: 'Eleni Foureira',
            country: 'Cyprus',
            year: 2018,
            reasoning: 'High-energy productivity vibes 🇨🇾',
            spotifyUrl: 'https://open.spotify.com/track/4cxvludVmQxryrnx1m9FBJ',
            previewUrl:
                'https://p.scdn.co/mp3-preview/2741de3c852e8628c6f193f4b879fb41a2a54647',
          ),
          EurovisionSong(
            title: 'Waterloo',
            artist: 'ABBA',
            country: 'Sweden',
            year: 1974,
            reasoning: 'Legendary productivity anthem 🇸🇪',
            spotifyUrl: 'https://open.spotify.com/track/0JiY190vktuhSGN6aqJdrt',
            previewUrl:
                'https://p.scdn.co/mp3-preview/6de1df17d3eb49211d53c435e26282bb180fae81',
          ),
          EurovisionSong(
            title: 'Heroes',
            artist: 'Måns Zelmerlöw',
            country: 'Sweden',
            year: 2015,
            reasoning: 'Determined coding like a true hero 🇸🇪',
            spotifyUrl: 'https://open.spotify.com/track/1eQ8Lz52BJDLhGNqQ8CCxY',
            previewUrl:
                'https://p.scdn.co/mp3-preview/f4ebc94b8e67c00c1bbf2332c8ca06ea9dd1359f',
          ),
          EurovisionSong(
            title: 'Satellite',
            artist: 'Lena',
            country: 'Germany',
            year: 2010,
            reasoning: 'Uplifting melody for focused productivity 🇩🇪',
            spotifyUrl: 'https://open.spotify.com/track/4IVtwWBNj9NEBNR7tkXDqb',
            previewUrl:
                'https://p.scdn.co/mp3-preview/89f9c3e6d11b8b8d9c8e6a2f1b5d8e3c',
          ),
        ];

      default:
        return [
          EurovisionSong(
            title: 'Heroes',
            artist: 'Måns Zelmerlöw',
            country: 'Sweden',
            year: 2015,
            reasoning: 'Determined coding like a true hero 🇸🇪',
            spotifyUrl: 'https://open.spotify.com/track/1eQ8Lz52BJDLhGNqQ8CCxY',
            previewUrl:
                'https://p.scdn.co/mp3-preview/f4ebc94b8e67c00c1bbf2332c8ca06ea9dd1359f',
          ),
          EurovisionSong(
            title: 'Euphoria',
            artist: 'Loreen',
            country: 'Sweden',
            year: 2012,
            reasoning: 'Universal coding euphoria 🇸🇪',
            spotifyUrl: 'https://open.spotify.com/track/3Yrp3hBg4iEcLEYgZkHVgh',
            previewUrl:
                'https://p.scdn.co/mp3-preview/cad6841f50b565a0e241917e95a4263380859384',
          ),
          EurovisionSong(
            title: 'Fuego',
            artist: 'Eleni Foureira',
            country: 'Cyprus',
            year: 2018,
            reasoning: 'High energy for any coding session 🇨🇾',
            spotifyUrl: 'https://open.spotify.com/track/4cxvludVmQxryrnx1m9FBJ',
            previewUrl:
                'https://p.scdn.co/mp3-preview/2741de3c852e8628c6f193f4b879fb41a2a54647',
          ),
          EurovisionSong(
            title: 'Waterloo',
            artist: 'ABBA',
            country: 'Sweden',
            year: 1974,
            reasoning: 'Classic Eurovision energy for coding 🇸🇪',
            spotifyUrl: 'https://open.spotify.com/track/0JiY190vktuhSGN6aqJdrt',
            previewUrl:
                'https://p.scdn.co/mp3-preview/6de1df17d3eb49211d53c435e26282bb180fae81',
          ),
          EurovisionSong(
            title: 'Satellite',
            artist: 'Lena',
            country: 'Germany',
            year: 2010,
            reasoning: 'Uplifting coding companion 🇩🇪',
            spotifyUrl: 'https://open.spotify.com/track/4IVtwWBNj9NEBNR7tkXDqb',
            previewUrl:
                'https://p.scdn.co/mp3-preview/89f9c3e6d11b8b8d9c8e6a2f1b5d8e3c',
          ),
        ];
    }
  }
}
