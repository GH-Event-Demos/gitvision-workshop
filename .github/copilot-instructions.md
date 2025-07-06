
# 🧠 Copilot Instructions for GitVision Development

**Objective**: Guide GitHub Copilot to generate idiomatic, secure Flutter code that analyzes GitHub commit sentiment and curates Eurovision-themed playlists using AI.

---

## 🎯 Core Project Context

### 🗂 Application Purpose
- Analyze developer GitHub commit patterns
- Use AI to infer commit **mood/sentiment**
- Match moods to **Eurovision songs** (2000–2025)
- Generate Spotify playlists
- Celebrate cultural diversity through music and code

### 🛠 Key Technologies
- **Flutter 3.7+**: Cross-platform app
- **GitHub Models API**: AI sentiment analysis + playlist generation
- **Spotify Web API**: Playlist creation
- **HTTP package**: REST communication

---

## 📐 Development Philosophy

- Build incrementally in **phases**
- Focus on **working code** over perfection
- Ensure strong **error handling**
- Adhere to **Flutter best practices**
- Prioritize **workshop-ready**, **beginner-friendly** implementations

---

## 🚦 Phase-Specific Copilot Guidelines

### 🔹 Phase 1: Basic Setup
When suggesting code:
- Minimal UI, functional layout
- Fetch GitHub commits only
- Keep API handling simple
- Use basic error states
- Avoid AI or Spotify integration

### 🔹 Phase 2: AI Integration
When suggesting code:
- Integrate GitHub Models API  
```dart
static const String modelsEndpoint = 'https://models.github.ai/inference/chat/completions';
```

- Implement sentiment analysis:
```dart
Future<SentimentResult> analyzeCommitSentiment(List<String> commits) async {
  // AI-powered classification of developer mood
}
```

- Generate song suggestions:
```dart
Future<List<Map<String, dynamic>>> getEurovisionSuggestions(CodingMood mood) async {
  // Return list of songs matched to mood
}
```

- Output should be JSON:
```json
[
  {
    "title": "Euphoria",
    "artist": "Loreen",
    "country": "Sweden",
    "year": 2012,
    "reasoning": "Upbeat, perfect for flow state"
  }
]
```

---

## 🛡️ Security & API Best Practices

### Token Management
- NEVER hardcode tokens
- Use `lib/config/api_tokens.dart` (git-ignored)
- Check for valid tokens before calling APIs
```dart
class ApiConfig {
  static bool get hasValidTokens =>
    ApiTokens.githubModelsToken.isNotEmpty &&
    ApiTokens.spotifyClientId.isNotEmpty;
}
```

### Error Handling Pattern
```dart
try {
  final response = await http.get(uri, headers: headers)
    .timeout(Duration(seconds: 10));
} on SocketException {
  throw NetworkException('No connection');
} on TimeoutException {
  throw ApiException('Timeout');
}
```

---

## 🎭 Eurovision Cultural Guidelines

- Use accurate country names and emojis 🇮🇪 🇺🇦 🇫🇷
- Avoid stereotypes or humor at a country’s expense
- Map moods to song types thoughtfully  
| Mood | Example Song |
|------|--------------|
| Productive | *Euphoria* |
| Debugging | *1944* |
| Creative | *Shum* |
| Victory | *Waterloo* |
| Reflective | *Arcade* |

```dart
class EurovisionSong {
  final String title, artist, country;
  final int year;
  final String reasoning;

  bool get isValidEurovisionEntry =>
    year >= 2000 && EurovisionCountries.isValidCountry(country);
}
```

---

## 📱 Flutter App Structure

### Project Layout
```
lib/
├── config/       # Tokens, endpoints
├── models/       # Data classes (commit, song, mood)
├── services/     # GitHub, AI, Spotify APIs
├── widgets/      # UI cards, loaders
└── screens/      # App views
```

### Widget Patterns
- Prefer `const` constructors
- Use Material Design 3
- Add `semanticLabels` to emoji/flag widgets
- Support small + large screens

### State Management
- Use **Riverpod** or **Provider**
- Handle states: loading, error, success
- Avoid `setState` in favor of reactive patterns

---

## 🎧 Spotify Integration (Phase 3+)
```dart
class SpotifyService {
  Future<void> authenticateWithSpotify() async {
    final credentials = base64Encode(
      utf8.encode('${ApiConfig.spotifyClientId}:${ApiConfig.spotifyClientSecret}')
    );
    // Use Client Credentials OAuth flow
  }
}
```

---

## 🧪 Testing Guidelines

- Unit test:
  - Mood-to-song logic
  - Data model validation
  - API error handling
- Add:
  ```dart
  debugPrint('🎵 Selected song: ${song.title}');
  // Workshop TODO: Add Spotify link
  ```

---

## 🧠 Copilot Prompt Optimization

### File Awareness
| File             | Focus Copilot on...                         |
|------------------|---------------------------------------------|
| `models/`        | Define complete, typed data models          |
| `services/`      | Implement API logic with error handling     |
| `widgets/`       | Create reusable UI (song cards, loaders)    |
| `screens/`       | Scaffold views and navigation               |

### If Suggestion is Incomplete
- Add `// Workshop TODO:` comments to prompt follow-ups

### Ask for Clarification
- “Is this GitHub parsing or Spotify integration?”
- “Should suggestions include real API responses or mock data?”
- “StatelessWidget or StatefulWidget?”

---

## 🌍 Final Copilot Notes

✅ Promote cultural sensitivity  
✅ Handle errors gracefully  
✅ Keep code modular and readable  
✅ Comment where workshop participants might need guidance  
✅ Default to real functionality unless demo/mocked is specified  
✅ Use idiomatic Dart/Flutter patterns