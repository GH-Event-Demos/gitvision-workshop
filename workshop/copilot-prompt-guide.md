# GitVision Workshop Copilot Prompt Guide

This guide provides effective prompting strategies for GitHub Copilot to help generate appropriate code for each outcome in the GitVision Eurovision Workshop. It covers step-by-step project phases, outcome-driven prompt templates, advanced prompt engineering techniques, and examples of actual high-quality prompts for the GitVision app.

---

## Phase 0: Project Initialization

### Effective Prompts

1. **Create Basic Flutter App Structure**
    ```dart
    // Create a basic Flutter app called GitVision with:
    // - A MaterialApp with 'GitVision - Eurovision Edition' title
    // - Deep purple theme with Material 3 enabled
    // - Main screen scaffold with AppBar and basic body layout
    // - Initialization of API configuration
    ```

2. **Setup Main Entry Point**
    ```dart
    // Create a main.dart file that:
    // - Initializes Flutter bindings
    // - Checks for web platform with kIsWeb
    // - Prints API debug info
    // - Uses const constructor for app widget
    // - Sets up app theme with ColorScheme.fromSeed
    ```

3. **MainScreen Skeleton**
    ```dart
    // Create a MainScreen widget for a Flutter app that:
    // - Uses Scaffold with deepPurple AppBar
    // - Contains a Card for GitHub connection
    // - Uses proper padding and spacing
    // - Prepares column layout for future widgets
    ```

---

## Phase 1: Setup

### Outcome: Environment Configuration

**Effective Prompts:**
1. "Set up Flutter dependencies in pubspec.yaml for a Eurovision-themed GitHub analyzer that needs HTTP, audioplayers, provider, url_launcher, and sentiment analysis packages."
2. "Create a secure API token configuration system with two files: lib/config/api_config.dart that's safe to commit and api_tokens.dart that's gitignored, with a tokens.example.dart template."
3. "Implement a debug configuration validator that uses Flutter's kDebugMode to conditionally print API token validation status on app startup."

### Outcome: Flutter Project Structure

**Effective Prompts:**
1. "Create a Flutter project structure for a GitHub analytics app with directories for models, services, repositories, providers, widgets, and screens following clean architecture principles."
2. "Set up a comprehensive .gitignore file for a Flutter project that ignores build artifacts, IDE files, and specifically excludes lib/config/api_tokens.dart for security."
3. "Configure a Flutter app with MaterialApp using deepPurple theme, Material 3, and provider package for state management."

---

## Phase 2: GitHub Integration

### Outcome: GitHub API Authentication & Data Fetching

**Highly Effective Prompts:**

1. **Context-Rich API Implementation**
    ```dart
    // In GitVision Eurovision app, implement GitHub API integration that:
    // - Fetches recent commit events from https://api.github.com/users/{username}/events
    // - Extracts commit messages from PushEvent payloads
    // - Handles 403 (rate limit), 404 (user not found), network timeouts
    // - Uses Eurovision-themed error messages like "Eurovision break time! GitHub API rate limit exceeded"
    // - Limits to 10 commits for performance
    // - Includes proper User-Agent header for GitHub API compliance
    ```

2. **Error Handling & UI Feedback**
    ```dart
    // Create a GitHubConnectionWidget for Flutter that:
    // - Has a TextField for username input with deepPurple theme
    // - Shows loading indicator during API calls
    // - Displays user-friendly error messages in a red container with close button
    // - Shows success in a green container with commit count
    // - Has proper state management for loading/error/success states
    ```

3. **Error-First Development**
    ```dart
    // Create comprehensive GitHub API error handling with Eurovision theming:
    // Handle specific scenarios:
    // - 403: "Eurovision break time! GitHub API rate limit exceeded. Even Eurovision has intermissions - try again in an hour!"
    // - 404: "This GitHub user is more elusive than a Eurovision winner prediction! Please check the username."
    // - Network: "Eurovision needs the internet! Please check your connection and try again."
    // - Timeout: "Eurovision timeout! Even the best performances need good timing. Please try again!"
    ```

---

### Outcome: Commit Sentiment Analysis

**Highly Effective Prompts:**

