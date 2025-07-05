import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sentiment_result.dart';
import '../models/coding_mood.dart';
import '../models/sentiment_analysis.dart';
import '../models/coding_mood_data.dart';
import '../services/logging_service.dart';
import '../config/api_config.dart';

/// 🎵 GitVision Sentiment Analysis Service
/// Analyzes commit messages and matches them to Eurovision song moods
class SentimentService {
  final String? _githubToken;
  final LoggingService _logger;

  SentimentService({String? githubToken, required LoggingService logger}) 
    : _githubToken = githubToken,
      _logger = logger;

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
You are analyzing Git commit messages to determine the developer's coding mood. 
Match it to one of these Eurovision-inspired moods:

1. PRODUCTIVE 🚀 - Active development, adding features (like Euphoria - Sweden 2012)
2. DEBUGGING 🔧 - Fixing issues, solving problems (like Rise Like a Phoenix - Austria 2014)
3. CREATIVE 🎨 - UI/UX work, experiments (like Dancing Lasha Tumbai - Ukraine 2007)
4. VICTORY 🏆 - Releases, milestones (like Waterloo - Sweden 1974)
5. REFLECTIVE 📚 - Refactoring, documentation (like Calm After the Storm - Netherlands 2014)

Return ONLY a JSON object with:
- mood: string (one of the above moods in lowercase)
- confidence: float (0.0-1.0)
- keywords: string[] (key words found)
- reasoning: string (brief Eurovision-themed explanation)

Analyze these commits:
${commitMessages.take(20).map((m) => "- $m").join("\n")}
''';

    final response = await http.post(
      Uri.parse('https://api.github.com/copilot/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_githubToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'GitHub-Authentication-Type': 'Bearer',
      },
      body: jsonEncode({
        'model': 'gpt-4',
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
    
    // Extract JSON from markdown code blocks if present
    String jsonContent = content;
    if (content.contains('```json')) {
      final start = content.indexOf('```json') + 7;
      final end = content.indexOf('```', start);
      if (end != -1) {
        jsonContent = content.substring(start, end).trim();
      }
    } else if (content.contains('```')) {
      final start = content.indexOf('```') + 3;
      final end = content.indexOf('```', start);
      if (end != -1) {
        jsonContent = content.substring(start, end).trim();
      }
    }
    
    final data = jsonDecode(jsonContent);

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

  /// Get Eurovision song suggestions for a mood using GitHub Models API
  Future<List<Map<String, dynamic>>> getSongSuggestions(CodingMood mood) async {
    if (_githubToken == null || _githubToken!.isEmpty) {
      _logger.warning('No GitHub token available for song suggestions');
      return [];
    }

    final context = _getMoodContext(mood);
    final prompt = '''
Based on this developer's coding mood, suggest Eurovision songs that match their vibe.

Current mood: ${mood.name}
Context: $context

Return ONLY a JSON array with 5 Eurovision songs in this format:
[{
  "title": "song title",
  "artist": "artist name",
  "country": "country name",
  "year": year number,
  "reasoning": "brief explanation of why this song matches the mood"
}]

Only include actual Eurovision entries from 1956-2025.
Mix different decades and countries for variety.
Keep reasonings concise but creative, relating to both the song and coding mood.
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.github.com/copilot/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_githubToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'GitHub-Authentication-Type': 'Bearer',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a Eurovision expert matching songs to developer moods.',
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode != 200) {
        _logger.error('Failed to get song suggestions: ${response.statusCode}');
        return [];
      }

      final aiResponse = jsonDecode(response.body);
      final content = aiResponse['choices'][0]['message']['content'] as String;
      
      // Extract JSON from markdown code blocks if present
      String jsonContent = content;
      if (content.contains('```json')) {
        final start = content.indexOf('```json') + 7;
        final end = content.indexOf('```', start);
        if (end != -1) {
          jsonContent = content.substring(start, end).trim();
        }
      } else if (content.contains('```')) {
        final start = content.indexOf('```') + 3;
        final end = content.indexOf('```', start);
        if (end != -1) {
          jsonContent = content.substring(start, end).trim();
        }
      }

      final suggestions = jsonDecode(jsonContent) as List;
      return List<Map<String, dynamic>>.from(suggestions);
    } catch (e) {
      _logger.error('Error getting song suggestions', e);
      return [];
    }
  }

  /// Get context for a specific coding mood to help with Eurovision suggestions
  String _getMoodContext(CodingMood mood) {
    switch (mood) {
      case CodingMood.productive:
        return '''
This developer is in a productive flow state, actively building and creating new features.
Think energetic, triumphant Eurovision songs that capture the excitement of making progress.
Look for songs with powerful, uplifting choruses and dynamic performances.''';
      
      case CodingMood.debugging:
        return '''
The developer is deep in problem-solving mode, tackling bugs and fixing issues.
Consider dramatic Eurovision power ballads or songs about overcoming challenges.
Look for emotional depth and determination in the performances.''';
      
      case CodingMood.creative:
        return '''
They're in an experimental, creative phase - working on UI/UX or trying new approaches.
Match this with Eurovision's most unique and innovative performances.
Consider entries that pushed boundaries or introduced unexpected elements.''';
      
      case CodingMood.victory:
        return '''
The developer is celebrating achievements - successful deployments or completing features.
Think of Eurovision winning moments and songs that capture triumph.
Look for memorable victory performances and crowd-pleasing anthems.''';
      
      case CodingMood.reflective:
        return '''
They're in a thoughtful state - refactoring code or improving documentation.
Consider Eurovision's more introspective or emotional moments.
Look for beautiful melodies and meaningful performances.''';
      
      default:
        return '''
Match this mood with Eurovision songs that feel appropriate for the developer's current state.
Consider both the emotional and energy levels in your suggestions.''';
    }
  }

  /// Get Eurovision song suggestions based on the coding mood
  Future<List<Map<String, dynamic>>> getEurovisionSuggestions(CodingMood mood) async {
    if (_githubToken == null || _githubToken!.isEmpty) {
      _logger.warning('No GitHub token available for Eurovision suggestions');
      return [];
    }

    _logger.debug('Requesting Eurovision suggestions for mood: ${mood.name}');

    final prompt = '''
You are a Eurovision Song Contest expert. Based on the developer's coding mood "${mood.name}", 
suggest 5 Eurovision songs that would perfectly match their current state of mind.

${_getMoodContext(mood)}

Return a JSON array of 5 creative song suggestions in this format:
[{
  "title": "song name",
  "artist": "performer",
  "country": "country name",
  "year": year as number,
  "reasoning": "2-3 sentences explaining why this specific song matches the developer's current coding mood. Be creative and make unexpected but meaningful connections between the song's performance/mood and the coding state.",
  "energyLevel": number 1-10,
  "moodMatch": number 1-10
}]

Requirements:
1. Only use real Eurovision songs (2000-2025)
2. Mix different eras and countries
3. Be specific about why each song fits the coding mood
4. Consider both the song's energy and emotional qualities
5. Make creative, unexpected connections between coding and Eurovision

Be imaginative but authentic - help developers see their work in a new light through Eurovision's artistic lens.
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.github.com/copilot/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_githubToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'GitHub-Authentication-Type': 'Bearer',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a Eurovision expert with deep knowledge of the contest\'s history and performances.',
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode != 200) {
        _logger.error('GitHub Models API request failed: ${response.statusCode}');
        return [];
      }

      final aiResponse = jsonDecode(response.body);
      final content = aiResponse['choices'][0]['message']['content'] as String;
      
      // Extract JSON from markdown code blocks if present
      String jsonContent = content;
      if (content.contains('```json')) {
        final start = content.indexOf('```json') + 7;
        final end = content.indexOf('```', start);
        if (end != -1) {
          jsonContent = content.substring(start, end).trim();
        }
      } else if (content.contains('```')) {
        final start = content.indexOf('```') + 3;
        final end = content.indexOf('```', start);
        if (end != -1) {
          jsonContent = content.substring(start, end).trim();
        }
      }

      final suggestions = jsonDecode(jsonContent) as List;
      _logger.debug('Received ${suggestions.length} Eurovision song suggestions');
      
      return List<Map<String, dynamic>>.from(suggestions);
    } catch (e) {
      _logger.error('Error getting Eurovision suggestions', e);
      return [];
    }
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
