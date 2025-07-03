import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sentiment_result.dart';
import '../models/coding_mood.dart';
import '../models/sentiment_analysis.dart';
import '../models/coding_mood_data.dart';

/// 🎵 GitVision Sentiment Analysis Service
/// Analyzes commit messages and matches them to Eurovision song moods
class SentimentService {
  final String? _githubToken;

  SentimentService({String? githubToken}) : _githubToken = githubToken;

  /// Analyze commit messages and determine the coding mood
  Future<SentimentResult> analyzeCommitSentiment(
      List<String> commitMessages) async {
    if (commitMessages.isEmpty) {
      return SentimentResult(
        mood: CodingMood.productive,
        confidence: 0.5,
        keywords: const [],
        reasoning: 'No commits to analyze',
        analysis: SentimentAnalysis.empty,
      );
    }

    try {
      if (_githubToken != null && _githubToken!.isNotEmpty) {
        return await _analyzeWithAI(commitMessages);
      }
    } catch (e) {
      print('AI analysis failed, falling back to local: $e');
    }

    return _analyzeLocally(commitMessages);
  }

  /// Use AI to analyze commit sentiment
  Future<SentimentResult> _analyzeWithAI(List<String> commitMessages) async {
    final prompt = '''
Analyze these Git commit messages and determine the developer's mood.
Return ONLY a JSON object with these fields:
- mood: one of [productive, debugging, creative, victory, reflective]
- confidence: 0.0-1.0
- keywords: array of relevant words found
- reasoning: brief Eurovision-themed explanation

Commits to analyze:
${commitMessages.take(20).map((m) => "- $m").join("\n")}
''';

    final response = await http.post(
      Uri.parse('https://api.github.com/copilot/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_githubToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a Eurovision expert analyzing coding sentiment.',
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
        'max_tokens': 300,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI request failed: ${response.statusCode}');
    }

    final aiResponse = jsonDecode(response.body);
    final content = aiResponse['choices'][0]['message']['content'] as String;
    final data = jsonDecode(content);

    return _createResult(
      mood: CodingMood.fromString(data['mood'] as String),
      confidence: (data['confidence'] as num).toDouble(),
      keywords: List<String>.from(data['keywords'] as List),
      reasoning: data['reasoning'] as String,
      commitMessages: commitMessages,
    );
  }

  /// Local sentiment analysis using keyword matching
  SentimentResult _analyzeLocally(List<String> commitMessages) {
    final moodCounts = Map<String, int>.from(SentimentAnalysis.emptyMoodCounts);
    final foundKeywords = <String>{};

    // Count occurrences of mood-indicating keywords
    for (final message in commitMessages) {
      final lowerMessage = message.toLowerCase();

      CodingMoodData.keywords.forEach((mood, keywords) {
        for (final keyword in keywords) {
          if (lowerMessage.contains(keyword)) {
            moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
            foundKeywords.add(keyword);
          }
        }
      });
    }

    // Find the dominant mood
    var dominantMood = 'productive';
    var maxCount = 0;

    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = mood;
      }
    });

    final totalWords = commitMessages.join(' ').split(' ').length;
    final confidence =
        maxCount == 0 ? 0.3 : (maxCount / totalWords).clamp(0.0, 0.9);

    return _createResult(
      mood: CodingMood.fromString(dominantMood),
      confidence: confidence,
      keywords: foundKeywords.take(5).toList(),
      reasoning: maxCount > 0
          ? 'Found $maxCount keywords matching this mood'
          : 'No strong patterns detected',
      commitMessages: commitMessages,
    );
  }

  /// Create a SentimentResult with complete analysis
  SentimentResult _createResult({
    required CodingMood mood,
    required double confidence,
    required List<String> keywords,
    required String reasoning,
    required List<String> commitMessages,
  }) {
    return SentimentResult(
      mood: mood,
      confidence: confidence,
      keywords: keywords,
      reasoning: reasoning,
      analysis: SentimentAnalysis(
        totalCommits: commitMessages.length,
        moodCounts: Map<String, int>.from(SentimentAnalysis.emptyMoodCounts),
        keywordCount: keywords.length,
      ),
    );
  }
}
