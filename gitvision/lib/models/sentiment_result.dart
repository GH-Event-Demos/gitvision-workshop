// Data structure for sentiment analysis results with Eurovision integration
import 'eurovision_song.dart';
import 'coding_mood.dart';
import 'sentiment_analysis.dart';

/// Result from analyzing commit messages for coding mood
class SentimentResult {
  final CodingMood mood;
  final double confidence;
  final List<String> keywords;
  final String reasoning;
  final SentimentAnalysis analysis;

  const SentimentResult({
    required this.mood,
    required this.confidence,
    required this.keywords,
    required this.reasoning,
    required this.analysis,
  });

  factory SentimentResult.fromCommitMessages(List<String> commitMessages) {
    if (commitMessages.isEmpty) {
      return SentimentResult(
        mood: CodingMood.productive,
        confidence: 0.5,
        keywords: const [],
        reasoning: 'No commits to analyze',
        analysis: SentimentAnalysis.empty,
      );
    }

    // Initialize mood counters
    final moodCounts = Map<String, int>.from(SentimentAnalysis.emptyMoodCounts);

    // Initialize keyword collections
    final Set<String> detectedKeywords = {};

    // Define mood keywords (Eurovision-themed)
    final Map<CodingMood, List<String>> moodKeywords = {
      CodingMood.productive: ['add', 'implement', 'create', 'feature', 'update', 'support'],
      CodingMood.debugging: ['fix', 'bug', 'issue', 'error', 'crash', 'debug'],
      CodingMood.creative: ['design', 'style', 'ui', 'animation', 'theme', 'experiment'],
      CodingMood.victory: ['release', 'deploy', 'complete', 'milestone', 'ship'],
      CodingMood.reflective: ['refactor', 'cleanup', 'organize', 'document', 'improve'],
    };

    // Analyze each commit message
    for (final message in commitMessages) {
      final lowerMessage = message.toLowerCase();

      // Check each mood's keywords
      moodKeywords.forEach((mood, keywords) {
        for (final keyword in keywords) {
          if (lowerMessage.contains(keyword)) {
            moodCounts[mood.name] = (moodCounts[mood.name] ?? 0) + 1;
            detectedKeywords.add(keyword);
          }
        }
      });
    }

    // Find the dominant mood
    CodingMood dominantMood = CodingMood.productive;
    int maxCount = 0;

    moodCounts.forEach((moodStr, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = CodingMood.fromString(moodStr);
      }
    });

    // Calculate confidence based on keyword matches
    final totalCommits = commitMessages.length;
    final confidence = maxCount > 0
        ? (maxCount / totalCommits).clamp(0.0, 1.0)
        : 0.5;

    return SentimentResult(
      mood: dominantMood,
      confidence: confidence,
      keywords: detectedKeywords.take(5).toList(),
      reasoning: _generateReasoning(dominantMood, confidence),
      analysis: SentimentAnalysis(
        totalCommits: totalCommits,
        moodCounts: moodCounts,
        keywordCount: detectedKeywords.length,
      ),
    );
  }

  factory SentimentResult.fromJson(Map<String, dynamic> json) {
    return SentimentResult(
      mood: CodingMood.fromJson(json['mood'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      keywords: List<String>.from(json['keywords'] as List),
      reasoning: json['reasoning'] as String,
      analysis: SentimentAnalysis.fromJson(
        Map<String, dynamic>.from(json['analysis'] as Map)),
    );
  }

  static String _generateReasoning(CodingMood mood, double confidence) {
    final confidenceDesc = confidence > 0.8
        ? 'strong'
        : confidence > 0.5
            ? 'moderate'
            : 'mild';

    return '${mood.description} with $confidenceDesc confidence';
  }

  Map<String, dynamic> toJson() => {
    'mood': mood.toJson(),
    'confidence': confidence,
    'keywords': keywords,
    'reasoning': reasoning,
    'analysis': analysis.toJson(),
  };

  @override
  String toString() => 'Mood: ${mood.name} (${(confidence * 100).toStringAsFixed(0)}% confidence)';
}