// A simple sentiment analyzer for GitVision app
// This analyzes commit messages and returns a "vibe" that matches Eurovision songs

import 'dart:math';
import 'models/coding_mood.dart';
import 'models/coding_mood_data.dart';
import 'models/sentiment_result.dart';
import 'models/sentiment_analysis.dart';

/// A simple sentiment analyzer that matches commit messages to Eurovision vibes
class SentimentAnalyzer {
  /// Detect the coding vibe from commit messages
  static CodingMood detectVibe(List<String> commitMessages) {
    if (commitMessages.isEmpty) {
      return CodingMood.productive;
    }

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

    return CodingMood.fromString(dominantMood);
  }

  /// Get song recommendations for a specific mood
  static List<String> getSongRecommendations(CodingMood vibe, {int count = 3}) {
    return CodingMoodData.getRecommendations(vibe.name, count: count);
  }

  /// Create a complete sentiment analysis result
  static SentimentResult analyzeSentiment(List<String> commitMessages) {
    if (commitMessages.isEmpty) {
      return SentimentResult(
        mood: CodingMood.productive,
        confidence: 0.5,
        keywords: const [],
        reasoning: 'No commits to analyze',
        analysis: SentimentAnalysis.empty,
      );
    }

    final moodCounts = Map<String, int>.from(SentimentAnalysis.emptyMoodCounts);
    final foundKeywords = <String>{};

    // Count keyword occurrences
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

    // Find dominant mood
    var dominantMood = CodingMood.productive;
    var maxCount = 0;

    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = CodingMood.fromString(mood);
      }
    });

    // Calculate confidence
    final totalWords = commitMessages.join(' ').split(' ').length;
    final confidence = maxCount == 0 ? 0.3 : min(0.9, (maxCount / totalWords) * 10);

    return SentimentResult(
      mood: dominantMood,
      confidence: confidence,
      keywords: foundKeywords.take(5).toList(),
      reasoning: maxCount > 0 
        ? 'Found $maxCount keywords matching ${dominantMood.name}'
        : 'No strong patterns detected, defaulting to ${dominantMood.name}',
      analysis: SentimentAnalysis(
        totalCommits: commitMessages.length,
        moodCounts: moodCounts,
        keywordCount: foundKeywords.length,
      ),
    );
  }
}
