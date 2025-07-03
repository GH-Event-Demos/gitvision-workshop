// Eurovision song data model with Spotify integration
import 'coding_mood.dart';
import '../services/logging_service.dart';

class EurovisionSong {
  final String title;
  final String artist;
  final String country;
  final int year;
  final CodingMood? mood;
  final String? reasoning;
  final String? spotifyUrl;
  final String? previewUrl;
  final String? imageUrl;

  const EurovisionSong({
    required this.title,
    required this.artist,
    required this.country,
    required this.year,
    this.mood,
    this.reasoning,
    this.spotifyUrl,
    this.previewUrl,
    this.imageUrl,
  });

  // Indicates if the song can be played on Spotify
  bool get isPlayable => spotifyUrl != null && (spotifyUrl?.isNotEmpty ?? false);

  // Indicates if the song has a preview available
  bool get hasPreview => previewUrl != null && (previewUrl?.isNotEmpty ?? false);

  // Create a EurovisionSong from JSON data, with fallback values if data is missing
  factory EurovisionSong.fromJson(Map<String, dynamic> json) {
    try {
      // Process and validate the imageUrl
      String? imageUrl;
      if (json['imageUrl'] != null) {
        if (json['imageUrl'] is String && json['imageUrl'].toString().isNotEmpty) {
          imageUrl = json['imageUrl'];
          print('DEBUG: EurovisionSong has imageUrl: $imageUrl');
        } else {
          print('DEBUG: EurovisionSong imageUrl is not a valid string: ${json['imageUrl']}');
        }
      } else if (json['album'] != null && json['album']['images'] != null && json['album']['images'].isNotEmpty) {
        final images = json['album']['images'] as List;
        if (images.isNotEmpty && images.first['url'] != null) {
          imageUrl = images.first['url'];
          print('DEBUG: EurovisionSong extracted album imageUrl: $imageUrl');
        }
      } else {
        print('DEBUG: EurovisionSong has no imageUrl or album images');
      }
      
      final song = EurovisionSong(
        title: json['title'] as String? ?? defaultSong.title,
        artist: json['artist'] as String? ?? defaultSong.artist,
        country: json['country'] as String? ?? defaultSong.country,
        year: (json['year'] as num?)?.toInt() ?? defaultSong.year,
        mood: json['mood'] != null ? CodingMood.fromString(json['mood'] as String) : null,
        reasoning: json['reasoning'] as String?,
        spotifyUrl: json['webPlayerUrl'] as String? ?? json['spotifyUrl'] as String?,
        previewUrl: json['preview_url'] as String? ?? json['previewUrl'] as String?,
        imageUrl: imageUrl,
      );
      
      print('DEBUG: Created EurovisionSong: ${song.title} with imageUrl: ${song.imageUrl}');
      return song;
    } catch (e) {
      LoggingService().error('Error parsing Eurovision song', e);
      return defaultSong;
    }
  }

  // Convert a Spotify track to EurovisionSong
  factory EurovisionSong.fromSpotifyTrack(Map<String, dynamic> track, {
    String? country,
    int? year,
    CodingMood? mood,
    String? reasoning,
  }) {
    return EurovisionSong(
      title: track['name'] as String? ?? 'Unknown Song',
      artist: (track['artists'] as List<dynamic>?)?.isNotEmpty == true
          ? (track['artists']![0]['name'] as String?) ?? 'Unknown Artist'
          : 'Unknown Artist',
      country: country ?? 'Unknown',
      year: year ?? DateTime.now().year,
      mood: mood,
      reasoning: reasoning,
      spotifyUrl: (track['external_urls'] as Map<String, dynamic>?)?.containsKey('spotify') == true
          ? track['external_urls']!['spotify'] as String?
          : null,
      previewUrl: track['preview_url'] as String?,
      imageUrl: (track['album'] as Map<String, dynamic>?)?.containsKey('images') == true
          ? ((track['album']!['images'] as List<dynamic>?)?.isNotEmpty == true
              ? (track['album']!['images']![0] as Map<String, dynamic>?)?.containsKey('url') == true
                  ? track['album']!['images']![0]['url'] as String?
                  : null
              : null)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    'country': country,
    'year': year,
    'mood': mood?.name,
    'reasoning': reasoning,
    'webPlayerUrl': spotifyUrl,
    'preview_url': previewUrl,
    'imageUrl': imageUrl,
    'isPlayable': isPlayable,
  };

  // Create a map in the format expected by the playlist widget
  Map<String, dynamic> toPlaylistFormat() => {
    'title': title,
    'artist': artist,
    'country': country,
    'year': year,
    'reasoning': reasoning ?? 'A classic Eurovision song',
    'isPlayable': isPlayable,
    'webPlayerUrl': spotifyUrl,
    'preview_url': previewUrl,
    'imageUrl': imageUrl, // Pass through as null if not available
    'mood': mood?.name,
    'duration_ms': 30000, // Default 30s for previews
    'hasPreview': hasPreview,
  };

  // Default song for error cases
  static const defaultSong = EurovisionSong(
    title: 'Dancing Lasha Tumbai',
    artist: 'Verka Serduchka',
    country: 'Ukraine',
    year: 2007, // A memorable Eurovision performance
    reasoning: 'Default Eurovision song - Dancing Lasha Tumbai (2007) 🇺🇦',
  );

  // Convert a list of Maps to EurovisionSongs
  static List<EurovisionSong> fromJsonList(List<dynamic> jsonList) {
    try {
      return jsonList
          .map((json) => EurovisionSong.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggingService().error('Error parsing Eurovision song list', e);
      return [defaultSong];
    }
  }

  // Create a copy of this song with updated fields
  EurovisionSong copyWith({
    String? title,
    String? artist,
    String? country,
    int? year,
    CodingMood? mood,
    String? reasoning,
    String? spotifyUrl,
    String? previewUrl,
    String? imageUrl,
  }) {
    return EurovisionSong(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      country: country ?? this.country,
      year: year ?? this.year,
      mood: mood ?? this.mood,
      reasoning: reasoning ?? this.reasoning,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() => '$title by $artist ($country, $year)';
}