import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  Color get primaryColor => _isDarkMode ? const Color(0xFF2D46B9) : const Color(0xFF1E3A8A);
  Color get surfaceColor => _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get backgroundColor => _isDarkMode ? const Color(0xFF121212) : Colors.grey[100]!;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get borderColor => _isDarkMode ? Colors.white24 : Colors.black12;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

extension ColorExtension on Color {
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromARGB(
      (alpha != null ? (alpha * 255).round() : this.alpha),
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
