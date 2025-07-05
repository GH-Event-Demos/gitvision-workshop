/// Application-wide constants
class AppConstants {
  // Image cache configuration
  static const int imageCacheMaxSize = 200;
  static const int imageCacheMaxSizeBytes = 200 << 20; // 200 MB
  
  // Spotify batch configuration
  static const int spotifyBatchSize = 10;
  
  // Performance thresholds (milliseconds)
  static const int performanceSlowThreshold = 1000;
  static const int performanceTimeoutThreshold = 300000; // 5 minutes
  
  // UI constants
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 32.0;
  
  // Animation durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration navigationDelay = Duration(milliseconds: 500);
  
  // Spacing constants
  static const double smallSpacing = 8.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  // Icon sizes
  static const double smallIconSize = 20.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;
  
  // Font sizes
  static const double captionFontSize = 12.0;
  static const double bodyFontSize = 14.0;
  static const double titleFontSize = 16.0;
  static const double headingFontSize = 18.0;
  static const double largeTitleFontSize = 20.0;
  static const double displayFontSize = 24.0;
}