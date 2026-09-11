import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/services/local_storage_service.dart';

/// Genre and rating choices captured during the intro, before an account
/// exists to attach them to.
///
/// The intro asks for these up front because that is when someone is willing
/// to answer — but PUT /users/me/preferences requires a verified account, and
/// at that point in the flow there is neither. So the answers wait here and
/// are pushed the first time the app runs with a verified, signed-in user.
///
/// Stored rather than held in memory because the round trip goes through
/// account creation, an email link, and a fresh sign-in — quite possibly in a
/// different tab, and certainly after the app has been rebuilt from scratch.
class PendingPreferences {
  final List<String> genres;
  final double minRating;

  const PendingPreferences({required this.genres, required this.minRating});

  Map<String, dynamic> toJson() => {'genres': genres, 'minRating': minRating};

  static PendingPreferences? _fromJson(Map<String, dynamic> json) {
    final genres = (json['genres'] as List<dynamic>?)
        ?.whereType<String>()
        .toList();
    final rating = (json['minRating'] as num?)?.toDouble();
    if (genres == null || rating == null) return null;
    return PendingPreferences(genres: genres, minRating: rating);
  }

  static Future<void> save(PendingPreferences prefs) async {
    final storage = await LocalStorageService.getInstance();
    await storage.saveString(
      AppConstants.pendingPreferencesKey,
      jsonEncode(prefs.toJson()),
    );
  }

  static Future<PendingPreferences?> load() async {
    final storage = await LocalStorageService.getInstance();
    final raw = storage.getString(AppConstants.pendingPreferencesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt or from an older shape — not worth failing a launch over.
      return null;
    }
  }

  static Future<void> clear() async {
    final storage = await LocalStorageService.getInstance();
    await storage.saveString(AppConstants.pendingPreferencesKey, '');
  }

  /// Converts to the shape the preferences API expects, preserving whatever
  /// theme the user already has rather than overwriting it.
  UserPreferences toUserPreferences({required bool isDarkTheme}) =>
      UserPreferences(
        preferredGenres: genres,
        minRating: minRating,
        isDarkTheme: isDarkTheme,
      );
}
