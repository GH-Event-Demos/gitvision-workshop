import 'dart:math';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = const Color(0xFF1DB954); // Spotify green
  Color _secondaryColor = const Color(0xFF1ED760); // Lighter Spotify green
  Color _accentColor = const Color(0xFFFFFFFF);
  bool _isDarkMode = true;
  bool _eurovisionMode = true; // Eurovision theme on by default in Phase 2
  
  // Eurovision themes with fun, bold colors
  final List<List<Color>> _eurovisionThemes = [
    [const Color(0xFF00A0E4), const Color(0xFF36C8F5), const Color(0xFFE1F5FE)], // Eurovision Blue
    [const Color(0xFFD80056), const Color(0xFFFF4081), const Color(0xFFFCE4EC)], // Eurovision Pink
    [const Color(0xFFFFD600), const Color(0xFFFFE57F), const Color(0xFFFFFDE7)], // Eurovision Gold
    [const Color(0xFF9C27B0), const Color(0xFFBA68C8), const Color(0xFFF3E5F5)], // Eurovision Purple
    [const Color(0xFFFF6B35), const Color(0xFFFF8A65), const Color(0xFFFFF3E0)], // Eurovision Orange
  ];
  
  // Dark, developer-focused themes with Spotify vibes
  final List<List<Color>> _codeThemes = [
    [const Color(0xFF1DB954), const Color(0xFF1ED760), const Color(0xFFFFFFFF)], // Spotify Classic
    [const Color(0xFF007ACC), const Color(0xFF4FC3F7), const Color(0xFFE3F2FD)], // VS Code Blue
    [const Color(0xFFFF6B35), const Color(0xFFFF8A65), const Color(0xFFFFF3E0)], // Git Orange
    [const Color(0xFF9C27B0), const Color(0xFFBA68C8), const Color(0xFFF3E5F5)], // Terminal Purple
    [const Color(0xFF4CAF50), const Color(0xFF81C784), const Color(0xFFE8F5E8)], // Matrix Green
    [const Color(0xFFFF5722), const Color(0xFFFF7043), const Color(0xFFFBE9E7)], // Error Red
  ];
  
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  bool get isDarkMode => _isDarkMode;
  bool get eurovisionMode => _eurovisionMode;
  
  // Dark base colors for Spotify-like appearance
  Color get backgroundColor => _isDarkMode 
      ? const Color(0xFF0D1117) // GitHub dark
      : const Color(0xFFF5F5F5); // Light gray
      
  Color get surfaceColor => _isDarkMode 
      ? const Color(0xFF161B22) // Card background
      : const Color(0xFFFFFFFF); // White
      
  Color get borderColor => _isDarkMode 
      ? const Color(0xFF21262D) // Subtle borders
      : const Color(0xFFE0E0E0); // Light border
      
  Color get textColor => _isDarkMode 
      ? const Color(0xFFE6EDF3) // Light text
      : const Color(0xFF24292F); // Dark text
  
  List<Color> get gradientColors => [
    backgroundColor,
    backgroundColor.withValues(alpha: 0.8),
    _primaryColor.withValues(alpha: 0.1)
  ];
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  void randomizeTheme() {
    final random = Random();
    final themes = _eurovisionMode ? _eurovisionThemes : _codeThemes;
    final themeIndex = random.nextInt(themes.length);
    
    _primaryColor = themes[themeIndex][0];
    _secondaryColor = themes[themeIndex][1];
    _accentColor = themes[themeIndex][2];
    
    notifyListeners();
  }
  
  void setCustomTheme(Color primary, Color secondary, Color accent) {
    _primaryColor = primary;
    _secondaryColor = secondary;
    _accentColor = accent;
    
    notifyListeners();
  }
  
  void setEurovisionMode(bool enabled) {
    _eurovisionMode = enabled;
    // Apply a Eurovision theme if enabled
    if (enabled) {
      final random = Random();
      final themeIndex = random.nextInt(_eurovisionThemes.length);
      _primaryColor = _eurovisionThemes[themeIndex][0];
      _secondaryColor = _eurovisionThemes[themeIndex][1];
      _accentColor = _eurovisionThemes[themeIndex][2];
    }
    notifyListeners();
  }
  
  // For Material app theme configuration
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}