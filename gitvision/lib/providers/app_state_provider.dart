import 'package:flutter/material.dart';

import '../models/coding_mood.dart';
import '../repositories/playlist_repository.dart';
import '../repositories/github_repository.dart';
import '../services/logging_service.dart';

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
    notifyListeners();
  }
}


}