// Analysis data structure for sentiment results
class SentimentAnalysis {
  final int totalCommits;
  final Map<String, int> moodCounts;
  final int keywordCount;
  final DateTime timestamp;
  final bool isEurovisionThemed;

  static final Map<String, int> emptyMoodCounts = {
    'productive': 0,
    'debugging': 0,
    'creative': 0,
    'victory': 0,
    'reflective': 0,
  };

  const SentimentAnalysis._internal({
    required this.totalCommits,
    required this.moodCounts,
    required this.keywordCount,
    required this.timestamp,
    required this.isEurovisionThemed,
  });

  factory SentimentAnalysis({
    required int totalCommits,
    required Map<String, int> moodCounts,
    required int keywordCount,
    DateTime? timestamp,
    bool isEurovisionThemed = true,
  }) {
    return SentimentAnalysis._internal(
      totalCommits: totalCommits,
      moodCounts: Map.unmodifiable(moodCounts),
      keywordCount: keywordCount,
      timestamp: timestamp ?? DateTime.now(),
      isEurovisionThemed: isEurovisionThemed,
    );
  }

  // Default empty analysis
  static final empty = SentimentAnalysis(
    totalCommits: 0,
    moodCounts: Map.unmodifiable(emptyMoodCounts),
    keywordCount: 0,
    timestamp: DateTime.now(),
  );

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis._internal(
      totalCommits: json['total_commits'] as int,
      moodCounts: Map<String, int>.unmodifiable(
        Map<String, int>.from(json['mood_counts'] as Map)),
      keywordCount: json['keyword_count'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isEurovisionThemed: json['eurovision_themed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_commits': totalCommits,
    'mood_counts': moodCounts,
    'keyword_count': keywordCount,
    'timestamp': timestamp.toIso8601String(),
    'eurovision_themed': isEurovisionThemed,
  };
}
