import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/coding_mood.dart';
import '../repositories/playlist_repository.dart';
import '../repositories/github_repository.dart';
import '../services/logging_service.dart';
import '../services/analytics_service.dart';
import '../services/error_handling_service.dart';

class AppStateProvider extends ChangeNotifier {
  final PlaylistRepository _playlistRepository;
  final GitHubRepository _githubRepository;
  final LoggingService _logger;
  final AnalyticsService _analytics;
  final ErrorHandlingService _errorHandler;
  final AudioPlayer _audioPlayer;

  AppStateProvider({
    required PlaylistRepository playlistRepository,
    required GitHubRepository githubRepository,
    required LoggingService logger,
    required AnalyticsService analytics,
    required ErrorHandlingService errorHandler,
    required AudioPlayer audioPlayer,
  }) : _playlistRepository = playlistRepository,
       _githubRepository = githubRepository,
       _logger = logger,
       _analytics = analytics,
       _errorHandler = errorHandler,
       _audioPlayer = audioPlayer;

  // GitHub State
  String _githubUsername = '';
  String get githubUsername => _githubUsername;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  List<Map<String, dynamic>> _commits = [];
  List<Map<String, dynamic>> get commits => _commits;

  // Playlist State
  List<Map<String, dynamic>> _playlist = [];
  List<Map<String, dynamic>> get playlist => _playlist;

  bool _playlistGenerated = false;
  bool get playlistGenerated => _playlistGenerated;

  bool _generatingPlaylist = false;
  bool get generatingPlaylist => _generatingPlaylist;

  CodingMood? _detectedVibe;
  CodingMood? get detectedVibe => _detectedVibe;

  String? _playlistAnalysis;
  String? get playlistAnalysis => _playlistAnalysis;

  // Audio State
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int? _currentlyPlayingIndex;
  int? get currentlyPlayingIndex => _currentlyPlayingIndex;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _currentDuration = Duration.zero;
  Duration get currentDuration => _currentDuration;

  // Error State
  String? _lastError;
  String? get lastError => _lastError;

  /// Update GitHub username
  void updateGitHubUsername(String username) {
    _githubUsername = username.trim();
    _lastError = null;
    notifyListeners();
  }

  /// Connect to GitHub user and fetch recent commits
  Future<void> connectToGitHubUser() async {
    if (_githubUsername.isEmpty) {
      _lastError = 'Please enter a GitHub username';
      notifyListeners();
      return;
    }

    _isConnecting = true;
    _lastError = null;
    _commits.clear();
    notifyListeners();

    try {
      final result = await _githubRepository.getUserCommits(_githubUsername);
      
      if (result.isSuccess) {
        _commits = result.data ?? [];
        
        _analytics.trackGitVisionEvent(
          action: 'github_connected',
          additionalProperties: {
            'username': _githubUsername,
            'commit_count': _commits.length,
          },
        );
        
        _logger.debug('Successfully fetched ${_commits.length} commits for @$_githubUsername');
      } else {
        _lastError = result.error ?? 'Failed to fetch commits';
      }
    } catch (error) {
      _lastError = 'Failed to fetch commits for @$_githubUsername: ${error.toString().replaceAll('Exception: ', '')}';
      _logger.error('GitHub error during user commit fetch', error);
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Generate playlist from current commits
  Future<void> generatePlaylist() async {
    if (_commits.isEmpty) {
      _lastError = 'No commits available to analyze';
      notifyListeners();
      return;
    }

    _generatingPlaylist = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _playlistRepository.generatePlaylist(_commits);

      if (result.isSuccess) {
        _playlist = result.playlist ?? [];
        _detectedVibe = result.mood;
        _playlistAnalysis = result.analysis;
        _playlistGenerated = true;

        _analytics.trackGitVisionEvent(
          action: 'playlist_generated',
          mood: _detectedVibe?.name,
          trackCount: _playlist.length,
          additionalProperties: {
            'username': _githubUsername,
          },
        );
      } else {
        _lastError = result.error;
        await _errorHandler.handleAIError(
          error: Exception(result.error),
          model: 'GitHub Models',
          operation: 'playlist_generation',
        );
      }
    } catch (error) {
      _lastError = 'Failed to generate playlist: $error';
    } finally {
      _generatingPlaylist = false;
      notifyListeners();
    }
  }

  /// Play a song at the given index
  Future<void> playSong(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    final song = _playlist[index];
    final previewUrl = song['preview_url'] as String?;

    if (previewUrl == null || previewUrl.isEmpty) {
      _lastError = 'No preview available for this song';
      notifyListeners();
      return;
    }

    try {
      // Stop any current playback first
      await _audioPlayer.stop();
      
      // Validate URL before playing
      if (previewUrl.trim().isEmpty) {
        _lastError = 'Invalid preview URL';
        notifyListeners();
        return;
      }
      
      await _audioPlayer.play(UrlSource(previewUrl));
      _currentlyPlayingIndex = index;
      _isPlaying = true;
      notifyListeners();

      _analytics.trackGitVisionEvent(
        action: 'song_played',
        additionalProperties: {
          'song_title': song['title'],
          'song_artist': song['artist'],
          'playlist_index': index,
        },
      );
    } catch (error) {
      _lastError = 'Failed to play song: $error';
      _logger.error('Audio playback error', error);
      notifyListeners();
    }
  }

  /// Pause current playback
  Future<void> pausePlayback() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (error) {
      _lastError = 'Failed to pause playback: $error';
      notifyListeners();
    }
  }

  /// Resume current playback
  Future<void> resumePlayback() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (error) {
      _lastError = 'Failed to resume playback: $error';
      notifyListeners();
    }
  }

  /// Stop current playback
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentlyPlayingIndex = null;
      _currentPosition = Duration.zero;
      _currentDuration = Duration.zero;
      notifyListeners();
    } catch (error) {
      _lastError = 'Failed to stop playback: $error';
      notifyListeners();
    }
  }

  /// Update audio position
  void updatePosition(Duration position) {
    _currentPosition = position;
    notifyListeners();
  }

  /// Update audio duration
  void updateDuration(Duration duration) {
    _currentDuration = duration;
    notifyListeners();
  }

  /// Clear current error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _githubUsername = '';
    _isConnecting = false;
    _commits.clear();
    _playlist.clear();
    _playlistGenerated = false;
    _generatingPlaylist = false;
    _detectedVibe = null;
    _playlistAnalysis = null;
    _isPlaying = false;
    _currentlyPlayingIndex = null;
    _currentPosition = Duration.zero;
    _currentDuration = Duration.zero;
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}