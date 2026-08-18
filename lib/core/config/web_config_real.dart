import 'dart:js_interop';

@JS('CINEJO_API_BASE_URL')
external JSString? get _runtimeApiBaseUrl;

@JS('CINEJO_DEMO_EMAIL')
external JSString? get _runtimeDemoEmail;

@JS('CINEJO_DEMO_PASSWORD')
external JSString? get _runtimeDemoPassword;

String? getRuntimeApiBaseUrl() {
  try {
    final val = _runtimeApiBaseUrl;
    if (val != null) {
      final s = val.toDart;
      if (s.isNotEmpty && !s.startsWith('__')) return s;
    }
  } catch (_) {}
  return null;
}

String? getRuntimeDemoEmail() {
  try {
    final val = _runtimeDemoEmail;
    if (val != null) {
      final s = val.toDart;
      if (s.isNotEmpty && !s.startsWith('__')) return s;
    }
  } catch (_) {}
  return null;
}

String? getRuntimeDemoPassword() {
  try {
    final val = _runtimeDemoPassword;
    if (val != null) {
      final s = val.toDart;
      if (s.isNotEmpty && !s.startsWith('__')) return s;
    }
  } catch (_) {}
  return null;
}
