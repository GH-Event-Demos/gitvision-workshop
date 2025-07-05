import 'dart:async';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';
import 'logging_service.dart';

/// 🛡️ PHASE 5: Production Error Handling Service
/// 
/// This service provides comprehensive error handling:
/// - Global error catching and reporting
/// - User-friendly error messages
/// - Automatic retry mechanisms
/// - Graceful degradation patterns
/// 
/// Workshop Learning Goals:
/// - Error handling best practices
/// - User experience during failures
/// - Error categorization and prioritization
/// - Recovery strategies and fallbacks
class ErrorHandlingService {
  final AnalyticsService _analytics = AnalyticsService();
  final LoggingService _logger;
  bool _isInitialized = false;
  
  // Constructor that accepts LoggingService
  ErrorHandlingService({required LoggingService logger}) : _logger = logger;

  final AnalyticsService _analytics = AnalyticsService();
  bool _isInitialized = false;

  /// 🚀 Initialize global error handling
  /// Workshop: This shows comprehensive error handling setup
  void initialize() {
    if (_isInitialized) return;

    // Debug: // Debug: print('🛡️ [ErrorHandler] Initializing global error handling...');

    // Catch all errors in Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Catch errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Note: Isolate error handling removed for web compatibility

    _isInitialized = true;
    // Debug: // Debug: print('✅ [ErrorHandler] Global error handling initialized');
  }