1. **Eurovision-Themed Mood Detection**
    ```dart
    // Create Eurovision-themed sentiment analyzer that maps commit keywords to coding moods:
    // Map these patterns:
    // - 'productive' keywords (add, implement, create, feature, update, build) → "Productive Flow - Like Eurovision upbeat anthems! (Euphoria vibes)"
    // - 'debugging' keywords (fix, bug, issue, error, crash, debug) → "Debugging Intensity - Like Eurovision power ballads! (Rise Like a Phoenix)"
    // - 'creative' keywords (design, style, ui, animation, theme, experiment) → "Creative Experimental - Like unique Eurovision entries! (Epic Sax Guy energy)"
    // - 'victory' keywords (release, deploy, complete, finish, milestone, ship) → "Victory Breakthrough - Like Eurovision winners! (Waterloo moment)"
    // - 'reflective' keywords (cleanup, organize, document, improve, optimize) → "Reflective Cleanup - Like emotional Eurovision songs! (Arcade feels)"
    // Use case-insensitive matching and count keyword occurrences to determine dominant mood
    ```

---

### Outcome: UI State Management

**Highly Effective Prompts:**

1. **Flutter State Management with Loading**
    ```dart
    // Create StatefulWidget for GitHub analysis with these exact state variables:
    // - TextEditingController _usernameController
    // - bool _isLoading (for API calls)
    // - String? _errorMessage (for user-friendly errors)
    // - List<String> _commitMessages (for extracted commits)
    // - String? _detectedMood (for sentiment result)
    // Include loading UI with "Analyzing Eurovision vibes..." message
    // Show commit list with Eurovision mood card when analysis completes
    ```

---

## Phase 3: AI Integration & Music Playback

### Outcome: GitHub Models API Integration

**Highly Effective Prompts:**

1. **Complete AI Service Implementation**
    ```dart
    // Implement GitHub Models API integration in AIPlaylistService for GitVision with:
    // - Secure authentication using Bearer token from ApiConfig.githubToken
    // - POST request to https://models.github.ai/inference/chat/completions
    // - Required headers: Accept: application/json, Authorization: Bearer {token}, 
    //   Content-Type: application/json, X-Request-Type: JSON, X-GitHub-Api-Version: 2022-11-28
    // - JSON structure with model: ApiConfig.aiModel, provider: ApiConfig.aiProvider
    // - Temperature: 0.7 for creative song selection, max_tokens: 1000
    // - Timeout handling (30 seconds) with exponential backoff retry logic
    // - Eurovision-specific error handling like "Eurovision judge is taking a break!"
    // - Comprehensive response parsing with fallback mechanism
    ```

2. **Structured AI Prompt Engineering with Cultural Context**
    ```dart
    // Create a Eurovision-specific prompt for GitHub Models API that:
    // - Includes CULTURAL CONTEXT: "Eurovision is Europe's beloved song contest celebrating 
    //   diversity, creativity, and unity through music. Each song represents a country's 
    //   cultural identity and artistic expression."
    // - Uses format: "Create a Eurovision playlist of EXACTLY 5 songs that match a {mood} coding mood"
    // - Requests specific JSON format: [{"title": "...", "artist": "...", "country": "...", "year": ..., "reasoning": "..."}]
    // - Emphasizes cultural diversity: "Mix different decades and countries for cultural diversity"
    // - Includes regional guidance: "Nordic efficiency, Eastern European passion, Mediterranean warmth, British innovation"
    // - Ensures years are valid (2020-2025) and countries are actual Eurovision participants
    // - Maps moods to specific examples: Productive → Euphoria-Sweden 2012, Intense → Rise Like a Phoenix-Austria 2014
    // - Has fallback Eurovision songs per mood category when AI fails
    ```

---

### Outcome: Eurovision Song Modeling & Validation

**Highly Effective Prompts:**

1. **Complete EurovisionSong Model with Robust Validation**
    ```dart
    // Create a comprehensive EurovisionSong model class that:
    // - Has fields for title, artist, country, year (int), reasoning, spotifyUrl, previewUrl, imageUrl
    // - Includes constructor assertions for validation: assert(year >= 2020 && year <= 2025)
    // - Validates non-empty title, artist, and country in constructor
    // - Contains static List<String> validCountries with all Eurovision participants
    // - Implements static method isValidCountry(String country) for validation
    // - Includes JSON serialization/deserialization with enhanced fromJson() factory
    // - Enhanced fromJson() validates and sanitizes data with fallback to defaultSong
    // - Implements proper toString() method showing "{title} by {artist} ({country}, {year})"
    // - Uses non-const constructor to allow validation method calls
    ```

