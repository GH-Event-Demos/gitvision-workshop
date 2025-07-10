# GitVision 🎤✨

Eurovision-themed GitHub Commit Mood Analyzer & AI-Powered Spotify Playlist Generator

---

## Overview

GitVision is a cross-platform Flutter app that analyzes your GitHub commit history, detects your coding mood, and generates a custom Eurovision-inspired Spotify playlist using AI. It celebrates European music diversity and bridges technology with culture, making coding more fun and interactive!

## Features

- **Commit Mood Analysis:** Uses AI to analyze your GitHub commit messages and infer your current coding mood (e.g., productive, intense, creative).
- **Eurovision Song Curation:** Maps moods to Eurovision songs (1956–2025), respecting cultural diversity and historical changes.
- **AI-Powered Playlists:** Integrates with GitHub Models API to suggest Eurovision songs, providing reasoning for each choice.
- **Spotify Integration:** Authenticates with Spotify and creates playlists matching your coding vibe.
- **Cultural Sensitivity:** Handles country names, flags, and Eurovision history with care and inclusivity.
- **Workshop Ready:** Designed for learning, with clear debug output, educational comments, and mock/demo modes.

## Tech Stack

- **Flutter 3.7+** (cross-platform mobile & desktop)
- **Provider/Riverpod** for state management
- **GitHub API** for commit data
- **GitHub Models API** for AI song curation
- **Spotify Web API** for playlist creation
- **HTTP** package for RESTful API calls

## Project Structure

```
lib/
  config/      # API tokens & config (never hardcoded)
  models/      # Data classes (EurovisionSong, SentimentResult, etc.)
  services/    # API integrations (github_service, ai_playlist_service, spotify_service)
  widgets/     # Reusable UI components
  screens/     # Main app screens
```

## Security & API Best Practices

- **Never hardcode tokens.** Use `lib/config/api_tokens.dart` (git-ignored).
- Handle API errors, rate limits, and provide user-friendly messages.
- Respect user privacy and data security.

## Eurovision Cultural Guidelines

- Use accurate country names and flag emojis (🇸🇪 🇮🇹 🇺🇦)
- Handle historical changes (e.g., Yugoslavia → Serbia)
- Avoid stereotypes; celebrate diversity and inclusion

## Example: Mood-to-Eurovision Mapping

| Coding Mood         | Eurovision Song Example         |
|---------------------|--------------------------------|
| Productive/Flow     | Euphoria, Fuego, Heroes        |
| Debugging/Intense   | Rise Like a Phoenix, 1944      |
| Creative/Experimental | Shum, Epic Sax Guy           |
| Victory/Breakthrough | Waterloo, Love Shine a Light  |
| Reflective/Cleanup  | Arcade, Soldi                  |

## Getting Started

1. **Clone the repo:**
	```sh
	git clone https://github.com/GH-Event-Demos/gitvision-workshop.git
	cd gitvision-workshop/gitvision
	```
2. **Install dependencies:**
	```sh
	flutter pub get
	```
3. **Configure API tokens:**
	- Copy `lib/config/api_tokens.example.dart` to `lib/config/api_tokens.dart` and add your tokens.
4. **Run the app:**
	```sh
	flutter run
	```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

MIT License. See [LICENSE](../LICENSE) for details.

---

✨ GitVision: Where code meets Eurovision! 🇪🇺🎵
