// Configuration file for API settings that references the secure tokens

// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'api_tokens.dart';

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
    if (kDebugMode) {
      print('======= API CONFIG DEBUG INFO =======');
    }
    print(
        'GitHub Token: ${githubToken.substring(0, min(5, githubToken.length))}... (length: ${githubToken.length})');
    print('GitHub API Endpoint: $githubApiEndpoint');
    print('User Agent: $userAgent');
    print('Tokens Valid: $hasValidTokens');
    print('====================================');
  }
}
