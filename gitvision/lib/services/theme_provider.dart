import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Eurovision signature colors
  final Color _primaryColor = const Color(0xFFD80056); // Eurovision Pink
  final Color _secondaryColor = const Color(0xFF00A0E4); // Eurovision Blue
  final Color _accentColor = const Color(0xFFFFC700); // Eurovision Gold
  
  // Basic colors for Phase 2
  final backgroundColor = const Color(0xFFF8F9FA);
  final surfaceColor = const Color(0xFFFFFFFF);
  final textColor = const Color(0xFF24292F);
  ];
  
  // Developer-focused themes
  final List<List<Color>> _codeThemes = [
    [const Color(0xFF007ACC), const Color(0xFF4FC3F7), const Color(0xFFE3F2FD)], // VS Code Blue
    [const Color(0xFF0D1117), const Color(0xFF161B22), const Color(0xFF21262D)], // GitHub Dark
    [const Color(0xFFFF6B35), const Color(0xFFFF8A65), const Color(0xFFFFF3E0)], // Git Orange
    [const Color(0xFF9C27B0), const Color(0xFFBA68C8), const Color(0xFFF3E5F5)], // Terminal Purple
    [const Color(0xFF4CAF50), const Color(0xFF81C784), const Color(0xFFE8F5E8)], // Matrix Green
    [const Color(0xFFFF5722), const Color(0xFFFF7043), const Color(0xFFFBE9E7)], // Error Red
  ];
  
  // Simple getters for basic theme
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  
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
  
  // Simple theme configuration for Phase 2
  ThemeData get theme => ThemeData(
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}