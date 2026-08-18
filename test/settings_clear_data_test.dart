import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinejo_frontend/core/constants/app_constants.dart';
import 'package:cinejo_frontend/data/services/local_storage_service.dart';
import 'package:cinejo_frontend/features/settings/screens/settings_screen.dart';

Widget _harness() =>
    const ProviderScope(child: MaterialApp(home: SettingsScreen()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      AppConstants.likedMoviesKey: <String>['1', '2'],
      'is_authenticated': true,
    });
  });

  testWidgets('Clear User Data asks before wiping anything', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear User Data'));
    await tester.pumpAndSettle();

    expect(find.text('Clear user data?'), findsOneWidget);

    // Backing out must leave the data untouched.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final storage = await LocalStorageService.getInstance();
    expect((await storage.getLikedMovies()).length, 2);
  });

  testWidgets('confirming the dialog clears the data', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear User Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear data'));
    await tester.pumpAndSettle();

    final storage = await LocalStorageService.getInstance();
    expect(await storage.getLikedMovies(), isEmpty);
  });

  testWidgets('the broken Edit Preferences entry is gone', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // It routed via Navigator.pushNamed, which resolves to nothing under
    // GoRouter, so tapping it silently did nothing.
    expect(find.text('Edit Preferences'), findsNothing);
  });
}
