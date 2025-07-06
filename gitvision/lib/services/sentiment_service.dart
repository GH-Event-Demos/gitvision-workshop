import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coding_mood.dart';
import '../models/sentiment_result.dart';
import '../services/logging_service.dart';

/// PHASE 2: Sentiment Analysis Service
/// 
/// This service demonstrates:
/// - Advanced sentiment analysis using GitHub Models API
/// - Integration with AI/ML services for playlist generation
/// - Eurovision-themed content generation
/// - Prompt engineering for specific use cases
class SentimentService {
  final String _githubToken;
  final LoggingService _logger;
  
  static const String _githubModelsEndpoint = 'https://models.github.ai/inference';
  static const String _modelName = 'openai/gpt-4.1';

  SentimentService({
    required String githubToken,
    required LoggingService logger,
  }) : _githubToken = githubToken,
       _logger = logger;

  /// Analyze commit sentiment and return coding mood
  Future<SentimentResult> analyzeCommitSentiment(List<String> commitMessages) async {
    _logger.debug('Analyzing sentiment for ${commitMessages.length} commits');
    
    if (commitMessages.isEmpty) {
      return SentimentResult.fromCommitMessages([]);
    }

    try {
      // Use GitHub Models API for advanced sentiment analysis
      final aiResult = await _analyzeWithGitHubModels(commitMessages);
      
      // Combine AI results with local analysis
      final localResult = SentimentResult.fromCommitMessages(commitMessages);
      
      // If AI analysis succeeded, use it; otherwise fallback to local
      return aiResult ?? localResult;
    } catch (e) {
      _logger.error('Failed to analyze sentiment with AI, using local analysis', e);
      return SentimentResult.fromCommitMessages(commitMessages);
    }
  }

