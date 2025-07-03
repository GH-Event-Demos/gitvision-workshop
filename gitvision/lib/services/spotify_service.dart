import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/eurovision_song.dart';

/// Spotify Integration Service
class SpotifyService {
  String? _accessToken;
  final String _clientId;
  final String _clientSecret;
  DateTime? _tokenExpiry;

  SpotifyService({
    required String clientId,
    required String clientSecret,
  })  : _clientId = clientId,
        _clientSecret = clientSecret;

  /// Authenticate with Spotify using Client Credentials flow
  Future<void> authenticateSpotify() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        _tokenExpiry!.isAfter(DateTime.now())) {
      return;
    }
    await _getClientCredentialsToken();
  }

  Future<void> _getClientCredentialsToken() async {
    try {
      print(
          'DEBUG: Attempting to get Spotify token with Client ID: ${_clientId.substring(0, 4)}...');
      final String credentials =
          base64Encode(utf8.encode('$_clientId:$_clientSecret'));

      final response = await http
          .post(
            Uri.parse('https://accounts.spotify.com/api/token'),
            headers: {
              'Authorization': 'Basic $credentials',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'grant_type=client_credentials',
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry =
            DateTime.now().add(Duration(seconds: data['expires_in'] - 60));
        print('DEBUG: Successfully got Spotify token');
      } else {
        throw Exception(
            'Failed to authenticate with Spotify: ${response.statusCode}');
      }
    } catch (e) {
      print('Error authenticating with Spotify: $e');
      rethrow;
    }
  }

  /// Search for songs on Spotify and return enhanced data
  Future<List<Map<String, dynamic>>> searchSongsOnSpotify(
      List<EurovisionSong> songs) async {
    try {
      await authenticateSpotify();

      final queries =
          songs.map((song) => '${song.title} ${song.artist}').toList();
      return await searchTracks(queries);
    } catch (e) {
      print('Error searching songs on Spotify: $e');
      // Return offline data for each song
      return songs.map((song) => _createOfflineSongData(song.title)).toList();
    }
  }

  /// Search for tracks on Spotify
  /// Can accept either a single String query or a List<String> of queries
  Future<List<Map<String, dynamic>>> searchTracks(dynamic query) async {
    try {
      await authenticateSpotify();

      // Handle both String and List<String> inputs - safely cast List<dynamic> to List<String>
      final queries = query is String ? [query] : (query as List).cast<String>();
      print('DEBUG: Starting Spotify search for ${queries.length} queries');

      final List<Map<String, dynamic>> foundTracks = [];
      const int maxBatchSize = AppConstants.spotifyBatchSize; // Spotify recommends batching requests
      int retryCount = 0;
      const maxRetries = 3;

      for (int i = 0; i < queries.length; i += maxBatchSize) {
        final batch = queries.skip(i).take(maxBatchSize);
        print('DEBUG: Processing batch ${i ~/ maxBatchSize + 1}');

        try {
          final results = await Future.wait(batch.map((query) async {
            try {
              final trackData = await _searchSingleSong(query);
              return trackData ?? _createOfflineSongData(query);
            } catch (e) {
              print('DEBUG: Failed to find $query on Spotify: $e');
              return _createOfflineSongData(query);
            }
          }));
          foundTracks.addAll(results);
        } catch (e) {
          print('ERROR: Batch processing failed: $e');
          if (++retryCount < maxRetries) {
            print(
                'DEBUG: Retrying batch after error (attempt $retryCount of $maxRetries)');
            i -= maxBatchSize; // Retry this batch
            await Future.delayed(
                Duration(seconds: retryCount * 2)); // Exponential backoff
            continue;
          }
          // Add offline data for failed batch
          for (final query in batch) {
            foundTracks.add(_createOfflineSongData(query));
          }
        }

        // Respect rate limits
        if (i + maxBatchSize < queries.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      print('DEBUG: Search completed. Found ${foundTracks.length} tracks');
      return foundTracks;
    } catch (e) {
      print('Error in searchTracks: $e');
      if (query is String) {
        return [_createOfflineSongData(query)];
      }
      return (query as List).cast<String>()
          .map((q) => _createOfflineSongData(q))
          .toList();
    }
  }

  Map<String, dynamic> _createOfflineSongData(String query) => {
        'title': query,
        'artist': 'Unknown Artist',
        'preview_url': null,
        'imageUrl': 'https://ui-avatars.com/api/?name=Eurovision&size=300&background=2D46B9&color=fff',
        'external_urls': {'spotify': null},
        'album': {'images': []},
        'id': null,
        'uri': null,
        'isPlayable': false,
        'webPlayerUrl': null,
      };

  Future<Map<String, dynamic>?> _searchSingleSong(String queryString) async {
    try {
      // Search strategies in order of preference
      final searchStrategies = [
        queryString,
        '$queryString eurovision',
        '$queryString eurovision song contest',
      ];

      for (final searchQuery in searchStrategies) {
        final response = await _makeSpotifyRequest(
          'search',
          queryParameters: {
            'q': searchQuery,
            'type': 'track',
            'market': 'US',
            'limit': '10'
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final tracks = (data['tracks']?['items'] as List?) ?? [];

          if (tracks.isEmpty) continue;

          // First try to find a track with album art and preview
          final trackWithPreview = tracks.firstWhere(
            (track) =>
                track['preview_url'] != null &&
                track['album']?['images']?.isNotEmpty == true,
            orElse: () => tracks[0],
          );

          return _formatTrack(trackWithPreview,
              hasPreview: trackWithPreview['preview_url'] != null);
        }
      }

      return null;
    } catch (e) {
      print('ERROR in _searchSingleSong: $e');
      return null;
    }
  }

  Map<String, dynamic> _formatTrack(Map<String, dynamic> track,
      {required bool hasPreview}) {
    // Extract album image URL with proper null handling
    String? imageUrl;

    try {
      final albumImages = track['album']['images'] as List?;
      if (albumImages != null && albumImages.isNotEmpty) {
        final firstImage = albumImages[0];
        if (firstImage is Map && firstImage.containsKey('url')) {
          final url = firstImage['url'];
          if (url is String && url.isNotEmpty) {
            imageUrl = url;
            print('DEBUG: Successfully extracted image URL: $imageUrl');
          }
        }
      }
    } catch (e) {
      print('ERROR: Failed to extract album image URL: $e');
    }

    print(
        'DEBUG: Track from Spotify: ${track['name']} by ${track['artists'][0]['name']}');
    print('DEBUG: Album cover URL: $imageUrl');

    return {
      'title': track['name'],
      'artist': track['artists'][0]['name'],
      'preview_url': track['preview_url'],
      'imageUrl': imageUrl,
      'external_urls': track['external_urls'],
      'album': track['album'],
      'id': track['id'],
      'uri': track['uri'],
      'isPlayable': hasPreview,
      'webPlayerUrl': track['external_urls']['spotify'],
    };
  }

  Future<http.Response> _makeSpotifyRequest(String endpoint,
      {Map<String, String>? queryParameters}) async {
    await authenticateSpotify();

    final uri = Uri.https('api.spotify.com', 'v1/$endpoint', queryParameters);

    return await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));
  }

  bool _isLikelyMatch(String trackName, String artistName, String query) {
    final queryLower = query
        .toLowerCase()
        .replaceAll('eurovision', '')
        .replaceAll('esc', '')
        .trim();
    final trackLower = trackName.toLowerCase();
    final artistLower = artistName.toLowerCase();

    // Handle artist - song format
    final queryParts = queryLower.split(' - ');
    if (queryParts.length == 2) {
      final queryArtist = queryParts[0].trim();
      final queryTrack = queryParts[1].trim();
      if ((trackLower.contains(queryTrack) ||
              queryTrack.contains(trackLower)) &&
          (artistLower.contains(queryArtist) ||
              queryArtist.contains(artistLower))) {
        return true;
      }
    }

    // Handle variations in artist names (e.g., "Loreen" vs "Loreen Talhaoui")
    if ((trackLower.contains(queryLower) || queryLower.contains(trackLower)) &&
        (artistLower.split(' ').any((part) => queryLower.contains(part)) ||
            queryLower.split(' ').any((part) => artistLower.contains(part)))) {
      return true;
    }

    // Fall back to simple matching
    final cleanQueryParts = queryLower.split(' ')
      ..removeWhere((part) => part.length < 3); // Remove very short words
    return cleanQueryParts.any((part) => trackLower.contains(part)) &&
        cleanQueryParts.any((part) => artistLower.contains(part));
  }
}
