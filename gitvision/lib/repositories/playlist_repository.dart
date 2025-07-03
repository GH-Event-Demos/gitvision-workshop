import '../models/eurovision_song.dart';
import '../models/coding_mood.dart';
import '../services/playlist_generator.dart';
import '../services/spotify_service.dart';
import '../services/logging_service.dart';

class PlaylistRepository {
  final PlaylistGenerator _playlistGenerator;
  final SpotifyService _spotifyService;
  final LoggingService _logger;

  PlaylistRepository({
    required PlaylistGenerator playlistGenerator,
    required SpotifyService spotifyService,
    required LoggingService logger,
  }) : _playlistGenerator = playlistGenerator,
       _spotifyService = spotifyService,
       _logger = logger;

  /// Generate a playlist based on git commit data
  Future<PlaylistResult> generatePlaylist(List<Map<String, dynamic>> commitData) async {
    try {
      _logger.debug('Generating playlist from ${commitData.length} commits');
      
      final result = await _playlistGenerator.generatePlayablePlaylist(commitData);
      final playlist = List<Map<String, dynamic>>.from(result['songs']);
      
      _logger.logPlaylistGeneration('Generated ${playlist.length} songs from GitHub Models AI');
      
      // Debug imageUrl values
      for (int i = 0; i < playlist.length; i++) {
        final song = playlist[i];
        _logger.debug('Song $i: ${song['title']} - imageUrl: ${song['imageUrl']}');
      }
      
      return PlaylistResult.success(
        playlist: playlist,
        mood: CodingMood.fromString(result['mood'] ?? 'productive'),
        analysis: result['fullAnalysis'] as String?,
        stats: result['stats'] as Map<String, dynamic>?,
      );
    } catch (error, stackTrace) {
      _logger.error('Failed to generate playlist', error, stackTrace);
      return PlaylistResult.error(error.toString());
    }
  }

  /// Search for a specific song on Spotify
  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    try {
      return await _spotifyService.searchTracks(query);
    } catch (error) {
      _logger.error('Failed to search songs', error);
      return [];
    }
  }

  /// Get enhanced song data with Spotify information
  Future<Map<String, dynamic>?> enhanceSong(EurovisionSong song) async {
    try {
      final searchQuery = '${song.title} ${song.artist}';
      final results = await searchSongs(searchQuery);
      
      if (results.isNotEmpty) {
        final spotifyTrack = results.first;
        return {
          ...song.toJson(),
          'imageUrl': spotifyTrack['imageUrl'],
          'preview_url': spotifyTrack['preview_url'],
          'webPlayerUrl': spotifyTrack['webPlayerUrl'],
          'spotifyId': spotifyTrack['id'],
        };
      }
      
      return song.toJson();
    } catch (error) {
      _logger.error('Failed to enhance song: ${song.title}', error);
      return song.toJson();
    }
  }
}

/// Result wrapper for playlist generation
class PlaylistResult {
  final List<Map<String, dynamic>>? playlist;
  final CodingMood? mood;
  final String? analysis;
  final Map<String, dynamic>? stats;
  final String? error;
  final bool isSuccess;

  const PlaylistResult._({
    this.playlist,
    this.mood,
    this.analysis,
    this.stats,
    this.error,
    required this.isSuccess,
  });

  factory PlaylistResult.success({
    required List<Map<String, dynamic>> playlist,
    required CodingMood mood,
    String? analysis,
    Map<String, dynamic>? stats,
  }) {
    return PlaylistResult._(
      playlist: playlist,
      mood: mood,
      analysis: analysis,
      stats: stats,
      isSuccess: true,
    );
  }

  factory PlaylistResult.error(String error) {
    return PlaylistResult._(
      error: error,
      isSuccess: false,
    );
  }
}