import 'dart:math';

// Provides keywords and recommendations for each coding mood
class CodingMoodData {
  static const Map<String, List<String>> keywords = {
    'productive': ['add', 'implement', 'create', 'feature', 'support', 'improve', 'enhance', 'optimize', 'update'],
    'debugging': ['fix', 'bug', 'issue', 'error', 'crash', 'problem', 'critical', 'urgent', 'hotfix', 'patch'],
    'creative': ['design', 'style', 'ui', 'ux', 'interface', 'animation', 'visual', 'layout', 'theme', 'experiment'],
    'victory': ['release', 'version', 'deploy', 'launch', 'publish', 'finalize', 'complete', 'milestone', 'ship'],
    'reflective': ['refactor', 'cleanup', 'simplify', 'restructure', 'organize', 'document', 'comment', 'review'],
  };

  static const Map<String, List<String>> songRecommendations = {
    'productive': [
      "Euphoria (Sweden 2012) 🇸🇪",
      "Fuego (Cyprus 2018) 🇨🇾",
      "Heroes (Sweden 2015) 🇸🇪",
      "City Lights (Belgium 2017) 🇧🇪",
      "Shum (Ukraine 2021) 🇺🇦"
    ],
    'debugging': [
      "Rise Like a Phoenix (Austria 2014) 🇦🇹",
      "1944 (Ukraine 2016) 🇺🇦",
      "Zitti e buoni (Italy 2021) 🇮🇹",
      "Hard Rock Hallelujah (Finland 2006) 🇫🇮",
      "Arcade (Netherlands 2019) 🇳🇱"
    ],
    'creative': [
      "Toy (Israel 2018) 🇮🇱",
      "Dancing Lasha Tumbai (Ukraine 2007) 🇺🇦",
      "Spirit in the Sky (Norway 2019) 🇳🇴",
      "Love Love Peace Peace (Sweden 2016) 🇸🇪",
      "Think About Things (Iceland 2020) 🇮🇸"
    ],
    'victory': [
      "Waterloo (Sweden 1974) 🇸🇪",
      "Love Shine a Light (UK 1997) 🇬🇧",
      "Making Your Mind Up (UK 1981) 🇬🇧",
      "Take Me to Your Heaven (Sweden 1999) 🇸🇪",
      "Wild Dances (Ukraine 2004) 🇺🇦"
    ],
    'reflective': [
      "Amar pelos dois (Portugal 2017) 🇵🇹",
      "Calm After the Storm (Netherlands 2014) 🇳🇱",
      "Nocturne (Norway 1995) 🇳🇴",
      "Mercy (France 2018) 🇫🇷",
      "Soldi (Italy 2019) 🇮🇹"
    ],
  };

  static List<String> getRecommendations(String mood, {int count = 3}) {
    final songs = songRecommendations[mood.toLowerCase()] ?? songRecommendations['productive']!;
    if (count >= songs.length) return List.from(songs);

    final random = Random();
    final selected = <String>{};
    while (selected.length < count) {
      selected.add(songs[random.nextInt(songs.length)]);
    }
    return selected.toList();
  }
}
