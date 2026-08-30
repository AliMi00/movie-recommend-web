import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../../data/services/local_storage_service.dart';
import '../config/web_config_stub.dart'
    if (dart.library.html) '../config/web_config_real.dart';

class AnalyticsService {
  static final Posthog _posthog = Posthog();
  static const String _cookieConsentKey = 'cinejo_cookie_consent';

  // PostHog project tokens (phc_...) are safe to embed in client code — they
  // only allow writing events, unlike PostHog's secret personal API keys.
  // No default is baked in here: this is a public repo, so analytics stay
  // off unless a deployer supplies their own key.
  //
  // Compile-time fallback, used by the mobile builds. Web must NOT rely on
  // this: the Docker image is built once and configured at container start,
  // so a --dart-define baked at build time would always be empty there.
  static const String _compileTimeKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: '',
  );
  static const String _compileTimeHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://eu.i.posthog.com',
  );

  // Runtime value (injected into index.html by docker-entrypoint.sh) wins on
  // web, falling back to the compile-time define elsewhere. Without this the
  // Dart SDK never initialises on web, and every explicit event —
  // login_success, onboarding steps, PosthogObserver screen views — is
  // silently dropped even while posthog-js is happily autocapturing.
  static String get _apiKey => getRuntimePosthogKey() ?? _compileTimeKey;
  static String get _host => getRuntimePosthogHost() ?? _compileTimeHost;

  /// Helper to convert `Map<String, dynamic>?` into `Map<String, Object>?` safely.
  /// This removes null values because 'Object' in Dart is non-nullable.
  static Map<String, Object>? _cleanProperties(Map<String, dynamic>? source) {
    if (source == null) return null;
    final Map<String, Object> cleaned = {};
    source.forEach((key, value) {
      if (value != null) {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }

  /// Initialize analytics.
  ///
  /// On Android/iOS this performs the real SDK setup with the project token
  /// — without this call, capture()/identify() are silent no-ops since the
  /// native SDK was never initialized. On web, posthog_flutter only hooks
  /// into the posthog-js instance already started by the snippet in
  /// web/index.html (whose key is injected at deploy time); it does not
  /// re-initialize with a different key here.
  ///
  /// On web, starts opted out of tracking unless the visitor has already
  /// accepted cookies via [setCookieConsent] — [CookieConsentBanner] is
  /// responsible for asking and calling that. Mobile app stores don't
  /// require the same cookie-consent flow, so this only applies to web.
  static Future<void> initialize() async {
    if (_apiKey.isEmpty) return; // no key configured — analytics stay off
    try {
      if (kDebugMode) {
        debugPrint('AnalyticsService: Initializing PostHog...');
      }
      final config = PostHogConfig(_apiKey)
        ..host = _host
        ..debug = kDebugMode
        ..captureApplicationLifecycleEvents = true;
      if (kIsWeb) {
        config.optOut = await getCookieConsent() != true;
      }
      await _posthog.setup(config);
    } catch (e, stack) {
      debugPrint('AnalyticsService Error: Failed to initialize: $e\n$stack');
    }
  }

  /// The visitor's stored cookie-consent choice: true (accepted), false
  /// (declined), or null (no choice made yet — only meaningful on web).
  static Future<bool?> getCookieConsent() async {
    final storage = await LocalStorageService.getInstance();
    final value = storage.getString(_cookieConsentKey);
    if (value == 'accepted') return true;
    if (value == 'declined') return false;
    return null;
  }

  /// Records the visitor's cookie-consent choice and enables/disables
  /// PostHog tracking accordingly.
  static Future<void> setCookieConsent(bool accepted) async {
    final storage = await LocalStorageService.getInstance();
    await storage.saveString(
      _cookieConsentKey,
      accepted ? 'accepted' : 'declined',
    );
    try {
      if (accepted) {
        await _posthog.enable();
      } else {
        await _posthog.disable();
      }
    } catch (e, stack) {
      debugPrint(
        'AnalyticsService Error: Failed to apply cookie consent: $e\n$stack',
      );
    }
  }

  /// Resolves a PostHog feature flag/experiment variant key (e.g. "control",
  /// "streamlined"). Returns [defaultValue] if the flag hasn't loaded yet,
  /// isn't set, or PostHog is opted out — callers should always get a
  /// sensible variant back rather than needing to handle null.
  static Future<String> getFeatureFlagVariant(
    String key, {
    required String defaultValue,
  }) async {
    try {
      final result = await _posthog.getFeatureFlag(key);
      if (result is String && result.isNotEmpty) return result;
      return defaultValue;
    } catch (e, stack) {
      debugPrint(
        'AnalyticsService Error: Failed to resolve feature flag "$key": $e\n$stack',
      );
      return defaultValue;
    }
  }

  /// Track custom events with optional properties
  static void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    try {
      if (kDebugMode) {
        debugPrint(
          'AnalyticsService: Track Event "$eventName" with properties: $properties',
        );
      }
      _posthog.capture(
        eventName: eventName,
        properties: _cleanProperties(properties),
      );
    } catch (e, stack) {
      debugPrint('AnalyticsService Error: Failed to track event: $e\n$stack');
    }
  }

  /// Identify logged-in user
  static void identifyUser(
    String userId, {
    Map<String, dynamic>? userProperties,
  }) {
    try {
      if (kDebugMode) {
        debugPrint(
          'AnalyticsService: Identify User "$userId" with properties: $userProperties',
        );
      }
      _posthog.identify(
        userId: userId,
        userProperties: _cleanProperties(userProperties),
      );
    } catch (e, stack) {
      debugPrint('AnalyticsService Error: Failed to identify user: $e\n$stack');
    }
  }

  /// Reset session / clear user identity upon logout
  static void reset() {
    try {
      if (kDebugMode) {
        debugPrint('AnalyticsService: Reset User Identity');
      }
      _posthog.reset();
    } catch (e, stack) {
      debugPrint(
        'AnalyticsService Error: Failed to reset identity: $e\n$stack',
      );
    }
  }

  /// Explicitly track screen views
  static void trackScreen(String screenName) {
    try {
      if (kDebugMode) {
        debugPrint('AnalyticsService: Track Screen "$screenName"');
      }
      _posthog.screen(screenName: screenName);
    } catch (e, stack) {
      debugPrint('AnalyticsService Error: Failed to track screen: $e\n$stack');
    }
  }
}
