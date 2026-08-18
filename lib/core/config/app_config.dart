import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_io_stub.dart' if (dart.library.io) 'platform_io_real.dart';
import 'web_config_stub.dart' if (dart.library.html) 'web_config_real.dart';

class AppConfig {
  final String baseUrl;
  final bool useApi;
  final bool useCookieAuth; // if true, rely on refresh cookie; else bearer token
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

  AppConfig copyWith({String? baseUrl, bool? useApi, bool? useCookieAuth, int? defaultPageSize}) {
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

final appConfigProvider = Provider<AppConfig>((ref) {
  // Allow overriding via --dart-define at build/run time. Defaults point at
  // the live public CineJo API — this is a public repo, so no private
  // network address belongs here.
  const envBaseUrlRaw = String.fromEnvironment('CINEJO_API_BASE_URL', defaultValue: 'https://api.gozaga.xyz/v1');
  const envUseApi = bool.fromEnvironment('CINEJO_USE_API', defaultValue: true);
  // Use string to support tri-state: 'true'/'false'/'auto'
  const envCookieRaw = String.fromEnvironment('CINEJO_USE_COOKIE_AUTH', defaultValue: 'false');
  const envPageSize = int.fromEnvironment('CINEJO_DEFAULT_PAGE_SIZE', defaultValue: 20);
  const envDemoEmailRaw = String.fromEnvironment('CINEJO_DEMO_EMAIL', defaultValue: '');
  const envDemoPasswordRaw = String.fromEnvironment('CINEJO_DEMO_PASSWORD', defaultValue: '');

  // Resolve base URL: runtime JS global (web) takes priority over dart-define
  String resolvedBase = getRuntimeApiBaseUrl() ?? envBaseUrlRaw;
  try {
    if (!kIsWeb && platformIsAndroid && (envBaseUrlRaw.contains('localhost') || envBaseUrlRaw.contains('127.0.0.1'))) {
      resolvedBase = envBaseUrlRaw.replaceFirst(RegExp(r'localhost|127\.0\.0\.1'), '10.0.2.2');
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
