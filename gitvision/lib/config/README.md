The lib/config/ folder in your GitVision codebase is responsible for storing configuration files and classes that manage app-wide settings and sensitive information.

Key roles of lib/config/:

Stores API token definitions (e.g., api_tokens.dart, which is git-ignored for security).
Contains configuration classes like ApiConfig that centralize API endpoints, token access, and validation logic.
Provides a single source of truth for credentials and endpoints used by services (GitHub, Spotify, etc.).
Ensures sensitive data is separated from the main codebase and never hardcoded elsewhere.
May include example files (e.g., api_tokens.example.dart) to guide setup without exposing secrets.
This structure supports secure, maintainable, and scalable management of external service integrations.