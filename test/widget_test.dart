// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinejo_frontend/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Without this the platform channel never answers, the splash screen's
    // storage read hangs, and pumpAndSettle spins on its loading indicator.
    // Marking the intro as seen keeps this test on the pre-onboarding path.
    SharedPreferences.setMockInitialValues({'onboarding_intro_seen': true});

    await tester.pumpWidget(const ProviderScope(child: CinejoApp()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    expect(find.byType(CinejoApp), findsOneWidget);
  });
}