2. **Eurovision Cultural Validation with Comprehensive Country List**
    ```dart
    // Implement Eurovision cultural validation logic that:
    // - Maintains comprehensive static const List<String> validCountries including:
    //   ['Albania', 'Andorra', ... 'Ukraine', 'United Kingdom', 'Yugoslavia']
    // - Implements case-insensitive country validation with validCountries.any((c) => c.toLowerCase() == country.toLowerCase())
    // - Provides fallback mechanism in fromJson() that uses defaultSong.country for invalid entries
    // - Validates year range with fallback to defaultSong.year for invalid years
    // - Trims and validates string inputs before processing
    // - Respects cultural sensitivities with official country names
    ```

---

### Outcome: AI Response Parsing & Error Handling

**Highly Effective Prompts:**

1. **Robust JSON Parsing with Enhanced EurovisionSong Factory**
    ```dart
    // Create a resilient Eurovision AI response parser that:
    // - Uses EurovisionSong.fromJson() factory method for consistent validation
    // - Safely extracts JSON data from AI completions API response with try-catch blocks
    // - Handles malformed JSON by falling back to _getFallbackEurovisionSongs()
    // - Parses response.body with proper null checking: result['choices'][0]['message']['content']
    // - Uses jsonList.map((json) => EurovisionSong.fromJson(json as Map<String, dynamic>))
    // - Validates each song automatically through EurovisionSong's built-in validation
    // - Filters out invalid entries through the model's validation logic
    // - Limits to exactly 5 songs and pads with fallback songs if needed
    // - Returns a clearly typed List<EurovisionSong> with null safety
    ```

2. **Comprehensive Fallback System with Non-Const Objects**
    ```dart
    // Implement Eurovision fallback system with:
    // - Pre-defined Eurovision songs using EurovisionSong() constructor (not const)
    // - Fallback songs for each mood: _getFallbackEurovisionSongs(String mood)
    // - Switch statement handling: 'frustrated'/'debugging', 'productive'/'flow', default cases
    // - At least 5 songs per mood from different decades/countries
    // - Songs like: Waterloo-Sweden 1974, Euphoria-Sweden 2012, Rise Like a Phoenix-Austria 2014,
    //   Heroes-Sweden 2015, Fuego-Cyprus 2018, 1944-Ukraine 2016, Hard Rock Hallelujah-Finland 2006
    // - Clear indication when falling back with debug messages
    // - Eurovision-themed error messages like "The AI jury is deliberating!"
    // - Graceful degradation that never breaks the user experience
    // - Proper error logging with _debugLog() for failed AI requests
    ```

---

### Additional Implementation-Proven Prompts

3. **Fixing Constant Expression Issues**
    ```dart
    // Fix Dart compilation errors in EurovisionSong model:
    // - Change const EurovisionSong constructor to non-const EurovisionSong
    // - Update static const defaultSong to static final defaultSong
    // - Remove const from all EurovisionSong instantiations in fallback methods
    // - Use EurovisionSong() instead of const EurovisionSong() in _getFallbackSongs()
    // - Ensure constructor assertions work with non-const validation methods
    // - Maintain validation logic while avoiding "Methods can't be invoked in constant expressions" errors
    ```

4. **System Message Optimization for GitHub Models**
    ```dart
    // Create optimized system message for GitHub Models API that:
    // - Identifies as "Eurovision music expert with deep cultural knowledge"
    // - Emphasizes cultural significance alongside mood matching
    // - Specifies exact requirements: "real Eurovision entry", "valid Eurovision participant"
    // - Requests "brief explanation connecting coding mood to song's cultural significance"
    // - Uses temperature: 0.7 for balanced creativity and accuracy
    // - Includes provider: ApiConfig.aiProvider for GitHub Models compatibility
    ```

---

## Phase 4: Spotify Playback

### Outcome: API Integration

**Effective Prompts:**
1. "Implement basic Spotify client credentials authentication flow in Flutter (without OAuth)."
2. "Create a secure token storage system for Spotify API credentials in a Flutter app."
3. "Write error handling for Spotify API failures with user-friendly messages."

### Outcome: Playlist Creation

