// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crossfit_timer_pro/main.dart';
import 'package:crossfit_timer_pro/theme_provider.dart';
import 'package:crossfit_timer_pro/language_provider.dart';

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
        ],
        child: const CrossFitTimerApp(),
      ),
    );

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the home screen loads with timer options
    expect(find.text('Workout Timer'), findsAny);
    expect(find.text('AMRAP'), findsOneWidget);
    expect(find.text('EMOM'), findsOneWidget);
    expect(find.text('TABATA'), findsOneWidget);
    expect(find.text('COUNTDOWN'), findsOneWidget);
  });
}
