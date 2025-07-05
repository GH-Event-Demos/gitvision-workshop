import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/eurovision_song.dart';
import '../models/sentiment_result.dart';
import '../config/api_config.dart';
import 'spotify_service.dart';

class PlaylistGenerator {
  final String _githubToken;
  final SpotifyService? spotifyService;
  final String _endpoint = ApiConfig.githubModelsEndpoint;
  final String _model = ApiConfig.aiModel;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Stream subscriptions for proper disposal
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  
  // Debug utility - only prints in debug mode
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[PlaylistGenerator] $message');
    }
  }
  
  PlaylistGenerator({
    required String githubToken,
    required this.spotifyService,
  })  : _githubToken = githubToken {
    _initAudioPlayer();
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
    print('🎵 [PlaylistGenerator] Making mood analysis API call...');
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

    print('🎵 [PlaylistGenerator] Mood analysis API response: ${response.statusCode}');
    return _processGitHubModelsResponse(response);
  }

  Future<Map<String, dynamic>> _processGitHubModelsResponse(
      http.Response response) async {
    print('🎵 [PlaylistGenerator] Processing API response: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('🎵 [PlaylistGenerator] ERROR: API request failed with ${response.statusCode}: ${response.body}');
      throw Exception('GitHub Models API request failed with ${response.statusCode}');
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

    Consider technical context and emotional tone. Focus on modern Eurovision entries (2010-2024).
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
    1. All songs must be actual Eurovision entries from 2010-2024 ONLY
    2. Mix different years and countries (all from 2010 onwards)
    3. Match the detected mood from commit messages
    4. Use accurate historical data
    5. Must return exactly 5 songs
    6. Focus on modern Eurovision entries with better streaming availability
  ''';

  List<EurovisionSong> _getFallbackSongs() => [
        EurovisionSong(
          title: 'Euphoria',
          artist: 'Loreen',
          country: 'Sweden',
          year: 2012,
          reasoning: 'Modern Eurovision classic with great streaming availability',
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
        EurovisionSong(
          title: 'Arcade',
          artist: 'Duncan Laurence',
          country: 'Netherlands',
          year: 2019,
          reasoning: 'Reflective and introspective coding mood',
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
  
  Future<void> _initAudioPlayer() async {
    // Configure audio player
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    
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
    _debugLog('Attempting to play song: ${song['title']} by ${song['artist']}');

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

  Future<void> resumePlayback() async {
    await _audioPlayer.resume();
  }

  Future<void> dispose() async {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    await _audioPlayer.dispose();
  }
  
  /// Generate a playable playlist with Spotify data
  Future<Map<String, dynamic>> generatePlayablePlaylist(List<Map<String, dynamic>> commitData) async {
    try {
      print('🎵 [PlaylistGenerator] Starting playlist generation with ${commitData.length} commits');
      final commitMessages = _extractCommitMessages(commitData);
      print('🎵 [PlaylistGenerator] Extracted ${commitMessages.length} commit messages');
      
      // Analyze mood
      print('🎵 [PlaylistGenerator] Analyzing mood...');
      final moodResult = await _analyzeMood(commitMessages);
      print('🎵 [PlaylistGenerator] Mood analyzed: ${moodResult['mood']}');
      
      // Generate playlist
      print('🎵 [PlaylistGenerator] Generating Eurovision playlist...');
      final playlistText = await _generatePlaylistWithRetry(commitMessages);
      print('🎵 [PlaylistGenerator] Parsing playlist text...');
      final songs = _parsePlaylistFromText(playlistText);
      print('🎵 [PlaylistGenerator] Parsed ${songs.length} songs');
      
      // Convert to maps and enhance with Spotify data
      final songMaps = songs.map((song) => song.toJson()).toList();
      print('🎵 [PlaylistGenerator] Enhancing with Spotify data...');
      final enhancedSongs = await _enhancePlaylist(songMaps);
      print('🎵 [PlaylistGenerator] Enhanced ${enhancedSongs.length} songs with Spotify data');
      
      return {
        'mood': moodResult['mood'],
        'fullAnalysis': moodResult['reasoning'],
        'songs': enhancedSongs,
        'generatedAt': DateTime.now().toIso8601String(),
        'stats': {
          'commitCount': commitData.length,
          'earliestCommit': commitData.isNotEmpty ? _getEarliestDate(commitData) : DateTime.now().toIso8601String(),
          'latestCommit': commitData.isNotEmpty ? _getLatestDate(commitData) : DateTime.now().toIso8601String(),
          'totalSongs': enhancedSongs.length,
        }
      };
    } catch (e) {
      print('🎵 [PlaylistGenerator] ERROR in generatePlayablePlaylist: $e');
      _debugLog('Error generating playable playlist: $e');
      return _buildFallbackPlaylistResult(commitData);
    }
  }

  /// Enhance playlist with Spotify data
  Future<List<Map<String, dynamic>>> _enhancePlaylist(List<Map<String, dynamic>> playlist) async {
    _debugLog('Enhancing playlist with Spotify data for ${playlist.length} songs');
    
    try {
      // Build search queries for each song
      final queries = playlist.map((song) => {
        'title': song['title'],
        'artist': song['artist'],
        'year': song['year'],
        'queries': [
          '${song['title']} ${song['artist']}', // Exact match
          '${song['title']} ${song['artist']} eurovision', // With eurovision
          '${song['title']} eurovision ${song['year']}', // With year
          '${song['title']} ${song['artist']} live', // Live versions often have previews
          '${song['title']} ${song['artist']} official', // Official versions
          '${song['title']} ${song['artist']} radio', // Radio versions
          song['title'], // Just the title as fallback
          '${song['artist']} ${song['title']}', // Artist first
        ]
      }).toList();
      
      // Process each song to find Spotify data
      final enhancedPlaylist = await Future.wait(
        playlist.asMap().entries.map((entry) async {
          final index = entry.key;
          final song = entry.value;
          final songQueries = (queries[index]['queries'] as List).cast<String>();
          
          // Try each query variation until we find a result with preview URL
          Map<String, dynamic>? bestMatch;
          
          for (final query in songQueries) {
            if (spotifyService == null) break;
            
            final searchResults = await spotifyService!.searchTracks(query);
            if (searchResults.isEmpty) continue;
            
            // First, try to find ANY track with preview URL
            final tracksWithPreviews = searchResults.where(
              (track) => track['preview_url'] != null && track['preview_url'].toString().isNotEmpty,
            ).toList();
            
            if (tracksWithPreviews.isNotEmpty) {
              // Found tracks with previews! Use the first one
              bestMatch = tracksWithPreviews.first;
              break;
            }
            
            // If no preview found yet, keep the first result as fallback
            if (bestMatch == null && searchResults.isNotEmpty) {
              bestMatch = searchResults.first;
            }
          }
          
          if (bestMatch != null) {
            // Return enhanced song
            return {
              ...song,
              'preview_url': bestMatch['preview_url'],
              'webPlayerUrl': bestMatch['webPlayerUrl'] ?? song['spotifyUrl'],
              'imageUrl': bestMatch['imageUrl'] ?? song['imageUrl'] ?? 
                       'https://via.placeholder.com/300x300.png?text=Eurovision',
              'isPlayable': bestMatch['preview_url'] != null,
              'spotifyId': bestMatch['id'],
            };
          }
          
          // If no match found with preview, return original with no preview
          return {
            ...song,
            'isPlayable': false,
            'imageUrl': song['imageUrl'] ?? 'https://via.placeholder.com/300x300.png?text=Eurovision',
          };
        }),
      );
      
      return enhancedPlaylist;
    } catch (e) {
      print('Error enhancing playlist: $e');
      // Return original songs if Spotify enhancement fails
      return playlist.map((song) => {
        ...song,
        'isPlayable': false,
        'imageUrl': song['imageUrl'] ?? 'https://via.placeholder.com/300x300.png?text=Eurovision',
      }).toList();
    }
  }
}


