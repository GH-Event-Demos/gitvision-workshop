/// Simple logging service for phase 1
class LoggingService {
  void debug(String message) {
    print('� DEBUG: $message');
  }

  void error(String message) {
    print('❌ ERROR: $message');
  }

  void info(String message) {
    print('ℹ️ INFO: $message');
  }

  void initialize() {
    // No initialization needed for phase 1
  }
}