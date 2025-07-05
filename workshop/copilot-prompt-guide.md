# GitVision Workshop Copilot Prompt Guide

This guide provides effective prompting strategies for GitHub Copilot to help generate appropriate code for each outcome in the GitVision Eurovision Workshop.

## Phase 1: Setup

### Outcome: Environment Configuration

**Effective Prompts:**
1. "Set up Flutter dependencies for a project that will use HTTP, audio playback, and API integration."
2. "Create a secure API token configuration class for storing GitHub and Spotify credentials in a Flutter app."
3. "Implement a configuration validator that ensures all required API tokens are present before app initialization."

### Outcome: Flutter Project Structure

**Effective Prompts:**
1. "Create a Flutter project structure with separate directories for models, services, widgets, and screens."
2. "Set up a proper .gitignore file for a Flutter project that ignores API tokens and sensitive information."
3. "Configure a Flutter app to run in web mode with appropriate browser compatibility settings."

## Phase 2: GitHub Integration

### Outcome: GitHub API Authentication & Data Fetching

**Highly Effective Prompts:**

1. **Context-Rich API Implementation:**

```dart
// In GitVision Eurovision app, implement GitHub API integration that:
// - Fetches recent commit events from https://api.github.com/users/{username}/events
// - Extracts commit messages from PushEvent payloads
// - Handles 403 (rate limit), 404 (user not found), network timeouts
// - Uses Eurovision-themed error messages like "Eurovision break time! GitHub API rate limit exceeded"
// - Limits to 10 commits for performance
// - Includes proper User-Agent header for GitHub API compliance
```

2. **Error-First Development:**

```dart
// Create comprehensive GitHub API error handling with Eurovision theming:
// Handle specific scenarios:
// - 403: "Eurovision break time! GitHub API rate limit exceeded. Even Eurovision has intermissions - try again in an hour!"
// - 404: "This GitHub user is more elusive than a Eurovision winner prediction! Please check the username."
// - Network: "Eurovision needs the internet! Please check your connection and try again."
// - Timeout: "Eurovision timeout! Even the best performances need good timing. Please try again!"
```

### Outcome: Commit Sentiment Analysis

**Highly Effective Prompts:**

1. **Eurovision-Themed Mood Detection:**

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

### Outcome: UI State Management

**Highly Effective Prompts:**

1. **Flutter State Management with Loading:**

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

## Phase 3: AI Eurovision Magic

### Outcome: GitHub Models API Integration

**Highly Effective Prompts:**

1. **Complete AI Service Implementation:**

```dart
// Implement GitHub Models API integration in AIPlaylistService for GitVision with:
// - Secure authentication using token from ApiConfig
// - POST request to https://models.github.ai/inference/chat/completions
// - JSON structure with model: "github-starcoder2-7b-2024-05-20"
// - Proper headers and timeout handling (15 seconds)
// - Eurovision-specific error handling like "Eurovision judge is taking a break!"
// - Comprehensive response parsing with fallback mechanism
```

2. **Structured AI Prompt Engineering:**

```dart
// Create a Eurovision-specific prompt for GitHub Models API that:
// - Uses this exact format: "Based on coding mood: '{mood}', suggest 5 Eurovision songs matching this developer's vibe."
// - Requests specific JSON format: [{"title": "...", "artist": "...", "country": "...", "year": ..., "reasoning": "..."}]
// - Includes helpful context about Eurovision's cultural importance
// - Provides mood keywords to guide song selection
// - Ensures years are valid (1956-2025) and countries are actual Eurovision participants
// - Has fallback Eurovision songs per mood category when AI fails
```

### Outcome: Eurovision Song Modeling & Validation

**Highly Effective Prompts:**

1. **Complete EurovisionSong Model:**

```dart
// Create a comprehensive EurovisionSong model class that:
// - Has fields for title, artist, country, year (int), and reasoning
// - Includes JSON serialization/deserialization
// - Implements proper toString() and equality methods
// - Contains validation for years (1956-2025)
// - Validates against official Eurovision country list
// - Has factory constructor to parse AI-generated responses
// - Includes toString() method showing "{title} by {artist} ({country}, {year})"
```

