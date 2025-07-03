// Eurovision-themed coding moods enum
enum CodingMood {
  productive('You\'re in a productive flow, like Loreen\'s "Euphoria" 🇸🇪'),
  debugging('Deep in debugging mode, channeling "Rise Like a Phoenix" 🇦🇹'),
  creative('Your creative energy matches "Shum" by Go_A 🇺🇦'),
  victory('Celebrating wins like "Waterloo" by ABBA 🇸🇪'),
  reflective('In a reflective state, like "Arcade" by Duncan Laurence 🇳🇱'),
  frustrated('Feeling frustrated, like "My Heart Will Go On" struggles 🇨🇦'),
  focused('Laser-focused like "Hold Me Closer" by Cornelia Jakobs 🇸🇪'),
  experimental('Experimenting boldly like "Stefania" by Kalush Orchestra 🇺🇦');

  final String description;
  const CodingMood(this.description);

  String get displayName {
    switch (this) {
      case CodingMood.productive:
        return 'Productive';
      case CodingMood.debugging:
        return 'Debugging';
      case CodingMood.creative:
        return 'Creative';
      case CodingMood.victory:
        return 'Victory';
      case CodingMood.reflective:
        return 'Reflective';
      case CodingMood.frustrated:
        return 'Frustrated';
      case CodingMood.focused:
        return 'Focused';
      case CodingMood.experimental:
        return 'Experimental';
    }
  }

  static CodingMood fromString(String value) {
    try {
      return CodingMood.values.firstWhere(
        (mood) => mood.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return CodingMood.productive;
    }
  }

  String toJson() => name;
  static CodingMood fromJson(String json) => fromString(json);
}
