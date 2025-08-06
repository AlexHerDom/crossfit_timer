import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para SystemChrome
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme_provider.dart';
import 'localization.dart';

void main() {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación vertical para toda la app
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const CrossFitTimerApp(),
    ),
  );
}

class CrossFitTimerApp extends StatelessWidget {
  const CrossFitTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Workout Timer',
          theme: themeProvider.themeData,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
          // Localización
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: themeProvider.currentLocale,
        );
      },
    );
  }
}
