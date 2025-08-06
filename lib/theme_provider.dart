import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  Color _primaryColor = Colors.orange;
  String _selectedTheme = 'Orange';
  Locale _currentLocale = const Locale('es', 'ES'); // Default to Spanish

  Color get primaryColor => _primaryColor;
  String get selectedTheme => _selectedTheme;
  Locale get currentLocale => _currentLocale;

  static const Map<String, Color> themes = {
    'Orange': Colors.orange,
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Green': Colors.green,
    'Purple': Colors.purple,
  };

  ThemeProvider() {
    _loadTheme();
    _loadLocale();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedTheme = prefs.getString('selected_theme') ?? 'Orange';
    _primaryColor = themes[_selectedTheme] ?? Colors.orange;
    notifyListeners();
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _currentLocale = Locale(languageCode, languageCode == 'es' ? 'ES' : 'US');
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    if (themes.containsKey(themeName)) {
      _selectedTheme = themeName;
      _primaryColor = themes[themeName]!;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_theme', _selectedTheme);

      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  ThemeData get themeData => ThemeData(
    primarySwatch: _createMaterialColor(_primaryColor),
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
