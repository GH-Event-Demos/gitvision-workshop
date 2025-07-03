// This is an example configuration file for API tokens
// Copy this file to api_tokens.dart and replace the placeholder values with your actual tokens
// IMPORTANT: api_tokens.dart should be added to .gitignore to prevent committing sensitive tokens

class ApiTokens {
  // GitHub Models API token - get this from https://github.com/settings/tokens
  static const String githubModelsToken = "your_github_models_token_here";
  
  // Spotify API credentials - get these from https://developer.spotify.com/dashboard
  static const String spotifyClientId = "your_spotify_client_id_here";
  static const String spotifyClientSecret = "your_spotify_client_secret_here";
  
  // Environment configuration
  static const bool isProduction = false;
  
  // Spotify redirect URI for OAuth (only needed for full Spotify integration)
  static String get spotifyRedirectUri => 
      isProduction 
          ? 'gitvision://callback'
          : 'gitvision://callback';
}
