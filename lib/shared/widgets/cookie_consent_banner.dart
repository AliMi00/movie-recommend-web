import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/analytics/analytics_service.dart';

/// Wraps [child] and overlays a cookie-consent banner on web until the
/// visitor accepts or declines analytics tracking. No-op on mobile, where
/// app store review — not a cookie banner — governs data disclosure.
class CookieConsentBanner extends StatefulWidget {
  final Widget? child;
  const CookieConsentBanner({super.key, required this.child});

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<CookieConsentBanner> {
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    if (!kIsWeb) return;
    final consent = await AnalyticsService.getCookieConsent();
    if (mounted && consent == null) {
      setState(() => _showBanner = true);
    }
  }

  Future<void> _respond(bool accepted) async {
    await AnalyticsService.setCookieConsent(accepted);
    if (mounted) setState(() => _showBanner = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (_showBanner)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Material(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: const Text(
                          'We use cookies for basic analytics to improve CineJo. You can accept or decline — this doesn\'t affect core app functionality.',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _respond(false),
                            child: const Text('Decline'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _respond(true),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
