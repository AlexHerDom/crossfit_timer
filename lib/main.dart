import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CrossFitTimerApp());
}

class CrossFitTimerApp extends StatefulWidget {
  const CrossFitTimerApp({super.key});

  @override
  State<CrossFitTimerApp> createState() => _CrossFitTimerAppState();
}

class _CrossFitTimerAppState extends State<CrossFitTimerApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeString = prefs.getString('theme_mode');
    setState(() {
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  void changeTheme(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = themeMode;
    });
    
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await prefs.setString('theme_mode', themeString);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrossFit Timer',
      themeMode: _themeMode,
      theme: ThemeData(
        // Tema claro deportivo
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange.shade400,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        // Tema oscuro deportivo
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.orange,
        ),
      ),
      home: HomeScreen(changeTheme: changeTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}
