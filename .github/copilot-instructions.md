# Copilot Instructions for GitVision Development

**Objective**: Deliver accurate, idiomatic code for Eurovision-themed GitHub commit analyzer with AI-powered playlist generation, adhering to modern Flutter best practices and cultural sensitivity.

## GitVision Context

### Project Domain
- **Eurovision-themed** GitHub commit mood analyzer creating Spotify playlists
- **Multi-API integration**: GitHub API, GitHub Models (AI), Spotify Web API
- **Cultural application** celebrating European music diversity (1996-2025)
- **Workshop environment** with real data integration and learning focus

### Key Technologies
- **Flutter 3.7+** for cross-platform development
- **GitHub Models API** for AI-powered Eurovision song curation
- **Spotify Web API** for playlist creation and music search
- **HTTP package** for RESTful API communications

## Security & API Best Practices

### API Token Management
- **NEVER hardcode tokens** - use `lib/config/api_tokens.dart` (git-ignored)
- Implement token validation and comprehensive error handling
- Handle GitHub API rate limits (5000 requests/hour) with exponential backoff
- Provide clear user-friendly error messages for API failures

```dart
class ApiConfig {
  static String get githubToken => ApiTokens.githubModelsToken;
  static const String githubEndpoint = "https://models.github.ai/inference/chat/completions";  // For GitHub Models
  
  static bool get hasValidTokens => 
    ApiTokens.githubModelsToken.isNotEmpty && 
    ApiTokens.spotifyClientId.isNotEmpty;
}
```

### Error Handling Patterns
```dart
try {
  final response = await http.get(uri, headers: headers)
    .timeout(const Duration(seconds: 10));
  // Handle success
} on SocketException {
  throw NetworkException('No internet connection');
} on TimeoutException {
  throw ApiException('Service temporarily unavailable');
}
```

## Eurovision Cultural Guidelines

### Cultural Sensitivity
- Use accurate country names and flag emojis (🇸🇪 🇮🇹 🇺🇦)
- Handle historical changes (Yugoslavia → Serbia, etc.)
- Respect Eurovision's diversity and inclusion values
- Avoid stereotypes about countries or cultures

### Mood-to-Eurovision Mapping
- **Productive/Flow** → Upbeat anthems (Euphoria, Fuego, Heroes)
- **Debugging/Intense** → Power ballads (Rise Like a Phoenix, 1944)
- **Creative/Experimental** → Unique entries (Shum, Epic Sax Guy)
- **Victory/Breakthrough** → Winners (Waterloo, Love Shine a Light)
- **Reflective/Cleanup** → Emotional songs (Arcade, Soldi)

### Eurovision Data Validation
```dart
class EurovisionSong {
  final String title, artist, country;
  final int year;
  final String reasoning; // AI explanation for mood match
  
  bool get isValidEurovisionEntry => 
    year >= 1956 && year <= DateTime.now().year &&
    EurovisionCountries.isValidCountry(country);
}
```

## Flutter Development Guidelines

### Project Structure
```
lib/
├── config/          # API configurations (api_tokens.dart git-ignored)
├── models/          # Eurovision, GitHub, Spotify data classes
├── services/        # API integrations (github_service, ai_playlist_service, spotify_service)
├── widgets/         # Reusable UI (eurovision_song_card, playlist_widget)
└── screens/         # Main app screens
```

### State Management
- Use **Provider** or **Riverpod** for app-wide state
- Handle loading, success, and error states explicitly
- Minimize `setState` usage; prefer reactive patterns
- Implement proper resource disposal

### Widget Best Practices
- Use `const` constructors extensively for performance
- Follow Material Design 3 guidelines with Eurovision theming
- Implement accessibility (semanticLabels for flags)
- Support responsive design for multiple device sizes

### AI Integration Pattern
```dart
class AIPlaylistService {
  Future<List<EurovisionSong>> generateEurovisionPlaylist(
    SentimentResult sentiment,
  ) async {
    final prompt = '''
    Based on coding mood: "${sentiment.mood}"
    
    Suggest 5 Eurovision songs matching this developer's vibe.
    Consider Eurovision history (1956-2024) and cultural diversity.
    
    Format as JSON: [{"title": "...", "artist": "...", "country": "...", "year": ..., "reasoning": "..."}]
    
    Keywords: ${sentiment.keywords.join(', ')}
    ''';
    
    final response = await _callGitHubModelsAPI(prompt);
    return _parseEurovisionResponse(response);
  }
}
```

## Error Handling & User Experience

### Comprehensive Error Categories
```dart
abstract class GitVisionException implements Exception {
  final String message;
  final String userMessage; // User-friendly explanation
  const GitVisionException(this.message, this.userMessage);
}

class NetworkException extends GitVisionException {
  const NetworkException(String message) 
    : super(message, 'No internet connection. Please check your network.');
}
```

### Loading States with Eurovision Theming
```dart
Widget get loadingEurovisionPlaylist => Column(
  children: [
    CircularProgressIndicator(),
    SizedBox(height: 16),
    Text('Curating your Eurovision playlist...'),
    Text('🇪🇺 Selecting songs from across Europe'),
  ],
);
```

## Testing & Quality Guidelines

### Unit Testing Focus
- Test Eurovision song validation logic
- Mock API responses for consistent testing
- Verify cultural data accuracy and sensitivity
- Test error handling for network failures

### Workshop-Specific Patterns
- Include helpful debug output: `debugPrint('🎵 Eurovision: ${song.title}')`
- Add learning-focused comments: `// Workshop TODO: Implement Spotify search`
- Ensure beginner-friendly error messages
- Log API calls for educational purposes

## Context Awareness

### File Context Recognition
- **`lib/models/`**: Generate complete data classes with JSON serialization
- **`lib/services/`**: Focus on API integration and error handling patterns  
- **`lib/widgets/`**: Provide Eurovision-themed UI components
- **`lib/screens/`**: Create complete layouts with proper navigation

### Clarifying Questions
- "Are you implementing GitHub commit analysis or Eurovision song curation?"
- "Do you need real API integration or workshop demonstration code?"
- "Should this include Eurovision cultural validation?"
- "Are you building StatelessWidget display or StatefulWidget interaction?"

## Advanced Features

### Spotify Integration
```dart
class SpotifyService {
  Future<void> authenticateWithSpotify() async {
    // Client Credentials OAuth flow
    final credentials = base64Encode(
      utf8.encode('${ApiConfig.spotifyClientId}:${ApiConfig.spotifyClientSecret}')
    );
    // Handle authentication and token refresh
  }
}
```


## Final Notes

Remember: GitVision celebrates the intersection of **technology and culture**. Every implementation should:

✨ **Respect Eurovision's cultural diversity**  
🛡️ **Prioritize security and user privacy**  
🚀 **Provide excellent developer experience**  
🎯 **Enable effective learning in workshop environments**  
🌍 **Bridge communities through music and code**

---

## Error Handling for Copilot

**For incomplete suggestions**: Include `// Workshop TODO:` comments and suggest next implementation steps

**If request is unclear**: Ask "Are you building Eurovision display, GitHub analysis, or Spotify integration?"

#tool:notify-user
{
  "sound": true,
  "message": "GitVision Eurovision development guidance ready! 🇪🇺🎵"
}