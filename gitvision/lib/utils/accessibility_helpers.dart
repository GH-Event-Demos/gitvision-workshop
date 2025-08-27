/// Accessibility constants and utilities for GitVision app
class AccessibilityConstants {
  // Minimum touch target sizes (following Material Design guidelines)
  static const double minTouchTargetSize = 44.0;
  static const double preferredTouchTargetSize = 48.0;
  
  // Semantic labels for Eurovision features
  static const String eurovisionAppTitle = 'GitVision - Eurovision themed GitHub commit analyzer';
  static const String musicNoteIcon = 'Music note icon';
  static const String playButtonLabel = 'Play Eurovision song';
  static const String pauseButtonLabel = 'Pause Eurovision song';
  static const String nextTrackLabel = 'Next Eurovision track';
  static const String previousTrackLabel = 'Previous Eurovision track';
  static const String volumeControlLabel = 'Volume control';
  static const String progressBarLabel = 'Song progress';
  
  // GitHub related labels
  static const String githubUsernameField = 'GitHub username input field';
  static const String connectButton = 'Connect to GitHub profile';
  static const String analyzeCommitsButton = 'Analyze commit patterns';
  
  // Loading and status labels
  static const String loadingEurovisionSongs = 'Loading Eurovision song recommendations';
  static const String connectingToGithub = 'Connecting to GitHub profile';
  static const String analyzingCommits = 'Analyzing commit patterns';
  
  // Eurovision content labels
  static String songCardLabel(String title, String artist, String country, int year) =>
      'Eurovision song: $title by $artist, representing $country in $year';
  
  static String albumArtLabel(String title, String artist) =>
      'Album artwork for $title by $artist';
  
  static String countryFlagLabel(String country) =>
      'Flag of $country';
  
  // Error and status messages
  static const String connectionError = 'Connection error occurred';
  static const String noSongsFound = 'No Eurovision songs found for your mood';
  static const String invalidGithubUser = 'Invalid GitHub username entered';
}

/// Accessibility helper functions
class AccessibilityHelpers {
  /// Creates a semantically labeled icon button with proper touch target size
  static Widget accessibleIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String semanticLabel,
    Color? color,
    double size = AccessibilityConstants.preferredTouchTargetSize,
    String? tooltip,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: color,
          tooltip: tooltip ?? semanticLabel,
          iconSize: size * 0.6, // Icon is 60% of touch target
        ),
      ),
    );
  }
  
  /// Creates an accessible text field with proper labeling
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? semanticLabel,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    Widget? prefixIcon,
    bool enabled = true,
    InputDecoration? decoration,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      textField: true,
      enabled: enabled,
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: (decoration ?? InputDecoration()).copyWith(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
  
  /// Creates an accessible card with proper semantic structure
  static Widget accessibleCard({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onTap,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        margin: margin,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Creates an accessible image with alternative text
  static Widget accessibleImage({
    required String imageUrl,
    required String altText,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Semantics(
      label: altText,
      image: true,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: altText,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? 
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading image',
                ),
              ),
            );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: Icon(
                Icons.error,
                semanticLabel: 'Failed to load image: $altText',
              ),
            );
        },
      ),
    );
  }
  
  /// Announces dynamic content changes to screen readers
  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Creates accessible loading indicator with description
  static Widget accessibleLoadingIndicator({
    required String description,
    Color? color,
    double? strokeWidth,
  }) {
    return Semantics(
      label: description,
      liveRegion: true,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth ?? 4.0,
        semanticsLabel: description,
      ),
    );
  }
}