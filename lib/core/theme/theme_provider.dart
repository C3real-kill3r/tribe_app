import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _accentColor = const Color(0xFFF9A826); // Default Warm Amber
  double _fontSizeMultiplier = 1.0; // 1.0 = 100%, range: 0.8 to 1.2 (80% to 120%)

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get accentColor => _accentColor;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }

  void setFontSizeMultiplier(double multiplier) {
    // Clamp between 0.8 (80%) and 1.2 (120%)
    _fontSizeMultiplier = multiplier.clamp(0.8, 1.2);
    notifyListeners();
  }

  // Convert slider value (0-100) to multiplier (0.8-1.2)
  double sliderToMultiplier(double sliderValue) {
    // Map 0-100 to 0.8-1.2
    return 0.8 + (sliderValue / 100) * 0.4;
  }

  // Convert multiplier (0.8-1.2) to slider value (0-100)
  double multiplierToSlider(double multiplier) {
    // Map 0.8-1.2 to 0-100
    return ((multiplier - 0.8) / 0.4) * 100;
  }
}

