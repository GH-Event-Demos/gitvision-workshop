import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class SpotifyService {
  String? _accessToken;
  DateTime? _tokenExpiry;
  
  final _client = http.Client();

  void _debugLog(String message) {
    if (kDebugMode) {
      print('[SpotifyService] $message');
    }
  }

  Future<void> _authenticate() async {
    if (_accessToken != null && _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }

    final credentials = base64Encode(
      utf8.encode('${ApiConfig.spotifyClientId}:${ApiConfig.spotifyClientSecret}')
    );

    final response = await _client.post(
      Uri.parse(ApiConfig.spotifyAuthEndpoint),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiry = DateTime.now().add(
        Duration(seconds: data['expires_in'] as int)
      );
      _debugLog('Successfully authenticated with Spotify');
    } else {
      throw Exception('Failed to authenticate with Spotify');
    }
  }

  Future<List<Map<String, dynamic>>> searchTracks(String query) async {
    await _authenticate();

    final uri = Uri.parse('${ApiConfig.spotifyApiEndpoint}/search')
        .replace(queryParameters: {
      'q': query,
      'type': 'track',
      'market': 'US', // Changed from ES to US - better preview availability
      'limit': '50', // Increased limit to find more tracks with previews
    });

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'] as List;
      
      _debugLog('Found ${tracks.length} tracks for query: $query');
      
      final results = tracks.map((track) {
        final hasPreview = track['preview_url'] != null;
        _debugLog('Track: ${track['name']} - Preview: ${hasPreview ? track['preview_url'] : 'None'}');
        
        return {
          'id': track['id'],
          'title': track['name'],
          'artist': (track['artists'] as List).map((a) => a['name']).join(', '),
          'preview_url': track['preview_url'],
          'webPlayerUrl': track['external_urls']['spotify'],
          'imageUrl': track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : null,
          'isPlayable': track['preview_url'] != null,
        };
      }).toList();
      
      final withPreviews = results.where((track) => track['preview_url'] != null).length;
      _debugLog('Found $withPreviews tracks with previews out of ${results.length} total');
      
      return results;
    } else {
      _debugLog('Failed to search tracks: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}
