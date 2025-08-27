# GitVision: Eurovision Edition

## Project Overview

GitVision is a Flutter application that transforms GitHub commit messages into AI-curated Eurovision playlists. The app analyzes a developer's coding patterns and mood through their commit history, then uses AI to recommend Eurovision songs that match their coding "vibe".

## Core Features

### Phase 1: GitHub Integration
- GitHub handle input and validation
- Fetch up to 50 recent public commit messages
- Basic sentiment analysis of commit patterns
- Error handling for invalid handles and API failures

### Phase 2: AI Eurovision Magic
- Integration with GitHub Models API
- AI-powered Eurovision song recommendations based on commit sentiment
- Structured parsing of AI responses into Eurovision song data
- Cultural sensitivity and Eurovision context awareness

### Phase 3: Spotify Integration
- Spotify OAuth authentication
- Search for Eurovision songs on Spotify
- Create playable playlists
- Handle missing tracks and provide fallbacks

## Technical Stack

- **Flutter 3.7+** for cross-platform development
- **GitHub API** for commit data retrieval
- **GitHub Models API** for AI-powered recommendations
- **Spotify Web API** for playlist creation and playback
- **HTTP package** for API communications

## Cultural Context

The app celebrates Eurovision's diversity by:
- Using accurate country names and flag emojis
- Handling historical changes (Yugoslavia → Serbia, etc.)
- Respecting Eurovision's inclusion values
- Mapping coding moods to Eurovision musical styles

## Mood-to-Eurovision Mapping

| Commit Mood | Eurovision Style | Example |
|-------------|------------------|---------|
| **Productive/Flow** | Upbeat anthems | "Euphoria" (Sweden 2012) 🇸🇪 |
| **Debugging/Intense** | Power ballads | "Rise Like a Phoenix" (Austria 2014) 🇦🇹 |
| **Creative/Experimental** | Unique entries | "Shum" (Ukraine 2021) 🇺🇦 |
| **Victory/Breakthrough** | Winners | "Waterloo" (ABBA 1974) 🇸🇪 |
| **Reflective/Cleanup** | Emotional songs | "1944" (Ukraine 2016) 🇺🇦 |

## Workshop Context

This is designed as a 2-hour workshop covering:
- Flutter development best practices
- Multi-API integration patterns
- AI service integration
- Error handling and user experience
- Cultural sensitivity in software development

## Success Criteria

By the end of implementation:
- ✅ Fetches and analyzes GitHub commit history
- ✅ Generates AI-powered Eurovision recommendations
- ✅ Creates playable Spotify playlists
- ✅ Handles all error cases gracefully
- ✅ Provides culturally sensitive Eurovision content</content>
<parameter name="filePath">/Users/alacolombiadev/Documents/code/gitvision-workshop/docs/idea.md