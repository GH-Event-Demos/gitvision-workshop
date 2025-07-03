// Configuration file for API settings that references the secure tokens

import 'dart:math';
import 'api_tokens.dart';

/// GitVision API Configuration that's safe to commit to version control
/// This references the secure tokens from api_tokens.dart
class ApiConfig {
  // GitHub Models API token reference
  static String get githubToken => ApiTokens.githubModelsToken;

  // Spotify API credentials
  static String get spotifyClientId => ApiTokens.spotifyClientId;
  static String get spotifyClientSecret => ApiTokens.spotifyClientSecret;

  // Spotify redirect URL for auth flow
  static const String spotifyRedirectUrl = "gitvision://callback";

  // API endpoints
  static const String githubModelsEndpoint =
      "https://models.github.ai/inference/chat/completions"; // For GitHub Models
  static const String spotifyAuthEndpoint =
      "https://accounts.spotify.com/api/token";
  static const String spotifyApiEndpoint = "https://api.spotify.com/v1";

  // Model settings - Model that excels in coding and instruction following
  static const String aiModel = "openai/gpt-4.1";
  static const String aiProvider =
      "azureml"; // Required provider for GitHub Models API

  // Validation
  static bool get hasValidTokens =>
      ApiTokens.githubModelsToken.isNotEmpty &&
      ApiTokens.spotifyClientId.isNotEmpty;

  // Debug information
  static void printDebugInfo() {
    print('======= API CONFIG DEBUG INFO =======');
    print(
        'GitHub Token: ${githubToken.substring(0, min(5, githubToken.length))}... (length: ${githubToken.length})');
    print(
        'Spotify Client ID: ${spotifyClientId.substring(0, min(5, spotifyClientId.length))}... (length: ${spotifyClientId.length})');
    print('GitHub Models Endpoint: $githubModelsEndpoint');
    print('AI Model: $aiModel');
    print('AI Provider: $aiProvider');
    print('Tokens Valid: $hasValidTokens');
    print('====================================');
  }
}
