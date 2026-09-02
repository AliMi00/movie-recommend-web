import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_io_stub.dart' if (dart.library.io) 'platform_io_real.dart';
import 'web_config_stub.dart' if (dart.library.html) 'web_config_real.dart';

class AppConfig {
  final String baseUrl;
  final bool useApi;
  final bool
  useCookieAuth; // if true, rely on refresh cookie; else bearer token
  final int defaultPageSize;
  // Optional shared demo account, surfaced as a one-click login on the
  // welcome/login screens. Empty when not configured for this deployment.
  final String demoEmail;
  final String demoPassword;

  const AppConfig({
    required this.baseUrl,
    this.useApi = true,
    this.useCookieAuth = true,
    this.defaultPageSize = 20,
    this.demoEmail = '',
    this.demoPassword = '',
  });

  bool get hasDemoAccount => demoEmail.isNotEmpty && demoPassword.isNotEmpty;

  AppConfig copyWith({
    String? baseUrl,
    bool? useApi,
    bool? useCookieAuth,
    int? defaultPageSize,
  }) {
    return AppConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      useApi: useApi ?? this.useApi,
      useCookieAuth: useCookieAuth ?? this.useCookieAuth,
      defaultPageSize: defaultPageSize ?? this.defaultPageSize,
      demoEmail: demoEmail,
      demoPassword: demoPassword,
    );
  }
}

// Build-time configuration, supplied with --dart-define.
//
// The app was renamed from Cinejo to CinReco, so each setting is read from
// its CINRECO_ name first and falls back to the old CINEJO_ name. The
// fallback exists because a build pipeline or deployment can still be
// passing the old names: dropping them outright would silently substitute
// defaults for the demo account and analytics rather than failing loudly.
// Remove the legacy reads once nothing supplies them.
const _baseUrlNew = String.fromEnvironment('CINRECO_API_BASE_URL');
const _baseUrlOld = String.fromEnvironment('CINEJO_API_BASE_URL');
const _demoEmailNew = String.fromEnvironment('CINRECO_DEMO_EMAIL');
const _demoEmailOld = String.fromEnvironment('CINEJO_DEMO_EMAIL');
const _demoPasswordNew = String.fromEnvironment('CINRECO_DEMO_PASSWORD');
const _demoPasswordOld = String.fromEnvironment('CINEJO_DEMO_PASSWORD');
const _cookieAuthNew = String.fromEnvironment('CINRECO_USE_COOKIE_AUTH');
const _cookieAuthOld = String.fromEnvironment('CINEJO_USE_COOKIE_AUTH');

/// First non-empty of the new name, the legacy name, then the default.
String _pick(String preferred, String legacy, String fallback) {
  if (preferred.isNotEmpty) return preferred;
  if (legacy.isNotEmpty) return legacy;
  return fallback;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  // Defaults point at the live public CinReco API — this is a public repo,
  // so no private network address belongs here.
  final envBaseUrlRaw = _pick(
    _baseUrlNew,
    _baseUrlOld,
    'https://api.gozaga.xyz/v1',
  );
  // Nested fromEnvironment is itself a const expression, so the legacy name
  // supplies the default when the new one was never defined.
  const envUseApi = bool.fromEnvironment(
    'CINRECO_USE_API',
    defaultValue: bool.fromEnvironment('CINEJO_USE_API', defaultValue: true),
  );
  const envPageSize = int.fromEnvironment(
    'CINRECO_DEFAULT_PAGE_SIZE',
    defaultValue: int.fromEnvironment(
      'CINEJO_DEFAULT_PAGE_SIZE',
      defaultValue: 20,
    ),
  );
  // String rather than bool to support tri-state: 'true'/'false'/'auto'.
  final envCookieRaw = _pick(_cookieAuthNew, _cookieAuthOld, 'false');
  final envDemoEmailRaw = _pick(_demoEmailNew, _demoEmailOld, '');
  final envDemoPasswordRaw = _pick(_demoPasswordNew, _demoPasswordOld, '');

  // Resolve base URL: runtime JS global (web) takes priority over dart-define
  String resolvedBase = getRuntimeApiBaseUrl() ?? envBaseUrlRaw;
  try {
    if (!kIsWeb &&
        platformIsAndroid &&
        (envBaseUrlRaw.contains('localhost') ||
            envBaseUrlRaw.contains('127.0.0.1'))) {
      resolvedBase = envBaseUrlRaw.replaceFirst(
        RegExp(r'localhost|127\.0\.0\.1'),
        '10.0.2.2',
      );
    }
  } catch (_) {}

  // Demo credentials follow the same runtime-injection pattern as the base
  // URL, so they can be set/rotated per-deployment without a rebuild.
  final resolvedDemoEmail = getRuntimeDemoEmail() ?? envDemoEmailRaw;
  final resolvedDemoPassword = getRuntimeDemoPassword() ?? envDemoPasswordRaw;

  // Resolve cookie mode default: web=true, others=false when 'auto'
  bool cookieMode;
  switch (envCookieRaw.toLowerCase()) {
    case 'true':
      cookieMode = true;
      break;
    case 'false':
      cookieMode = false;
      break;
    default:
      cookieMode = kIsWeb; // auto
  }

  return AppConfig(
    baseUrl: resolvedBase,
    useApi: envUseApi,
    useCookieAuth: cookieMode,
    defaultPageSize: envPageSize,
    demoEmail: resolvedDemoEmail,
    demoPassword: resolvedDemoPassword,
  );
});
