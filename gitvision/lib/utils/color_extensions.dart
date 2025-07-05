import 'package:flutter/material.dart';

/// Extension on Color class for Eurovision-themed operations
extension ColorExtensions on Color {
  /// Creates a new color with specified alpha value
  /// This is used throughout the app for opacity manipulation
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? this.opacity,
    );
  }

  /// Brightens the color by the given factor
  Color brighten(double factor) {
    assert(factor >= 0 && factor <= 1, 'Factor must be between 0 and 1');
    return Color.fromRGBO(
      (red + ((255 - red) * factor)).round().clamp(0, 255),
      (green + ((255 - green) * factor)).round().clamp(0, 255),
      (blue + ((255 - blue) * factor)).round().clamp(0, 255),
      opacity,
    );
  }

  /// Darkens the color by the given factor
  Color darken(double factor) {
    assert(factor >= 0 && factor <= 1, 'Factor must be between 0 and 1');
    return Color.fromRGBO(
      (red * (1 - factor)).round(),
      (green * (1 - factor)).round(),
      (blue * (1 - factor)).round(),
      opacity,
    );
  }

  /// Gets a Eurovision-themed complementary color
  Color get eurovisionComplement {
    final hslColor = HSLColor.fromColor(this);
    final complementHue = (hslColor.hue + 180) % 360;
    return HSLColor.fromAHSL(
      hslColor.alpha,
      complementHue,
      hslColor.saturation,
      hslColor.lightness,
    ).toColor();
  }

  /// Gets a Eurovision-themed analogous color
  Color eurovisionAnalogous(bool clockwise) {
    final hslColor = HSLColor.fromColor(this);
    final shift = clockwise ? 30 : -30;
    final newHue = (hslColor.hue + shift) % 360;
    return HSLColor.fromAHSL(
      hslColor.alpha,
      newHue,
      hslColor.saturation,
      hslColor.lightness,
    ).toColor();
  }
}
