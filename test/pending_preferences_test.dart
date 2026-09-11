import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinreco/core/constants/app_constants.dart';
import 'package:cinreco/data/services/local_storage_service.dart';
import 'package:cinreco/features/onboarding/pending_preferences.dart';

/// The intro asks for genres and a rating before an account exists, because
/// that is when someone is willing to answer. PUT /users/me/preferences needs
/// a verified account, which doesn't exist until two steps later — so the
/// answers have to survive account creation, an email link and a fresh
/// sign-in, quite possibly with the app rebuilt from scratch in between.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // LocalStorageService caches its SharedPreferences instance in a singleton,
  // so setMockInitialValues alone doesn't reset what a previous test wrote —
  // clear through the same path the app uses to keep these order-independent.
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PendingPreferences.clear();
  });

  test('round-trips the answers', () async {
    await PendingPreferences.save(
      const PendingPreferences(genres: ['Drama', 'Sci-Fi'], minRating: 7.5),
    );

    final loaded = await PendingPreferences.load();
    expect(loaded, isNotNull);
    expect(loaded!.genres, ['Drama', 'Sci-Fi']);
    expect(loaded.minRating, 7.5);
  });

  test('returns null when nothing was parked', () async {
    expect(await PendingPreferences.load(), isNull);
  });

  test('clearing removes them', () async {
    await PendingPreferences.save(
      const PendingPreferences(genres: ['Horror'], minRating: 5),
    );
    await PendingPreferences.clear();
    expect(await PendingPreferences.load(), isNull);
  });

  test('corrupt storage does not throw', () async {
    // Planted through the same storage the app reads, not via
    // setMockInitialValues: LocalStorageService caches its instance, so the
    // mock setter wouldn't reach it and this would pass without ever
    // exercising the parse.
    final storage = await LocalStorageService.getInstance();
    await storage.saveString(
      AppConstants.pendingPreferencesKey,
      'not json at all',
    );

    // Sanity: the bad value really is there to be read.
    expect(storage.getString(AppConstants.pendingPreferencesKey), isNotEmpty);

    // A launch must not fail because of a half-written or outdated value.
    expect(await PendingPreferences.load(), isNull);
  });

  test(
    'a partial record is treated as absent rather than half-applied',
    () async {
      final storage = await LocalStorageService.getInstance();
      // minRating missing: applying half of someone's answers silently would
      // be worse than asking again.
      await storage.saveString(
        AppConstants.pendingPreferencesKey,
        '{"genres":["Drama"]}',
      );
      expect(storage.getString(AppConstants.pendingPreferencesKey), isNotEmpty);

      expect(await PendingPreferences.load(), isNull);
    },
  );

  test('preserves the existing theme when converting', () async {
    const prefs = PendingPreferences(genres: ['Comedy'], minRating: 6);
    // The intro never asks about theme, so syncing these answers must not
    // quietly flip whatever the user already has.
    expect(prefs.toUserPreferences(isDarkTheme: false).isDarkTheme, isFalse);
    expect(prefs.toUserPreferences(isDarkTheme: true).isDarkTheme, isTrue);
  });
}