  /// > Use GitHub Models API for sentiment analysis
  Future<SentimentResult?> _analyzeWithGitHubModels(List<String> commitMessages) async {
    try {
      final prompt = _buildSentimentPrompt(commitMessages);
      
      final response = await http.post(
        Uri.parse('$_githubModelsEndpoint/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_githubToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _modelName,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a coding mood analyzer that determines a developer\'s coding mood based on their commit messages. You must respond with valid JSON only.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Clean up markdown formatting if present
        String cleanContent = content;
        if (cleanContent.startsWith('```json')) {
          cleanContent = cleanContent.substring(7);
        }
        if (cleanContent.endsWith('```')) {
          cleanContent = cleanContent.substring(0, cleanContent.length - 3);
        }
        cleanContent = cleanContent.trim();
        
        // Parse the AI response
        final aiResult = json.decode(cleanContent);
        
        return SentimentResult(
          mood: CodingMood.fromString(aiResult['mood']),
          confidence: (aiResult['confidence'] as num).toDouble(),
          keywords: List<String>.from(aiResult['keywords'] ?? []),
          reasoning: aiResult['reasoning'] ?? 'AI analysis completed',
          analysis: SentimentResult.fromCommitMessages(commitMessages).analysis,
        );
      } else {
        _logger.error('GitHub Models API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.error('Error calling GitHub Models API', e);
      return null;
    }
  }

  /// Get Eurovision song suggestions based on coding mood
  Future<List<Map<String, dynamic>>> getEurovisionSuggestions(CodingMood mood) async {
    _logger.debug('Getting Eurovision suggestions for mood: ${mood.name}');

    try {
      // Use GitHub Models API for Eurovision song suggestions
      final aiSuggestions = await _getEurovisionSuggestionsFromAI(mood);
      
      // If AI suggestions failed, use fallback
      return aiSuggestions ?? _getFallbackSuggestions(mood);
    } catch (e) {
      _logger.error('Failed to get Eurovision suggestions from AI, using fallback', e);
      return _getFallbackSuggestions(mood);
    }
  }

  /// <� Generate Eurovision suggestions using AI
  Future<List<Map<String, dynamic>>?> _getEurovisionSuggestionsFromAI(CodingMood mood) async {
    try {
      final prompt = _buildEurovisionPrompt(mood);
      
      final response = await http.post(
        Uri.parse('$_githubModelsEndpoint/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_githubToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _modelName,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a Eurovision music expert that creates playlists based on coding moods. You must respond with valid JSON only.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Clean up markdown formatting if present
        String cleanContent = content;
        if (cleanContent.startsWith('```json')) {
          cleanContent = cleanContent.substring(7);
        }
        if (cleanContent.endsWith('```')) {
          cleanContent = cleanContent.substring(0, cleanContent.length - 3);
        }
        cleanContent = cleanContent.trim();
        
        // Parse the AI response
        final aiResult = json.decode(cleanContent);
        
        return List<Map<String, dynamic>>.from(aiResult['songs'] ?? []);
      } else {
        _logger.error('GitHub Models API error for Eurovision suggestions: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.error('Error getting Eurovision suggestions from AI', e);
      return null;
    }
  }

  /// <� Build sentiment analysis prompt
  String _buildSentimentPrompt(List<String> commitMessages) {
    final commitsText = commitMessages.take(20).join('\n- ');
    
    return '''
Analyze these commit messages and determine the developer's coding mood:

- $commitsText

Available moods:
- productive: Working on new features, implementing functionality
- debugging: Fixing bugs, resolving issues
- creative: Designing UI, experimenting with new approaches
- victory: Completing milestones, releasing features
- reflective: Refactoring, cleaning up code
- frustrated: Dealing with difficult problems
- focused: Deep work, concentrated effort
- experimental: Trying new technologies, exploring ideas

Respond with JSON in this format:
{
  "mood": "mood_name",
  "confidence": 0.85,
  "keywords": ["keyword1", "keyword2"],
  "reasoning": "Brief explanation of the mood analysis"
}
''';
  }

  /// <� Build Eurovision suggestion prompt
  String _buildEurovisionPrompt(CodingMood mood) {
    return '''
Create a Eurovision playlist for a developer with a ${mood.name} coding mood.
${mood.description}

Generate 3-5 Eurovision songs that match this mood. Consider:
- Energy level that matches the coding mood
- Lyrical themes that resonate with the developer's state
- Musical style that complements the work environment
- Eurovision history and memorable performances

Respond with JSON in this format:
{
  "songs": [
    {
      "title": "Song Title",
      "artist": "Artist Name",
      "country": "Country",
      "year": 2023,
      "reasoning": "Why this song matches the mood",
      "energyLevel": 8,
      "moodMatch": 9
    }
  ]
}
''';
  }

  /// <� Fallback Eurovision suggestions when AI fails
  List<Map<String, dynamic>> _getFallbackSuggestions(CodingMood mood) {
    switch (mood) {
      case CodingMood.productive:
        return [
          {
            'title': 'Euphoria',
            'artist': 'Loreen',
            'country': 'Sweden',
            'year': 2012,
            'reasoning': 'This uplifting anthem matches your productive flow perfectly',
            'energyLevel': 9,
            'moodMatch': 10
          },
          {
            'title': 'Stefania',
            'artist': 'Kalush Orchestra',
            'country': 'Ukraine',
            'year': 2022,
            'reasoning': 'Energetic and driven, perfect for getting things done',
            'energyLevel': 8,
            'moodMatch': 9
          }
        ];
      
      case CodingMood.debugging:
        return [
          {
            'title': 'Rise Like a Phoenix',
            'artist': 'Conchita Wurst',
            'country': 'Austria',
            'year': 2014,
            'reasoning': 'Rising from the ashes of bugs, this song captures the debugging spirit',
            'energyLevel': 7,
            'moodMatch': 10
          }
        ];
      
      case CodingMood.creative:
        return [
          {
            'title': 'Shum',
            'artist': 'Go_A',
            'country': 'Ukraine',
            'year': 2021,
            'reasoning': 'Innovative and creative, matching your experimental coding energy',
            'energyLevel': 9,
            'moodMatch': 10
          }
        ];
      
      case CodingMood.victory:
        return [
          {
            'title': 'Waterloo',
            'artist': 'ABBA',
            'country': 'Sweden',
            'year': 1974,
            'reasoning': 'The ultimate Eurovision victory song for celebrating your wins',
            'energyLevel': 10,
            'moodMatch': 10
          }
        ];
      
      case CodingMood.reflective:
        return [
          {
            'title': 'Arcade',
            'artist': 'Duncan Laurence',
            'country': 'Netherlands',
            'year': 2019,
            'reasoning': 'Contemplative and thoughtful, perfect for reflective coding',
            'energyLevel': 5,
            'moodMatch': 9
          }
        ];
      
      case CodingMood.frustrated:
        return [
          {
            'title': 'My Heart Will Go On',
            'artist': 'C�line Dion',
            'country': 'Canada',
            'year': 1998,
            'reasoning': 'Sometimes you need a dramatic ballad to match your debugging struggles',
            'energyLevel': 6,
            'moodMatch': 8
          }
        ];
      
      case CodingMood.focused:
        return [
          {
            'title': 'Hold Me Closer',
            'artist': 'Cornelia Jakobs',
            'country': 'Sweden',
            'year': 2022,
            'reasoning': 'Focused and intense, perfect for deep work sessions',
            'energyLevel': 7,
            'moodMatch': 9
          }
        ];
      
      case CodingMood.experimental:
        return [
          {
            'title': 'Zitti e buoni',
            'artist': 'M�neskin',
            'country': 'Italy',
            'year': 2021,
            'reasoning': 'Bold and experimental, matching your adventurous coding spirit',
            'energyLevel': 10,
            'moodMatch': 10
          }
        ];
    }
  }
}