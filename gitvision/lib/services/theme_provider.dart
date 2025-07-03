import 'dart:math';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = const Color(0xFF1DB954); // Spotify green
  Color _secondaryColor = const Color(0xFF1ED760); // Lighter Spotify green
  Color _accentColor = const Color(0xFFFFFFFF);
  bool _isDarkMode = true;
  
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
    final themeIndex = random.nextInt(_codeThemes.length);
    
    _primaryColor = _codeThemes[themeIndex][0];
    _secondaryColor = _codeThemes[themeIndex][1];
    _accentColor = _codeThemes[themeIndex][2];
    
    notifyListeners();
  }
  
  void setCustomTheme(Color primary, Color secondary, Color accent) {
    _primaryColor = primary;
    _secondaryColor = secondary;
    _accentColor = accent;
    
    notifyListeners();
  }
}