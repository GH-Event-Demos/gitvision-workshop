import 'package:logger/logger.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  late final Logger _logger;

  void initialize({bool enableDebugLogs = true}) {
    _logger = Logger(
      filter: enableDebugLogs ? DevelopmentFilter() : ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.none,
      ),
    );
  }

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Service-specific logging methods
  void logGitHubAPI(String message, {Object? error}) {
    if (error != null) {
      _logger.e('🔗 [GitHub API] $message', error: error);
    } else {
      _logger.i('🔗 [GitHub API] $message');
    }
  }

  void logSpotifyAPI(String message, {Object? error}) {
    if (error != null) {
      _logger.e('🎵 [Spotify API] $message', error: error);
    } else {
      _logger.d('🎵 [Spotify API] $message');
    }
  }

  void logPlaylistGeneration(String message, {Object? error}) {
    if (error != null) {
      _logger.e('🎶 [Playlist] $message', error: error);
    } else {
      _logger.d('🎶 [Playlist] $message');
    }
  }

  void logPerformance(String message, {Object? error}) {
    if (error != null) {
      _logger.w('⏱️ [Performance] $message', error: error);
    } else {
      _logger.d('⏱️ [Performance] $message');
    }
  }

  void logAnalytics(String message, {Object? error}) {
    if (error != null) {
      _logger.e('📊 [Analytics] $message', error: error);
    } else {
      _logger.d('📊 [Analytics] $message');
    }
  }

  void logError(String service, String operation, Object error, [StackTrace? stackTrace]) {
    _logger.e('❌ [$service] $operation failed', error: error, stackTrace: stackTrace);
  }
}