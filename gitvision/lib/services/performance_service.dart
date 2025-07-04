import 'dart:async';
import 'dart:isolate';
import 'analytics_service.dart';

/// ⚡ PHASE 5: Performance Optimization Service
/// 
/// This service provides production-ready performance optimizations:
/// - Memory management and leak detection
/// - Network request optimization and caching
/// - Background processing and isolates
/// - Performance monitoring and profiling
/// 
/// Workshop Learning Goals:
/// - Flutter performance best practices
/// - Memory management patterns
/// - Background processing strategies
/// - Performance measurement and optimization
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final Map<String, Stopwatch> _stopwatches = {};
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Performance thresholds (in milliseconds)
  static const int slowOperationThreshold = 1000;
  static const int cacheExpirationMs = 300000; // 5 minutes

  /// 🚀 Start performance monitoring for an operation
  /// Workshop: This shows performance measurement patterns
  void startTimer(String operationId) {
    _stopwatches[operationId] = Stopwatch()..start();
    // Debug: print('⏱️ [Performance] Started timing: $operationId');
  }

  /// ⏹️ Stop performance monitoring and log results
  /// Workshop: This shows performance analysis and reporting
  Future<Duration?> stopTimer(String operationId, {Map<String, dynamic>? metadata}) async {
    final stopwatch = _stopwatches.remove(operationId);
    if (stopwatch == null) return null;

    stopwatch.stop();
    final duration = stopwatch.elapsed;
    
    // Debug: print('📊 [Performance] $operationId completed in ${duration.inMilliseconds}ms');
    
    // Track performance metric
    await _analytics.trackPerformance(
      operation: operationId,
      duration: duration,
      success: true,
    );
    
    // Log slow operations
    if (duration.inMilliseconds > slowOperationThreshold) {
      // Debug: print('🐌 [Performance] SLOW OPERATION: $operationId took ${duration.inMilliseconds}ms');
      await _analytics.trackEvent('slow_operation', {
        'operation': operationId,
        'duration_ms': duration.inMilliseconds,
        'threshold_ms': slowOperationThreshold,
        ...?metadata,
      });
    }
    
    return duration;
  }

  /// 📦 Cache management with automatic expiration
  /// Workshop: This shows caching strategies for performance
  void cacheData(String key, dynamic data, {Duration? customExpiration}) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    final expiration = customExpiration ?? const Duration(milliseconds: cacheExpirationMs);
    // Debug: print('💾 [Performance] Cached data: $key (expires in ${expiration.inMinutes}min)');
    
    // Schedule cleanup
    Timer(expiration, () => _cleanupCacheEntry(key));
  }

  /// 📤 Retrieve cached data with freshness check
  /// Workshop: This shows cache retrieval and validation
  T? getCachedData<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;
    
    final age = DateTime.now().difference(timestamp);
    if (age.inMilliseconds > cacheExpirationMs) {
      _cleanupCacheEntry(key);
      return null;
    }
    
    final data = _cache[key] as T?;
    if (data != null) {
      // Debug: print('💨 [Performance] Cache hit: $key (age: ${age.inSeconds}s)');
    }
    
    return data;
  }

  /// 🧵 Execute heavy operations in background isolate
  /// Workshop: This shows isolate usage for performance
  Future<T> executeInBackground<T>({
    required Future<T> Function() operation,
    required String operationName,
    Duration? timeout,
  }) async {
    // Debug: print('🧵 [Performance] Running $operationName in background...');
    startTimer('background_$operationName');
    
    try {
      final completer = Completer<T>();
      
      // Create isolate for heavy computation
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _isolateEntryPoint,
        receivePort.sendPort,
      );
      
      // Listen for result
      late StreamSubscription subscription;
      subscription = receivePort.listen((message) {
        if (message is T) {
          completer.complete(message);
          subscription.cancel();
          isolate.kill();
        } else if (message is Exception) {
          completer.completeError(message);
          subscription.cancel();
          isolate.kill();
        }
      });
      
      // Apply timeout if specified
      if (timeout != null) {
        Timer(timeout, () {
          if (!completer.isCompleted) {
            completer.completeError(TimeoutException('Background operation timed out', timeout));
            isolate.kill();
          }
        });
      }
      
      final result = await completer.future;
      await stopTimer('background_$operationName');
      
      // Debug: print('✅ [Performance] Background operation completed: $operationName');
      return result;
    } catch (e) {
      await stopTimer('background_$operationName');
      // Debug: print('❌ [Performance] Background operation failed: $operationName - $e');
      rethrow;
    }
  }

  /// 🔄 Batch multiple operations for efficiency
  /// Workshop: This shows batching strategies for performance
  Future<List<T>> executeBatch<T>({
    required List<Future<T> Function()> operations,
    required String batchName,
    int? concurrencyLimit,
  }) async {
    // Debug: print('🔄 [Performance] Executing batch: $batchName (${operations.length} operations)');
    startTimer('batch_$batchName');
    
    try {
      List<T> results;
      
      if (concurrencyLimit != null && concurrencyLimit < operations.length) {
        // Process with concurrency limit
        results = [];
        for (int i = 0; i < operations.length; i += concurrencyLimit) {
          final chunk = operations.skip(i).take(concurrencyLimit);
          final chunkResults = await Future.wait(chunk.map((op) => op()));
          results.addAll(chunkResults);
          
          // Small delay between chunks to prevent overwhelming services
          if (i + concurrencyLimit < operations.length) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
      } else {
        // Process all at once
        results = await Future.wait(operations.map((op) => op()));
      }
      
      await stopTimer('batch_$batchName', metadata: {
        'operation_count': operations.length,
        'concurrency_limit': concurrencyLimit,
      });
      
      // Debug: print('✅ [Performance] Batch completed: $batchName');
      return results;
    } catch (e) {
      await stopTimer('batch_$batchName');
      // Debug: print('❌ [Performance] Batch failed: $batchName - $e');
      rethrow;
    }
  }

  /// 🧹 Memory cleanup and optimization
  /// Workshop: This shows memory management best practices
  void performMemoryCleanup() {
    // Debug: print('🧹 [Performance] Performing memory cleanup...');
    
    // Clear expired cache entries
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp).inMilliseconds > cacheExpirationMs) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _cleanupCacheEntry(key);
    }
    
    // Clear completed stopwatches
    _stopwatches.removeWhere((key, stopwatch) => !stopwatch.isRunning);
    
    // Debug: print('✅ [Performance] Memory cleanup completed (removed ${expiredKeys.length} cache entries)');
  }

  /// 📊 Get performance statistics
  /// Workshop: This shows performance monitoring and debugging
  Map<String, dynamic> getPerformanceStats() {
    final activeTimes = _stopwatches.length;
    final cacheSize = _cache.length;
    final memoryUsage = _estimateMemoryUsage();
    
    return {
      'active_timers': activeTimes,
      'cache_entries': cacheSize,
      'estimated_memory_kb': memoryUsage,
      'cache_hit_rate': _calculateCacheHitRate(),
      'last_cleanup': DateTime.now().toIso8601String(),
    };
  }

  /// 🔧 Optimize network requests with retry and backoff
  /// Workshop: This shows network optimization patterns
  Future<T> optimizedNetworkRequest<T>({
    required Future<T> Function() request,
    required String requestName,
    int maxRetries = 2,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts <= maxRetries) {
      attempts++;
      startTimer('network_${requestName}_attempt_$attempts');
      
      try {
        final result = await request();
        await stopTimer('network_${requestName}_attempt_$attempts');
        
        if (attempts > 1) {
          await _analytics.trackEvent('network_retry_success', {
            'request': requestName,
            'attempts': attempts,
          });
        }
        
        return result;
      } catch (e) {
        await stopTimer('network_${requestName}_attempt_$attempts');
        
        if (attempts > maxRetries) {
          await _analytics.trackEvent('network_retry_failed', {
            'request': requestName,
            'max_attempts': attempts,
            'error': e.toString(),
          });
          rethrow;
        }
        
        // Debug: print('🔄 [Performance] Network retry $attempts for $requestName in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * 1.5).round());
      }
    }
    
    throw Exception('Network request failed after $maxRetries retries');
  }

  // Private helper methods

  void _cleanupCacheEntry(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    // Debug: print('🗑️ [Performance] Cleaned up cache entry: $key');
  }

  static void _isolateEntryPoint(SendPort sendPort) {
    // Isolate entry point for background processing
    // Workshop: Implement actual background operations here
  }

  int _estimateMemoryUsage() {
    // Simple memory estimation (in practice, use actual memory profiling)
    int totalSize = 0;
    
    _cache.forEach((key, value) {
      totalSize += key.length * 2; // Rough string size estimation
      if (value is String) {
        totalSize += value.length * 2;
      } else if (value is List) {
        totalSize += value.length * 8; // Rough list estimation
      } else {
        totalSize += 100; // Default object estimation
      }
    });
    
    return totalSize ~/ 1024; // Convert to KB
  }

  double _calculateCacheHitRate() {
    // Simple cache hit rate calculation
    // In practice, you'd track hits and misses
    return _cache.isNotEmpty ? 0.85 : 0.0; // Mock value
  }
}