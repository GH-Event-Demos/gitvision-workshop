import 'package:flutter/material.dart';

import '../models/coding_mood.dart';
import '../repositories/playlist_repository.dart';
import '../repositories/github_repository.dart';
import '../services/logging_service.dart';
import '../services/playlist_generator.dart';

class AppStateProvider extends ChangeNotifier {
  final PlaylistRepository _playlistRepository;
  final GitHubRepository _githubRepository;
  final LoggingService _logger;

  AppStateProvider({
    required PlaylistRepository playlistRepository,
    required GitHubRepository githubRepository,
    required LoggingService logger,
  }) : _playlistRepository = playlistRepository,
       _githubRepository = githubRepository,
       _logger = logger;

  String _githubUsername = '';
  String get githubUsername => _githubUsername;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  List<Map<String, dynamic>> _commits = [];
  List<Map<String, dynamic>> get commits => _commits;

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

  String? _lastError;
  String? get lastError => _lastError;
  
  // Audio playback state
  int _currentlyPlayingIndex = -1;
  int get currentlyPlayingIndex => _currentlyPlayingIndex;
  
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  void updateGitHubUsername(String username) {
    _githubUsername = username.trim();
    _lastError = null;
    notifyListeners();
  }

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
      } else {
        _lastError = result.error;
      }
    } catch (error) {
      _lastError = 'Failed to generate playlist: $error';
    } finally {
      _generatingPlaylist = false;
      notifyListeners();
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void reset() {
    _githubUsername = '';
    _isConnecting = false;
    _commits.clear();
    _playlist.clear();
    _playlistGenerated = false;
    _generatingPlaylist = false;
    _detectedVibe = null;
    _playlistAnalysis = null;
    _lastError = null;
    notifyListeners();
  }
}

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
      } else {
        _lastError = result.error;
      }
    } catch (error) {
      _lastError = 'Failed to generate playlist: $error';
    } finally {
      _generatingPlaylist = false;
      notifyListeners();
    }
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
    _lastError = null;
    _currentlyPlayingIndex = -1;
    _isPlaying = false;
    notifyListeners();
  }
  
  /// Play a song from the playlist by index
  Future<void> playSong(int index) async {
    if (index < 0 || index >= _playlist.length) {
      _logger.error('Invalid song index: $index');
      return;
    }
    
    try {
      // Stop any currently playing song
      if (_isPlaying) {
        await _playlistRepository.stopPlayback();
      }
      
      // Play the selected song
      final song = _playlist[index];
      await _playlistRepository.playSong(song);
      
      // Update state
      _currentlyPlayingIndex = index;
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _logger.error('Error playing song', e);
      _lastError = 'Could not play song: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Pause the currently playing song
  Future<void> pausePlayback() async {
    if (!_isPlaying) return;
    
    try {
      await _playlistRepository.pausePlayback();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _logger.error('Error pausing playback', e);
    }
  }
  
  /// Resume playback of the current song
  Future<void> resumePlayback() async {
    if (_isPlaying || _currentlyPlayingIndex < 0) return;
    
    try {
      await _playlistRepository.resumePlayback();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _logger.error('Error resuming playback', e);
    }
  }
  
  /// Stop the currently playing song
  Future<void> stopPlayback() async {
    if (_currentlyPlayingIndex < 0) return;
    
    try {
      await _playlistRepository.stopPlayback();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _logger.error('Error stopping playback', e);
    }
  }
}