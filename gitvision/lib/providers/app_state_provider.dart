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
  })  : _playlistRepository = playlistRepository,
        _githubRepository = githubRepository,
        _logger = logger;
       
  // State
  String _githubUsername = '';
  bool _isConnecting = false;
  List<Map<String, dynamic>> _commits = [];
  List<Map<String, dynamic>> _playlist = [];
  bool _generatingPlaylist = false;
  bool _playlistGenerated = false;
  String? _lastError;
  CodingMood? _detectedVibe;
  String? _playlistAnalysis;
  BuildContext? _context;
  
  // Getters
  String get githubUsername => _githubUsername;
  bool get isConnecting => _isConnecting;
  List<Map<String, dynamic>> get commits => _commits;
  List<Map<String, dynamic>> get playlist => _playlist;
  bool get generatingPlaylist => _generatingPlaylist;
  bool get playlistGenerated => _playlistGenerated;
  String? get lastError => _lastError;
  CodingMood? get detectedVibe => _detectedVibe;
  String? get playlistAnalysis => _playlistAnalysis;
  BuildContext? get context => _context;
  
  // Audio playback state
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  
  int? _currentlyPlayingIndex;
  int? get currentlyPlayingIndex => _currentlyPlayingIndex;
  
  void updateGitHubUsername(String username) {
    _githubUsername = username.trim();
    _lastError = null;
    notifyListeners();
  }

  void clearError() {
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
        print('🎯 [AppState] Successfully set ${_commits.length} commits for @$_githubUsername');
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
    print('🎬 [AppState] generatePlaylist() called with ${_commits.length} commits');
    if (_commits.isEmpty) {
      print('🎬 [AppState] No commits available, aborting');
      _lastError = 'No commits available to analyze';
      notifyListeners();
      return;
    }

    print('🎬 [AppState] Starting playlist generation...');
    _generatingPlaylist = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _playlistRepository.generatePlaylist(_commits);
      print('🎬 [AppState] Got result from repository: success=${result.isSuccess}');

      if (result.isSuccess) {
        _playlist = result.playlist ?? [];
        _detectedVibe = result.mood;
        _playlistAnalysis = result.analysis;
        _playlistGenerated = true;
        print('🎬 [AppState] Playlist generated successfully: ${_playlist.length} songs');
      } else {
        print('🎬 [AppState] Playlist generation failed: ${result.error}');
        _lastError = result.error;
      }
    } catch (error) {
      print('🎬 [AppState] Playlist generation error: $error');
      _lastError = 'Failed to generate playlist: $error';
    } finally {
      print('🎬 [AppState] Playlist generation finished - generated: $_playlistGenerated, songs: ${_playlist.length}');
      _generatingPlaylist = false;
      notifyListeners();
    }
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
    _currentlyPlayingIndex = null;
    _isPlaying = false;
    notifyListeners();
  }
  
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
  
  Future<void> resumePlayback() async {
    if (_isPlaying || _currentlyPlayingIndex == null) return;
    
    try {
      final song = _playlist[_currentlyPlayingIndex!];
      await _playlistRepository.playSong(song);
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _logger.error('Error resuming playback', e);
    }
  }
  
  Future<void> stopPlayback() async {
    if (_currentlyPlayingIndex == null) return;
    
    try {
      await _playlistRepository.stopPlayback();
      _isPlaying = false;
      _currentlyPlayingIndex = null;
      notifyListeners();
    } catch (e) {
      _logger.error('Error stopping playback', e);
    }
  }
}