**Effective Prompts:**
1. "Implement a Spotify search function to find Eurovision songs by title and artist with fallback options."
2. "Create a matching algorithm that handles Eurovision song titles that might differ slightly from Spotify track names."
3. "Build a function to handle missing tracks on Spotify with appropriate user feedback."

### Outcome: Audio Playback

**Effective Prompts:**
1. "Create a Flutter widget for playing Spotify preview tracks with simple play/pause controls."
2. "Implement a visually appealing Eurovision-themed playlist card with country flags and play buttons."
3. "Build an audio player service that manages playback state and handles errors gracefully."

---

## Phase 5: Further Enhancements

### Outcome: Social Sharing

**Effective Prompts:**
1. "Implement social sharing functionality in Flutter for sharing Eurovision playlists to different platforms."
2. "Create shareable content formats for Eurovision playlists including text, image, and link options."
3. "Build platform-specific sharing adapters for iOS and Android in Flutter."

### Outcome: Visual Enhancements

**Effective Prompts:**
1. "Create a visually appealing Eurovision-themed shareable card widget in Flutter."
2. "Implement an image export function for Flutter widgets to create shareable playlist images."
3. "Build a customizable playlist card with Eurovision branding and country flags."

### Outcome: Advanced Features

**Effective Prompts:**
1. "Implement local storage for Eurovision playlists using shared_preferences in Flutter."
2. "Create a team-based commit analyzer that combines multiple developers' coding patterns."
3. "Build a user preferences system for favorite Eurovision eras and countries."

---

## Advanced Prompt Engineering Techniques for GitVision

### 1. Context-Rich System Understanding
```dart
// In GitVision's Flutter Eurovision app (which connects GitHub commit analysis with 
// AI Eurovision song recommendations and Spotify playback):
// 
// Implement a robust error handling system that:
// - Uses Eurovision-themed error messages ("Even Eurovision has technical difficulties!")
// - Provides specific feedback for each API failure scenario
// - Implements exponential backoff for rate limits
// - Includes offline mode with cached Eurovision recommendations
// - Maintains proper Flutter state management during error recovery
```

### 2. Multi-Step Prompting
**Strategy**: Break complex tasks into sequential prompts for better results.
```
Step 1: Create the data structure
Create a Dart class for Eurovision song recommendations that includes
validation for years (2020-2025) and proper country name handling.

Step 2: Add parsing logic  
Add a factory constructor to parse JSON responses from GitHub Models API
with comprehensive error handling for malformed data.

Step 3: Implement fallbacks
Add fallback methods that provide default Eurovision songs when AI parsing fails.
```

### 3. Constraint-Based Prompting
**Strategy**: Define clear constraints to guide implementation decisions.
```
Implement a GitHub commit analyzer with these constraints:
- Must handle rate limits gracefully with exponential backoff
- Should filter out merge commits and bot-generated commits
- Must preserve user privacy (no personal data logging)
- Should work with paginated API responses
- Must fail gracefully with meaningful Eurovision-themed error messages
```

### 4. Pattern-Specific Prompting
**Strategy**: Reference specific design patterns for consistent architecture.
```
Using the Repository pattern, create a GitHubRepository that:
- Abstracts GitHub API calls from business logic
- Implements caching for frequently accessed data
- Provides clean interfaces for commit data retrieval
- Follows SOLID principles for testability
```

### 5. Example-Driven Prompting
**Strategy**: Provide examples of expected input/output for clearer results.
```
Create a Eurovision mood classifier that maps commit messages to moods:

Examples:
"fix: resolve critical bug in user authentication" → "Debugging" (like Eurovision power ballads)
"feat: add innovative UI animations" → "Creative" (like experimental Eurovision entries)
"refactor: optimize database queries" → "Productive" (like upbeat Eurovision anthems)

Handle edge cases like empty messages and non-English commits.
```

### 6. Progressive Enhancement Prompting
**Strategy**: Build features incrementally with clear upgrade paths.
```dart
// Basic version
Create a simple Eurovision song player widget with play/pause functionality.

// Enhanced version  
Extend the player widget to include:
- Progress bar with seeking
- Volume control
- Eurovision-themed animations
- Country flag displays
- Error states for unavailable tracks
```

### 7. Testing-First Prompting
**Strategy**: Include testing requirements in prompts for more robust code.
```
Create a EurovisionSong model class that includes:
- Proper validation methods
- Comprehensive toString() implementation
- Equality operators for testing
- Factory constructors for different data sources
- Unit test examples for all validation scenarios
```

