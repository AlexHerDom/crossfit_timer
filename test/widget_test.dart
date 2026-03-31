// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crossfit_timer/main.dart';
import 'package:crossfit_timer/theme_provider.dart';
import 'package:crossfit_timer/language_provider.dart';
import 'package:crossfit_timer/services/ad_service.dart';
import 'package:crossfit_timer/services/gamification_service.dart';

void main() {
  testWidgets('CrossFit Timer app starts correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          ChangeNotifierProvider(create: (context) => AdService()),
          ChangeNotifierProvider(create: (context) => GamificationService()),
        ],
        child: const CrossFitTimerApp(),
      ),
    );

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the home screen loads with timer options
    expect(find.text('CrossFit Timer Pro'), findsOneWidget);
    expect(find.text('AMRAP'), findsOneWidget);
    expect(find.text('EMOM'), findsOneWidget);
    expect(find.text('TABATA'), findsOneWidget);
    expect(find.text('COUNTDOWN'), findsOneWidget);
  });
}
