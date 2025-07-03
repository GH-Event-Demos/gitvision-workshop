import 'dart:io';
import '../models/coding_mood.dart';

/// 📊 PHASE 5: Analytics and Telemetry Service
/// 
/// This service demonstrates production-ready analytics integration:
/// - Event tracking and user behavior analytics
/// - Performance monitoring and error tracking
/// - A/B testing framework preparation
/// - Privacy-compliant data collection
/// 
/// Workshop Learning Goals:
/// - Analytics integration patterns
/// - Performance monitoring best practices
/// - Error tracking and crash reporting
/// - GDPR/Privacy compliance considerations
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isInitialized = false;
  bool _analyticsEnabled = true;
  final List<Map<String, dynamic>> _eventQueue = [];

  /// Prepare analytics data by converting enums to strings and ensuring type safety
  Map<String, dynamic> _prepareAnalyticsData(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is CodingMood) {
        return MapEntry(key, value.name);
      }
      return MapEntry(key, value);
    });
  }

  /// 🚀 Initialize analytics service
  /// Workshop: This shows analytics setup and configuration
  Future<void> initialize({
    required String apiKey,
    bool enableCrashReporting = true,
    bool enablePerformanceMonitoring = true,
  }) async {
    if (_isInitialized) return;
    
    try {
      // Workshop: Here you would initialize actual analytics SDKs
      // Examples: Firebase Analytics, Mixpanel, Amplitude, etc.
      
      await _setupAnalyticsSDK(apiKey);
      await _setupCrashReporting(enableCrashReporting);
      await _setupPerformanceMonitoring(enablePerformanceMonitoring);
      
      _isInitialized = true;
      
      // Track app start event with platform info
      await trackEvent('app_started', {
        'platform': _getPlatform(),
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Debug: // Debug: print('❌ [Analytics] Failed to initialize analytics: $e');
    }
  }

  /// 📈 Track custom events
  /// Workshop: This shows event tracking best practices
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties) async {
    if (!_analyticsEnabled || !_isInitialized) return;
    
    final event = {
      'event': eventName,
      'properties': _prepareAnalyticsData(properties),
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': _generateSessionId(),
    };
    
    _eventQueue.add(event);
    
    // Workshop: In production, you'd send to analytics service
    await _sendEventToAnalytics(event);
  }

  /// 🎯 Track user actions specific to GitVision
  Future<void> trackGitVisionEvent({
    required String action,
    String? githubHandle,
    String? mood,
    int? trackCount,
    String? platform,
    Map<String, dynamic>? additionalProperties,
  }) async {
    final properties = {
      'action': action,
      if (githubHandle != null) 'github_handle': githubHandle,
      if (mood != null) 'detected_mood': mood,
      if (trackCount != null) 'track_count': trackCount,
      if (platform != null) 'platform': platform,
      ...?additionalProperties,
    };
    
    await trackEvent('gitvision_$action', properties);
  }

  /// ⚡ Track performance metrics
  /// Workshop: This shows performance monitoring implementation
  Future<void> trackPerformance({
    required String operation,
    required Duration duration,
    bool success = true,
    String? errorMessage,
  }) async {
    if (!_analyticsEnabled || !_isInitialized) return;
    
    await trackEvent('performance_metric', {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  /// 🐛 Track errors and exceptions
  /// Workshop: This shows error tracking and crash reporting
  Future<void> trackError({
    required String error,
    String? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_analyticsEnabled || !_isInitialized) return;
    
    await trackEvent('error_occurred', {
      'error_message': error,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (context != null) 'context': context,
      'platform': _getPlatform(),
      ...?additionalData,
    });
  }

  /// 📱 Track user engagement metrics
  /// Workshop: This shows engagement tracking for retention analysis
  Future<void> trackEngagement({
    required String feature,
    required Duration timeSpent,
    int? interactionCount,
  }) async {
    await trackEvent('user_engagement', {
      'feature': feature,
      'time_spent_seconds': timeSpent.inSeconds,
      if (interactionCount != null) 'interaction_count': interactionCount,
    });
  }

  /// 🔄 Track conversion funnel steps
  /// Workshop: This shows funnel tracking for optimization
  Future<void> trackFunnelStep({
    required String funnel,
    required String step,
    required String githubHandle,
    Map<String, dynamic>? metadata,
  }) async {
    await trackEvent('funnel_step', {
      'funnel': funnel,
      'step': step,
      'github_handle': githubHandle,
      ...?metadata,
    });
  }

  /// 🎨 Track A/B test assignments
  /// Workshop: This shows A/B testing framework integration
  Future<void> trackExperiment({
    required String experimentName,
    required String variant,
    String? userId,
  }) async {
    await trackEvent('experiment_assigned', {
      'experiment': experimentName,
      'variant': variant,
      if (userId != null) 'user_id': userId,
    });
  }

  /// 📊 Get analytics summary for debugging
  /// Workshop: This shows analytics debugging and validation
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'is_initialized': _isInitialized,
      'analytics_enabled': _analyticsEnabled,
      'events_queued': _eventQueue.length,
      'last_events': _eventQueue.take(5).toList(),
    };
  }

  /// 🔧 Enable/disable analytics (GDPR compliance)
  /// Workshop: This shows privacy compliance implementation
  void setAnalyticsEnabled(bool enabled) {
    _analyticsEnabled = enabled;
    
    if (!enabled) {
      _eventQueue.clear();
    }
  }

  /// 🧹 Clear analytics data (privacy compliance)
  Future<void> clearAnalyticsData() async {
    _eventQueue.clear();
    // Workshop: Clear any stored analytics data
  }

  // Private helper methods

  Future<void> _setupAnalyticsSDK(String apiKey) async {
    // Workshop: Initialize your chosen analytics SDK
    // Firebase Analytics, Mixpanel, Amplitude, etc.
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate setup
  }

  Future<void> _setupCrashReporting(bool enabled) async {
    if (!enabled) return;
    // Workshop: Initialize crash reporting (Crashlytics, Sentry, etc.)
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate setup
  }

  Future<void> _setupPerformanceMonitoring(bool enabled) async {
    if (!enabled) return;
    // Workshop: Initialize performance monitoring
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate setup
  }

  Future<void> _sendEventToAnalytics(Map<String, dynamic> event) async {
    try {
      // Workshop: Send event to your analytics backend
      // Example: HTTP POST to analytics endpoint
      
      // Debug: // Debug: print('📤 [Analytics] Event sent: ${event['event']}');
    } catch (e) {
      // Debug: // Debug: print('❌ [Analytics] Failed to send event: $e');
    }
  }

  String _generateSessionId() {
    // Simple session ID generation
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _getPlatform() {
    try {
      return Platform.operatingSystem;
    } catch (e) {
      // Fallback for platforms where Platform.operatingSystem isn't supported
      return 'unknown';
    }
  }
}