### 8. Cultural Sensitivity Prompting
**Strategy**: Ensure appropriate handling of Eurovision's international context.
```
Create a country mapping service that:
- Handles historical Eurovision country changes (Yugoslavia → Serbia, etc.)
- Uses respectful, official country names
- Includes proper flag emoji mappings
- Validates against official Eurovision participant lists
- Provides alternatives for disputed territories
- Respects cultural sensitivities in song selection
```

### 9. Performance-Conscious Prompting
**Strategy**: Include performance considerations in complex features.
```
Implement an AI playlist generator with performance optimizations:
- Batch API calls to reduce network overhead
- Implement response caching with TTL
- Use lazy loading for Eurovision song metadata
- Optimize JSON parsing for large responses
- Include monitoring for API response times
```

### 10. Error-First Prompting
**Strategy**: Design error handling before implementing happy path.
```
Design comprehensive error handling for GitHub Models API that covers:
- Network connectivity issues
- API rate limiting (with retry strategies)
- Malformed AI responses (with fallback parsing)
- Authentication failures (with clear user guidance)
- Service unavailability (with offline mode)
Include Eurovision-themed error messages that maintain user engagement.
```

---

## Prompt Templates for Common Patterns

### API Service Template
```
Create a [ServiceName] class for [Platform] API integration that:
- Implements [authentication method] with secure token management
- Provides async methods for [specific operations]
- Includes comprehensive error handling with [theme]-appropriate messages
- Follows Flutter/Dart best practices for [specific patterns]
- Integrates with existing GitVision [architecture component]
- Includes [specific validation/security requirements]
```

### Widget Template
```
Build a Flutter widget called [WidgetName] that:
- Displays [specific data] in a [visual style] format
- Includes [interaction patterns] for user engagement
- Handles [error states] gracefully with appropriate feedback
- Follows [design system] guidelines with [theme] styling
- Is responsive for [platform requirements]
- Includes accessibility features for [specific needs]
```

### Data Model Template
```
Create a Dart data class [ModelName] that:
- Represents [domain concept] with [specific fields]
- Includes validation for [business rules]
- Provides JSON serialization/deserialization
- Implements equality operators and toString()
- Handles [edge cases] appropriately
- Follows [naming conventions] for [domain area]
```

---

## General Tips for Effective Copilot Prompts

1. **Be Specific**: Include the programming language (Dart/Flutter) and file context.
2. **Include Requirements**: Mention error handling, validation, and specific features.
3. **Reference Standards**: Mention Flutter best practices and design patterns.
4. **Cultural Context**: Include Eurovision-specific requirements for accuracy and cultural sensitivity.
5. **Code Structure**: Indicate desired patterns (services, models, widgets).
6. **Think in Steps**: Break complex features into smaller, manageable prompts.
7. **Consider Edge Cases**: Explicitly mention error scenarios and boundary conditions.
8. **Maintain Context**: Reference existing code structure and naming conventions.

---

## GitVision Optimized Prompt Template

The most effective GitVision prompt style based on actual implementation experience:

```dart
// For GitVision Eurovision Flutter app, implement a {feature} that:
//
// 1. Integration requirements:
//    - Connects to {API/service} with proper authentication
//    - Handles {specific error cases} with Eurovision-themed messages
//    - Follows Flutter best practices for async operations
//
// 2. Data handling requirements:
//    - Processes {input data format} into {output data structure}
//    - Validates data against Eurovision rules (years 2020-2025, valid countries)
//    - Includes fallback mechanisms when data is unavailable/invalid
//
// 3. UI/UX requirements:
//    - Shows loading states with Eurovision theming
//    - Displays error feedback in user-friendly format
//    - Maintains cultural sensitivity with accurate country references
//
// 4. Cultural considerations:
//    - Maps programming concepts to Eurovision themes
//    - Uses accurate country names and flag emojis
//    - Respects Eurovision's diversity and inclusion values
//
// Code structure should follow GitVision's {architecture pattern} with
// proper separation of concerns and testability.
```

---

## Examples of Highly Effective Actual Prompts

### 1. Complete AIPlaylistService Implementation