  /// 🎯 Handle specific GitVision errors with context
  /// Workshop: This shows contextual error handling
  Future<T?> handleOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
    T? fallbackValue,
    bool showUserError = true,
    int maxRetries = 0,
  }) async {
    final stopwatch = Stopwatch()..start();
    int attempts = 0;

    while (attempts <= maxRetries) {
      try {
        attempts++;
        // Debug: // Debug: print('🔄 [ErrorHandler] Attempting $operationName (attempt $attempts)');
        
        final result = await operation();
        
        stopwatch.stop();
        await _analytics.trackPerformance(
          operation: operationName,
          duration: stopwatch.elapsed,
          success: true,
        );
        
        if (attempts > 1) {
          // Debug: // Debug: print('✅ [ErrorHandler] $operationName succeeded after $attempts attempts');
        }
        
        return result;
      } catch (error, stackTrace) {
        // Debug: // Debug: print('❌ [ErrorHandler] $operationName failed (attempt $attempts): $error');
        
        if (attempts > maxRetries) {
          stopwatch.stop();
          
          // Track the final failure
          await _analytics.trackPerformance(
            operation: operationName,
            duration: stopwatch.elapsed,
            success: false,
            errorMessage: error.toString(),
          );
          
          await _handleApplicationError(
            error: error,
            stackTrace: stackTrace,
            context: operationName,
            showUserError: showUserError,
          );
          
          return fallbackValue;
        }
        
        // Wait before retry with exponential backoff
        if (attempts <= maxRetries) {
          final delayMs = (100 * (1 << (attempts - 1))).clamp(100, 5000);
          // Debug: // Debug: print('⏳ [ErrorHandler] Retrying $operationName in ${delayMs}ms...');
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }
    
    return fallbackValue;
  }

  /// 🌐 Handle network-related errors with specific guidance
  /// Workshop: This shows network error categorization
  Future<void> handleNetworkError(dynamic error, String operation) async {
    String userMessage;
    String errorCategory;
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('connection failed')) {
      userMessage = 'No internet connection. Please check your network and try again.';
      errorCategory = 'network_connectivity';
    } else if (errorString.contains('timeout')) {
      userMessage = 'Request timed out. Please try again.';
      errorCategory = 'network_timeout';
    } else if (errorString.contains('403')) {
      userMessage = 'API rate limit exceeded. Please wait a moment and try again.';
      errorCategory = 'api_rate_limit';
    } else if (errorString.contains('401')) {
      userMessage = 'Authentication failed. Please check your API token.';
      errorCategory = 'api_authentication';
    } else if (errorString.contains('404')) {
      userMessage = 'Resource not found. Please check your input and try again.';
      errorCategory = 'api_not_found';
    } else {
      userMessage = 'Network error occurred. Please try again.';
      errorCategory = 'network_unknown';
    }
    
    await _analytics.trackError(
      error: error.toString(),
      context: operation,
      additionalData: {
        'error_category': errorCategory,
        'user_message': userMessage,
      },
    );
    
    // Debug: // Debug: print('🌐 [ErrorHandler] Network error: $userMessage');
  }

  /// 🔧 Handle API integration errors
  /// Workshop: This shows API error handling patterns
  Future<void> handleAPIError({
    required dynamic error,
    required String service,
    required String endpoint,
    int? statusCode,
  }) async {
    final errorData = {
      'service': service,
      'endpoint': endpoint,
      'status_code': statusCode,
      'error_message': error.toString(),
    };
    
    await _analytics.trackError(
      error: 'API Error in $service',
      context: endpoint,
      additionalData: errorData,
    );
    
    // Debug: // Debug: print('🔧 [ErrorHandler] API error in $service ($endpoint): $error');
  }

  /// 🧠 Handle AI/ML service errors
  /// Workshop: This shows AI service error handling
  Future<void> handleAIError({
    required dynamic error,
    required String model,
    required String operation,
    String? prompt,
  }) async {
    String userMessage;
    
    if (error.toString().contains('rate limit')) {
      userMessage = 'AI service is busy. Falling back to local analysis.';
    } else if (error.toString().contains('authentication')) {
      userMessage = 'AI service authentication failed. Using local analysis.';
    } else {
      userMessage = 'AI analysis unavailable. Using local sentiment analysis.';
    }
    
    await _analytics.trackError(
      error: error.toString(),
      context: 'AI_$operation',
      additionalData: {
        'model': model,
        'operation': operation,
        'user_message': userMessage,
        'has_fallback': true,
      },
    );
    
    // Debug: // Debug: print('🧠 [ErrorHandler] AI error: $userMessage');
  }

  /// 📱 Get user-friendly error message
  /// Workshop: This shows error message localization and UX
  String getUserFriendlyMessage(dynamic error, {String? context}) {
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('socketexception')) {
      return 'Check your internet connection and try again.';
    }
    if (errorString.contains('timeout')) {
      return 'Request took too long. Please try again.';
    }
    
    // API errors
    if (errorString.contains('403') || errorString.contains('rate limit')) {
      return 'Service is busy. Please wait a moment and try again.';
    }
    if (errorString.contains('401')) {
      return 'Authentication error. Please check your settings.';
    }
    if (errorString.contains('404')) {
      return 'Resource not found. Please check your input.';
    }
    
    // GitHub specific
    if (context?.contains('github') == true) {
      if (errorString.contains('user not found')) {
        return 'GitHub user not found. Please check the username.';
      }
      return 'GitHub API error. Please try again later.';
    }
    
    // Spotify specific
    if (context?.contains('spotify') == true) {
      return 'Music service temporarily unavailable.';
    }
    
    // AI/ML specific
    if (context?.contains('ai') == true || context?.contains('models') == true) {
      return 'AI analysis temporarily unavailable. Using local analysis.';
    }
    
    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  /// 📊 Get error statistics for debugging
  /// Workshop: This shows error monitoring and debugging
  Map<String, dynamic> getErrorStatistics() {
    return {
      'is_initialized': _isInitialized,
      'error_handling_enabled': true,
      'last_check': DateTime.now().toIso8601String(),
    };
  }

  // Private error handlers

  Future<void> _handleFlutterError(FlutterErrorDetails details) async {
    // Debug: // Debug: print('🐛 [ErrorHandler] Flutter error: ${details.exception}');
    
    await _analytics.trackError(
      error: details.exception.toString(),
      stackTrace: details.stack.toString(),
      context: 'flutter_framework',
      additionalData: {
        'library': details.library,
        'error_type': 'flutter_error',
      },
    );
  }

  bool _handlePlatformError(Object error, StackTrace stack) {
    // Debug: // Debug: print('💥 [ErrorHandler] Platform error: $error');
    
    // Track async without waiting
    _analytics.trackError(
      error: error.toString(),
      stackTrace: stack.toString(),
      context: 'platform',
      additionalData: {
        'error_type': 'platform_error',
      },
    );
    
    return true;
  }

  Future<void> _handleApplicationError({
    required dynamic error,
    required StackTrace stackTrace,
    required String context,
    bool showUserError = true,
  }) async {
    await _analytics.trackError(
      error: error.toString(),
      stackTrace: stackTrace.toString(),
      context: context,
      additionalData: {
        'error_type': 'application_error',
        'show_user_error': showUserError,
      },
    );
  }
}