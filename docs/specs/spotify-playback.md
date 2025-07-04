# Feature Spec: Spotify Eurovision Playlist Integration

## Objective
Enable users to create real Spotify playlists with AI-curated Eurovision songs, creating a seamless experience from GitHub commit analysis to Eurovision music discovery and playlist sharing.

---

## Step 1: Spotify Authentication
**Objective:** Set up Spotify authentication to allow users to connect their Spotify accounts.
**Steps:**
- Implement Spotify OAuth flow
- Create a "Connect to Spotify" button
- Store authentication tokens securely
- Handle authentication errors gracefully

**Pseudocode:**
```
function connectToSpotify():
    initiate OAuth flow with Spotify API
    if successful:
        store accessToken and refreshToken
        updateUI(isConnected: true)
    else:
        showError('Could not connect to Spotify')

function refreshTokenIfNeeded():
    if tokenExpired:
        use refreshToken to get new accessToken
        if error:
            promptUserToReconnect()
```

**User Intervention:**
- User needs to log in to their Spotify account and grant permissions
- User must have a Spotify account (free or premium) to use this feature

---

## Step 2: Eurovision Song Search and Selection
**Objective:** Search for and identify AI-curated Eurovision songs on Spotify.
**Steps:**
- Create a service to translate Eurovision song metadata to Spotify track IDs
- Search Spotify API for Eurovision songs with fuzzy matching (artist variations, year differences)
- Handle cases where Eurovision songs might not be available on Spotify
- Implement fallback strategies for missing Eurovision tracks

**Pseudocode:**
```
function getEurovisionSpotifyTracks(eurovisionSongs):
    spotifyTracks = []
    for song in eurovisionSongs:
        query = "track:" + song.title + " artist:" + song.artist
        results = searchSpotify(query)
        if results.hasTrack:
            spotifyTracks.add(results.firstTrack)
        else:
            // Try alternative search strategies
            alternativeResults = searchWithFuzzyMatching(song)
            spotifyTracks.add(alternativeResults or fallbackEurovisionTrack)
    return spotifyTracks
```

**User Intervention:**
- None

---

## Step 3: Eurovision Playlist Creation UI
**Objective:** Create an intuitive interface for Eurovision playlist creation and management.
**Steps:**
- Design Eurovision-themed playlist creation interface
- Add playlist naming with coding vibe context
- Show Eurovision songs with country flags and years
- Add playlist sharing and external link functionality
- Support playlist description with AI-generated reasoning

**Pseudocode:**
```
UI:
    Container: playlistCreationWidget
        Text: "Your Eurovision Coding Vibe: [detectedMood]"
        TextField: playlistName (auto-generated with coding theme)
        EurovisionSongList:
            for each song:
                Card:
                    Image: countryFlag
                    Text: songTitle, artist, year, country
                    Text: aiReasoningForSelection
        Button: "Create Spotify Playlist"
        Button: "Share Eurovision Playlist"
        
function updatePlaylistUI(eurovisionSongs, mood):
    update song cards with Eurovision metadata and AI reasoning
```

**User Intervention:**
- User can customize playlist name and decide whether to create the playlist

---

## Step 4: Spotify Playlist Creation Implementation
**Objective:** Implement actual Eurovision playlist creation on Spotify.
**Steps:**
- Create new playlist on user's Spotify account
- Add Eurovision tracks to the created playlist
- Set playlist metadata (name, description with coding context)
- Handle API rate limits and Eurovision song availability issues
- Return shareable playlist URL

**Pseudocode:**
```
function createEurovisionPlaylist(spotifyTracks, playlistName, codingMood):
    playlist = createSpotifyPlaylist(
        name: playlistName,
        description: "Eurovision songs matching my coding vibe: " + codingMood,
        public: true
    )
    
    addTracksToPlaylist(playlist.id, spotifyTracks)
    
    return playlist.externalUrl

function addTracksToPlaylist(playlistId, tracks):
    for track in tracks:
        if track.isAvailable:
            addTrackToPlaylist(playlistId, track.uri)
        else:
            logMissingEurovisionSong(track)
```

**User Intervention:**
- User grants permission for playlist creation
- User can choose to make playlist public or private

---

## Step 5: Handling Eurovision-Specific Edge Cases
**Objective:** Ensure the feature works well for Eurovision content and various user scenarios.
**Steps:**
- Handle Eurovision songs not available on Spotify (common for older entries)
- Provide alternative Eurovision tracks when originals aren't found
- Support different Eurovision artist name variations (national vs. international)
- Handle songs from countries that no longer exist or have changed names
- Graceful fallbacks for incomplete Eurovision metadata

**Pseudocode:**
```
function handleEurovisionEdgeCases(eurovisionSong):
    if !foundOnSpotify(eurovisionSong):
        alternatives = searchEurovisionAlternatives(eurovisionSong)
        if alternatives.hasResults:
            return alternatives.firstMatch
        else:
            return fallbackEurovisionTrack(eurovisionSong.year, eurovisionSong.mood)

function searchEurovisionAlternatives(song):
    // Try different search strategies
    alternatives = [
        searchByYearAndCountry(song.year, song.country),
        searchByArtistVariations(song.artist),
        searchBySimilarEurovisionMood(song.mood, song.year)
    ]
    return alternatives.firstAvailable

function handleCountryNameChanges(countryName):
    countryMapping = {
        'Yugoslavia': ['Serbia', 'Croatia', 'Bosnia', 'Montenegro'],
        'Soviet Union': ['Russia'],
        'East Germany': ['Germany']
    }
    return countryMapping[countryName] or countryName
```

**User Intervention:**
- Users are informed when original Eurovision songs aren't available
- Users can choose to accept alternative Eurovision tracks or skip unavailable songs

---

This spec covers the implementation of Spotify integration for creating Eurovision playlists based on AI-analyzed GitHub commit sentiment. It addresses authentication, Eurovision song search challenges, playlist creation, and Eurovision-specific edge cases to ensure a culturally authentic and smooth user experience.
