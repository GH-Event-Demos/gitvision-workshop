import 'package:flutter/material.dart';
import '../models/sentiment_result.dart';
import '../models/coding_mood.dart';

/// A widget that displays the commit analysis results with Eurovision theming
class CommitAnalysisDisplay extends StatelessWidget {
  final SentimentResult analysis;
  final List<String> commitMessages;

  const CommitAnalysisDisplay({
    super.key,
    required this.analysis,
    required this.commitMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodHeader(),
            const Divider(),
            _buildConfidenceIndicator(),
            const SizedBox(height: 16),
            _buildKeywordsList(),
            if (commitMessages.isNotEmpty) ...[
              const Divider(),
              _buildCommitList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '🎵 Eurovision Coding Mood',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getMoodColor(analysis.mood),
              ),
            ),
            const SizedBox(width: 8),
            _getMoodEmoji(analysis.mood),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          analysis.mood.description,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confidence: ${(analysis.confidence * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: analysis.confidence,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(analysis.mood)),
        ),
      ],
    );
  }

  Widget _buildKeywordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detected Keywords:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: analysis.keywords.map((keyword) {
            return Chip(
              label: Text(keyword),
              backgroundColor: _getMoodColor(analysis.mood).withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommitList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Commits:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: commitMessages.length.clamp(0, 5),
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.commit),
              title: Text(
                commitMessages[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _getMoodEmoji(CodingMood mood) {
    String emoji;
    switch (mood) {
      case CodingMood.productive:
        emoji = '🏆';
      case CodingMood.debugging:
        emoji = '🔥';
      case CodingMood.creative:
        emoji = '✨';
      case CodingMood.victory:
        emoji = '🎉';
      case CodingMood.reflective:
        emoji = '💭';
      case CodingMood.frustrated:
        emoji = '💪';
      case CodingMood.focused:
        emoji = '🎯';
      case CodingMood.experimental:
        emoji = '🌟';
    }
    return Text(emoji, style: const TextStyle(fontSize: 24));
  }

  Color _getMoodColor(CodingMood mood) {
    switch (mood) {
      case CodingMood.productive:
        return Colors.green;
      case CodingMood.debugging:
        return Colors.orange;
      case CodingMood.creative:
        return Colors.purple;
      case CodingMood.victory:
        return Colors.blue;
      case CodingMood.reflective:
        return Colors.teal;
      case CodingMood.frustrated:
        return Colors.red;
      case CodingMood.focused:
        return Colors.indigo;
      case CodingMood.experimental:
        return Colors.pink;
    }
  }
}