```dart
// For GitVision Eurovision app, implement AIPlaylistService.generateEurovisionPlaylist() that:
//
// 1. API Integration requirements:
//    - Uses GitHub Models API endpoint: https://models.github.ai/inference/chat/completions
//    - Includes required headers: Accept: application/json, Authorization: Bearer {token},
//      Content-Type: application/json, X-Request-Type: JSON, X-GitHub-Api-Version: 2022-11-28
//    - Uses model: ApiConfig.aiModel and provider: ApiConfig.aiProvider
//    - Implements exponential backoff retry logic for rate limits and timeouts
//
// 2. Cultural Eurovision prompting:
//    - Includes cultural context about Eurovision celebrating diversity and unity
//    - Maps coding moods to specific Eurovision examples with countries and years
//    - Emphasizes regional diversity: Nordic efficiency, Eastern European passion, etc.
//    - Requests exactly 5 songs with title, artist, country, year, reasoning fields
//
// 3. Robust parsing and validation:
//    - Uses EurovisionSong.fromJson() for automatic validation
//    - Handles malformed responses with fallback to _getFallbackEurovisionSongs()
//    - Validates years (2020-2025) and countries against valid Eurovision participants
//    - Returns exactly 5 songs, padding with fallbacks if needed
```

### 2. Eurovision Song Model with Comprehensive Validation

```dart
// For GitVision Eurovision app, create EurovisionSong model class that:
//
// 1. Validation requirements:
//    - Contains static List<String> validCountries with all Eurovision participants
//    - Implements static isValidCountry() method for country validation
//    - Uses non-const constructor with assert() statements for year (2020-2025) validation
//    - Validates non-empty title, artist, country in constructor assertions
//
// 2. Data handling requirements:
//    - Enhanced fromJson() factory that validates and sanitizes input data
//    - Trims string inputs and validates against business rules
//    - Falls back to defaultSong values for invalid data instead of throwing errors
//    - Supports fields: title, artist, country, year, reasoning, spotifyUrl, previewUrl, imageUrl
//
// 3. Technical requirements:
//    - Uses static final defaultSong instead of const to avoid constant expression errors
//    - Implements proper toString() method: "{title} by {artist} ({country}, {year})"
//    - Includes toJson() method for serialization
//    - Maintains cultural sensitivity with official Eurovision country names
```

### 3. GitHub Commit Sentiment Analysis

```dart
// For GitVision Eurovision app, implement a GitHub commit sentiment analyzer that:
//
// 1. Data analysis requirements:
//    - Creates a mapping of programming keywords to Eurovision moods
//    - Maps 'productive' keywords (add, implement, create) → "Productive Flow - Like Eurovision upbeat anthems! (Euphoria vibes)"
//    - Maps 'debugging' keywords (fix, bug, issue) → "Debugging Intensity - Like Eurovision power ballads! (Rise Like a Phoenix)"
//    - Maps 'creative' keywords (design, style, ui) → "Creative Experimental - Like unique Eurovision entries! (Epic Sax Guy energy)"
//    - Maps 'victory' keywords (release, deploy, complete) → "Victory Breakthrough - Like Eurovision winners! (Waterloo moment)"
//    - Maps 'reflective' keywords (cleanup, organize, document) → "Reflective Cleanup - Like emotional Eurovision songs! (Arcade feels)"
//
// 2. Implementation details:
//    - Use case-insensitive matching for better accuracy
//    - Count keyword occurrences to determine dominant mood
//    - Default to 'productive' mood if no clear pattern emerges
//    - Process an entire list of commit messages as input
//    - Return both mood category and Eurovision-themed description
//
// 3. Integration with app:
//    - Callable from StatefulWidget context
//    - Updates UI state with detected mood
//    - Enables further processing for AI Eurovision recommendations
```

---

## Debugging Copilot Responses

When your GitVision prompts don't produce the expected results:

1. **Add Eurovision Context:** Include specific references to Eurovision themes and cultural requirements.
2. **Use Code Comments Format:** Structure as `// Comment style` rather than natural language.
3. **Be Extremely Specific:** Include exact method names, parameter types, and return values.
4. **List All Edge Cases:** Explicitly mention all error scenarios that need handling.
5. **Include Sample Data:** Provide examples of input/output formats.
6. **Split Complex Features:** Break features into smaller components with clear dependencies.
7. **Specify Cultural Requirements:** Include explicit cultural sensitivity guidance.

---
