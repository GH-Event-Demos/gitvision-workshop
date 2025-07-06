import 'package:logger/logger.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  late final Logger _logger;

  void initialize({bool enableDebugLogs = true}) {
    _logger = Logger(
      filter: enableDebugLogs ? DevelopmentFilter() : ProductionFilter(),
      printer: SimplePrinter(
        colors: false,
      ),
    );
  }

  void debug(String message) {
    _logger.d(message);
  }

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message) {
    _logger.w(message);
  }

  void error(String message, [Object? error]) {
    _logger.e(message, error: error);
  }
}