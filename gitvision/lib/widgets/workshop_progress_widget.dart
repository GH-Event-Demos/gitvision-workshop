import 'package:flutter/material.dart';
import '../utils/workshop_helpers.dart';

// Workshop progress tracking widget for instructors and participants
class WorkshopProgressWidget extends StatelessWidget {
  final bool githubIntegrationWorking;
  final bool aiServiceImplemented;
  final bool spotifyServiceImplemented;
  
  const WorkshopProgressWidget({
    super.key,
    required this.githubIntegrationWorking,
    required this.aiServiceImplemented,
    required this.spotifyServiceImplemented,
  });

  @override
  Widget build(BuildContext context) {
    final progress = WorkshopHelpers.getWorkshopProgress(
      githubIntegrationWorking: githubIntegrationWorking,
      aiServiceImplemented: aiServiceImplemented,
      spotifyServiceImplemented: spotifyServiceImplemented,
    );
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.track_changes, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Workshop Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${progress['percentage']}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            LinearProgressIndicator(
              value: progress['percentage'] / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 16),
            
            _buildPhaseStatus('Phase 1: GitHub Integration', githubIntegrationWorking),
            _buildPhaseStatus('Phase 2: AI Eurovision Service', aiServiceImplemented),
            _buildPhaseStatus('Phase 3: Spotify Integration', spotifyServiceImplemented),
            
            if (progress['percentage'] < 100) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Step:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(progress['next_step']),
                    const SizedBox(height: 4),
                    Text(
                      'Estimated time: ${progress['estimated_time_remaining']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Workshop Complete! 🎉',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhaseStatus(String title, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: completed ? Colors.green[700] : Colors.grey[600],
                fontWeight: completed ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}