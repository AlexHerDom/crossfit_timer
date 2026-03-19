import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para SystemChrome
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'localization.dart';
import 'services/license_manager.dart';
import 'services/analytics_manager.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicios
  await LicenseManager.initialize();
  await AnalyticsManager.initialize();
  await NotificationService.initialize();
  await MobileAds.instance.initialize();

  // Configurar orientación vertical para toda la app
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AdService()),
      ],
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
