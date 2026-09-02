import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinreco/core/constants/app_constants.dart';
import 'package:cinreco/data/services/local_storage_service.dart';
import 'package:cinreco/features/onboarding/screens/onboarding_screen.dart';

/// Minimal two-route harness: the intro finishes by navigating to the welcome
/// route, so the test needs a real router to observe that it happened.
Widget _harness() {
  final router = GoRouter(
    initialLocation: AppConstants.onboardingRoute,
    routes: [
      GoRoute(
        path: AppConstants.onboardingRoute,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppConstants.welcomeRoute,
        builder: (_, __) => const Scaffold(body: Text('WELCOME')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('advances through every slide and ends on Get Started', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // First slide is showing, with Skip available.
    expect(find.text(kOnboardingPages.first.title), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Walk to the last slide.
    for (var i = 0; i < kOnboardingPages.length - 1; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text(kOnboardingPages.last.title), findsOneWidget);
    // The last slide swaps the CTA and retires Skip, since the CTA now
    // finishes the flow itself.
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('completing the intro records the flag and leaves the carousel', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    for (var i = 0; i < kOnboardingPages.length - 1; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME'), findsOneWidget);

    final storage = await LocalStorageService.getInstance();
    expect(await storage.hasSeenOnboardingIntro(), isTrue);
  });

  testWidgets('skipping from the first slide also records the flag', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME'), findsOneWidget);

    // Skipping still counts as "seen" — the intro must not reappear on the
    // next launch just because the user opted out of reading it.
    final storage = await LocalStorageService.getInstance();
    expect(await storage.hasSeenOnboardingIntro(), isTrue);
  });
}
