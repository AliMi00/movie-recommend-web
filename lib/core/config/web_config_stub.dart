String? getRuntimeApiBaseUrl() => null;
String? getRuntimeDemoEmail() => null;
String? getRuntimeDemoPassword() => null;

// Non-web builds (Android/iOS) have no index.html to inject into, so these
// always fall back to the compile-time --dart-define values.
String? getRuntimePosthogKey() => null;
String? getRuntimePosthogHost() => null;
