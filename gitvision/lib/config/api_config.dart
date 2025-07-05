// Configuration file for API settings that references the secure tokens

import 'dart:math';
import 'api_tokens.dart';
import 'package:flutter/foundation.dart';

/// GitVision API Configuration that's safe to commit to version control
/// This references the secure tokens from api_tokens.dart
class ApiConfig {
  // GitHub API token reference
  static String get githubToken => ApiTokens.githubToken;

  // GitHub API endpoints
  static const String githubApiEndpoint = "https://api.github.com";
  static const String userAgent = "GitVision-Workshop-App";

  // Validation
  static bool get hasValidTokens => ApiTokens.githubToken.isNotEmpty;

  // Debug information
  static void printDebugInfo() {
    print('======= API CONFIG DEBUG INFO =======');
    print('GitHub Token: ${githubToken.substring(0, min(5, githubToken.length))}... (length: ${githubToken.length})');
    print('GitHub API Endpoint: $githubApiEndpoint');
    print('User Agent: $userAgent');
    print('Tokens Valid: $hasValidTokens');
    print('====================================');
  }
}
