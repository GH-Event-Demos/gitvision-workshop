Key points about lib/models/:

Contains Dart classes for Eurovision songs, GitHub commits, Spotify tracks, etc.
Each model typically includes JSON serialization/deserialization for API integration.
Ensures type safety and clear data handling across services and UI.
Follows best practices for validation (e.g., Eurovision entry validation).
Used by services (API calls), providers (state), and widgets (UI display).
For example, a EurovisionSong model in this folder would define fields like title, artist, country, year, and validation logic, making it easy to work with Eurovision data throughout the app.