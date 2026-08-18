import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/analytics/analytics_service.dart';
import 'shared/widgets/cookie_consent_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean, path-based URLs on web (/watchlist instead of /#/watchlist) —
  // matches the SPA fallback nginx.conf already assumes for deep links.
  if (kIsWeb) usePathUrlStrategy();

  // Initialize analytics tracking
  await AnalyticsService.initialize();

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => const ProviderScope(
        child: CinejoApp(),
      ),
    ),
  );
}

class CinejoApp extends ConsumerWidget {
  const CinejoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      // One clay theme. It is a light design by construction — its depth
      // relies on a white highlight against a pale ground — so the app no
      // longer offers a brightness choice.
      theme: AppTheme.clayTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: (context, child) => CookieConsentBanner(
        child: DevicePreview.appBuilder(context, child),
      ),
    );
  }
}
