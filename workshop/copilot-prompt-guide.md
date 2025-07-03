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

### Outcome: GitHub API Authentication

**Effective Prompts:**
1. "Implement a Flutter service to fetch GitHub commit history for a username using the GitHub API with proper error handling and rate limit management."
2. "Write a Dart function that extracts relevant information from GitHub commit API responses, including message, date, and author."
3. "Create a pagination mechanism for GitHub API to handle repositories with many commits, implementing the Link header parsing."

### Outcome: Repository Analysis

**Effective Prompts:**
1. "Create a repository analyzer in Dart that can process GitHub API responses and extract meaningful commit patterns."
2. "Implement a function to filter out merge commits and automated messages from GitHub commit history."
3. "Build a data structure to organize commit messages by author, date, and content for analysis."

### Outcome: Commit Data Extraction

**Effective Prompts:**
1. "Create a sentiment analyzer in Dart that maps coding-related keywords to Eurovision moods (productive, debugging, experimental, breakthrough, reflective)."
2. "Implement a scoring algorithm that evaluates commit messages to detect the dominant coding mood."
3. "Write a function that extracts keywords from commit messages and classifies them into Eurovision-themed sentiment categories."

### Outcome: Error Handling

**Effective Prompts:**
1. "Implement comprehensive error handling for GitHub API in Flutter, including rate limits, network failures, and authentication issues."
2. "Create user-friendly error messages for GitHub API failures with Eurovision-themed messaging."
3. "Write exponential backoff retry logic for GitHub API rate limit handling."

## Phase 3: AI Eurovision Magic

### Outcome: Models API Implementation

**Effective Prompts:**
1. "Create a Dart service to call GitHub Models API with proper authentication and error handling."
2. "Implement an AI prompt generator that creates effective prompts for Eurovision song recommendations based on commit sentiment."
3. "Write a function to parse and validate AI responses containing Eurovision song suggestions."

### Outcome: Song Matching

**Effective Prompts:**
1. "Create a EurovisionSong data model in Dart with fields for title, artist, country, year, and reasoning with proper validation."
2. "Implement validation logic for Eurovision songs ensuring years are between 1956-2025 and country names are valid."
3. "Add country flag emoji mapping for Eurovision countries, handling historical country name changes appropriately."

### Outcome: Playlist Generation

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

## Advanced Prompt Engineering Techniques

### 1. Context-Aware Prompting
**Strategy**: Provide context about the entire system to get more coherent code.

```
// In the context of a Flutter Eurovision app that analyzes GitHub commits
// and generates playlists using AI, create a robust error handling system
// that maintains the Eurovision theme while providing actionable feedback.
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

## Example Complete Prompt

```
Create a Flutter service class called SpotifyService that:
1. Implements client credentials authentication with Spotify Web API (no OAuth)
2. Securely stores and manages access tokens
3. Provides methods to search for Eurovision songs by title and artist
4. Handles missing songs gracefully with appropriate user feedback
5. Implements comprehensive error handling with Eurovision-themed messages
6. Follows Flutter best practices for async operations
7. Includes appropriate documentation

The service should fit within our existing GitVision architecture and respect
Eurovision cultural values with appropriate country naming.
```

## Debugging Copilot Responses

When Copilot generates unexpected results:

1. **Refine Context**: Add more specific domain context
2. **Break Down Tasks**: Split complex prompts into smaller steps
3. **Add Examples**: Provide concrete input/output examples
4. **Specify Constraints**: Be explicit about requirements and limitations
5. **Iterate Gradually**: Build up complexity through multiple prompts