2. **Eurovision Cultural Validation:**

```dart
// Implement Eurovision cultural validation logic that:
// - Maintains a list of valid Eurovision countries from 1956-2025
// - Handles historical country changes (e.g., Yugoslavia → Serbia, USSR → Russia)
// - Maps country names to flag emojis (🇸🇪 🇺🇦 🇮🇹)
// - Includes validation method isValidEurovisionEntry that checks year and country
// - Provides fallback mechanism for incorrect country names
// - Respects cultural sensitivities around contested territories
```

### Outcome: AI Response Parsing & Error Handling

**Highly Effective Prompts:**

1. **Robust JSON Parsing:**

```dart
// Create a resilient Eurovision AI response parser that:
// - Safely extracts JSON data from AI completions API response
// - Handles malformed JSON with clear error messages
// - Validates each song field before creating EurovisionSong objects
// - Filters out invalid entries (wrong years, countries)
// - Limits to 5-8 songs maximum for performance
// - Returns a clearly typed List<EurovisionSong> with null safety
```

2. **Comprehensive Fallback System:**

```dart
// Implement Eurovision fallback system with:
// - Pre-defined Eurovision songs for each mood category
// - At least 3 songs per mood from different decades/countries
// - Clear indication when falling back to predefined songs
// - Eurovision-themed error messages like "The AI jury is deliberating!"
// - Graceful degradation that never breaks the user experience
// - Logging for failed AI requests to improve future prompts
```

**Effective Prompts:**
1. "Write a JSON parser for converting GitHub Models API responses into EurovisionSong objects with error handling."
2. "Implement a fallback mechanism for when AI fails to generate valid Eurovision songs."
3. "Create a playlist generation algorithm that maps commit sentiments to appropriate Eurovision song categories."

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

## Advanced Prompt Engineering Techniques for GitVision

### 1. Context-Rich System Understanding

**Strategy**: Provide complete context about the GitVision app architecture.

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
```

### 2. Multi-Step Prompting
**Strategy**: Break complex tasks into sequential prompts for better results.

```
// Step 1: Create the data structure
Create a Dart class for Eurovision song recommendations that includes
validation for years (1956-2025) and proper country name handling.

// Step 2: Add parsing logic  
Add a factory constructor to parse JSON responses from GitHub Models API
with comprehensive error handling for malformed data.

// Step 3: Implement fallbacks
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

```
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

## General Tips for Effective Copilot Prompts

1. **Be Specific**: Include the programming language (Dart/Flutter) and file context.
2. **Include Requirements**: Mention error handling, validation, and specific features.
3. **Reference Standards**: Mention Flutter best practices and design patterns.
4. **Cultural Context**: Include Eurovision-specific requirements for accuracy and cultural sensitivity.
5. **Code Structure**: Indicate desired patterns (services, models, widgets).
6. **Think in Steps**: Break complex features into smaller, manageable prompts.
7. **Consider Edge Cases**: Explicitly mention error scenarios and boundary conditions.
8. **Maintain Context**: Reference existing code structure and naming conventions.

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
//    - Validates data against Eurovision rules (years 1956-2025, valid countries)
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

## Example of Highly Effective Actual Prompt

This optimized prompt style has been proven to produce high-quality GitVision code:

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

## Debugging Copilot Responses

When your GitVision prompts don't produce the expected results:

1. **Add Eurovision Context**: Include specific references to Eurovision themes and cultural requirements
2. **Use Code Comments Format**: Structure as `// Comment style` rather than natural language
3. **Be Extremely Specific**: Include exact method names, parameter types, and return values
4. **List All Edge Cases**: Explicitly mention all error scenarios that need handling
5. **Include Sample Data**: Provide examples of input/output formats
6. **Split Complex Features**: Break features into smaller components with clear dependencies
7. **Specify Cultural Requirements**: Include explicit cultural sensitivity guidance


