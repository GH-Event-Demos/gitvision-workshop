import 'package:flutter/material.dart';

import '../models/coding_mood.dart';
import '../services/github_service.dart';
import '../services/sentiment_service.dart';
import '../services/logging_service.dart';

class AppStateProvider extends ChangeNotifier {
  final GitHubService _githubService;
  final SentimentService _sentimentService;
  final LoggingService _logger;

  AppStateProvider({
    required GitHubService githubService,
    required SentimentService sentimentService,
    required LoggingService logger,
  }) : _githubService = githubService,
       _sentimentService = sentimentService,
       _logger = logger;

  String _githubUsername = '';
  String get githubUsername => _githubUsername;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _commits = [];
  List<Map<String, dynamic>> get commits => _commits;

  CodingMood? _detectedMood;
  CodingMood? get detectedMood => _detectedMood;

  List<Map<String, dynamic>> _songSuggestions = [];
  List<Map<String, dynamic>> get songSuggestions => _songSuggestions;

  String? _error;
  String? get error => _error;

  void updateUsername(String username) {
    _githubUsername = username.trim();
    _error = null;
    notifyListeners();
  }

  void updateGitHubUsername(String username) {
    updateUsername(username);
  }

  String? get lastError => _error;

  Future<void> connectToGitHubUser() async {
    await analyzeMood();
  }

  Future<void> generatePlaylist() async {
    // Placeholder for playlist generation
    _logger.debug('Generating playlist...');
  }

  Future<void> analyzeMood() async {
    if (_githubUsername.isEmpty) {
      _error = 'Please enter a GitHub username';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _commits.clear();
    _detectedMood = null;
    notifyListeners();

    try {
      final result = await _githubService.fetchUserCommits(_githubUsername);
      _commits = result['commitData'] as List<Map<String, dynamic>>;
      
      if (_commits.isEmpty) {
        _error = 'No commits found for @$_githubUsername';
        notifyListeners();
        return;
      }

      final sentiment = await _sentimentService.analyzeCommitSentiment(
        result['commitMessages'] as List<String>,
      );
      _detectedMood = sentiment.mood;
      _logger.debug('Analysis complete: ${sentiment.mood.name} (${sentiment.confidence * 100}% confidence)');

      // Get Eurovision song suggestions based on the mood
      _songSuggestions = await _sentimentService.getEurovisionSuggestions(_detectedMood!);
      _logger.debug('Got ${_songSuggestions.length} Eurovision song suggestions');
    } catch (e) {
      _error = e.toString();
      _logger.error('Failed to analyze mood', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _githubUsername = '';
    _isLoading = false;
    _commits.clear();
    _detectedMood = null;
    _songSuggestions.clear();
    _error = null;
    notifyListeners();
  }
}