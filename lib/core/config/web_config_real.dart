import 'dart:js_interop';

@JS('CINRECO_API_BASE_URL')
external JSString? get _runtimeApiBaseUrl;

@JS('CINRECO_DEMO_EMAIL')
external JSString? get _runtimeDemoEmail;

@JS('CINRECO_DEMO_PASSWORD')
external JSString? get _runtimeDemoPassword;

@JS('POSTHOG_API_KEY')
external JSString? get _runtimePosthogKey;

@JS('POSTHOG_HOST')
external JSString? get _runtimePosthogHost;

/// Reads a value the container entrypoint substituted into index.html at
/// startup. An un-substituted placeholder still looks like `__NAME__`, which
/// is treated as "not configured" rather than passed on as a literal.
String? _read(JSString? value) {
  try {
    if (value != null) {
      final s = value.toDart;
      if (s.isNotEmpty && !s.startsWith('__')) return s;
    }
  } catch (_) {}
  return null;
}

String? getRuntimeApiBaseUrl() => _read(_runtimeApiBaseUrl);
String? getRuntimeDemoEmail() => _read(_runtimeDemoEmail);
String? getRuntimeDemoPassword() => _read(_runtimeDemoPassword);
String? getRuntimePosthogKey() => _read(_runtimePosthogKey);
String? getRuntimePosthogHost() => _read(_runtimePosthogHost);
