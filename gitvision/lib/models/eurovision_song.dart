class EurovisionSong {
  final String title;
  final String artist;
  final String country;
  final int year;
  final String? spotifyUrl;
  final String? previewUrl;
  final String mood;
  final double energy;
  final double valence;

  EurovisionSong({
    required this.title,
    required this.artist,
    required this.country,
    required this.year,
    this.spotifyUrl,
    this.previewUrl,
    required this.mood,
    required this.energy,
    required this.valence,
  });

  factory EurovisionSong.fromJson(Map<String, dynamic> json) {
    return EurovisionSong(
      title: json['title'] as String,
      artist: json['artist'] as String,
      country: json['country'] as String,
      year: json['year'] as int,
      spotifyUrl: json['spotify_url'] as String?,
      previewUrl: json['preview_url'] as String?,
      mood: json['mood'] as String,
      energy: (json['energy'] as num).toDouble(),
      valence: (json['valence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'country': country,
      'year': year,
      'spotify_url': spotifyUrl,
      'preview_url': previewUrl,
      'mood': mood,
      'energy': energy,
      'valence': valence,
    };
  }
}