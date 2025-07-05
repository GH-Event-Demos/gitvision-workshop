import '../services/logging_service.dart';

class AnalyticsService {
  final LoggingService _logger;

  AnalyticsService({required LoggingService logger}) : _logger = logger;

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    _logger.debug('Analytics event: $eventName', parameters);
  }

  void trackError(String error, {Map<String, dynamic>? parameters}) {
    _logger.error('Analytics error: $error', parameters);
  }

  void trackMoodAnalysis(String mood, double confidence) {
    trackEvent('mood_analysis', {
      'mood': mood,
      'confidence': confidence,
    });
  }

  void trackUserAction(String action, {Map<String, dynamic>? parameters}) {
    trackEvent('user_action', {
      'action': action,
      ...?parameters,
    });
  }
}