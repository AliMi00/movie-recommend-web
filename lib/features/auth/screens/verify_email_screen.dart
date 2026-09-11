import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_logo.dart';

/// Where a signed-in but unverified account lands.
///
/// The backend gates every user-data endpoint behind get_verified_user_id and
/// answers 403 EMAIL_NOT_VERIFIED, so without this screen an unverified user
/// would reach the app proper and watch every panel fail with no explanation.
/// Sign-in itself still succeeds on purpose — that is what gives us an
/// authenticated context to show this, resend from, and re-check in.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _sending = false;
  bool _checking = false;

  /// Seconds left before the resend button is usable again.
  ///
  /// The server allows 3 resends per hour per IP and answers 429 beyond that.
  /// Without a cooldown here, an impatient tap-tap-tap burns the whole hour's
  /// allowance in a couple of seconds and the person is then locked out of the
  /// one action that unblocks them. This is a courtesy brake, not the control
  /// — the server limit is what actually enforces it.
  int _cooldown = 0;
  Timer? _cooldownTimer;

  static const _cooldownSeconds = 60;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown -= 1);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _resend() async {
    final email = ref.read(authProvider).user?.email;
    if (email == null || _sending || _cooldown > 0) return;
    setState(() => _sending = true);
    final failure = await ref
        .read(authProvider.notifier)
        .resendVerificationEmail(email);
    if (!mounted) return;
    setState(() => _sending = false);

    // Start the cooldown either way. A 429 especially must not be followed by
    // an immediately-tappable button that can only produce another 429.
    _startCooldown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure ?? 'Verification email sent — check your inbox.'),
      ),
    );
  }

  Future<void> _recheck() async {
    if (_checking) return;
    setState(() => _checking = true);
    // Re-fetches /users/me. The gate reads the database rather than a JWT
    // claim, so a link clicked seconds ago is already in effect — no
    // re-login or token refresh needed.
    await ref.read(authProvider.notifier).refresh();
    if (!mounted) return;
    setState(() => _checking = false);

    final verified = ref.read(authProvider).user?.emailVerified ?? false;
    if (verified) {
      if (!mounted) return;
      context.go(AppConstants.homeRoute);
      return;
    }

    // Deliberately covers two cases with one message. Arriving here from
    // registration means there is no session at all — /auth/register issues
    // no tokens — so this re-check cannot confirm anything even if the link
    // was clicked a moment ago, and signing in is the way forward. Arriving
    // from login means there is a session and the link genuinely hasn't been
    // clicked yet. Claiming "still not verified" outright would be wrong in
    // the first case.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Not confirmed yet. If you've just clicked the link, sign in to continue.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authProvider).user?.email;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AuthLogo(size: 88)),
                  const SizedBox(height: 32),
                  Text(
                    'Confirm your email',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    email == null
                        ? 'We sent you a link to confirm your email address. Click it, then come back here.'
                        : 'We sent a link to $email. Click it to activate your account, then come back here.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthButton(
                    text: _checking ? 'Checking…' : "I've confirmed it",
                    onPressed: _checking ? null : _recheck,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: (_sending || _cooldown > 0) ? null : _resend,
                    child: Text(
                      _sending
                          ? 'Sending…'
                          : _cooldown > 0
                          ? 'Resend available in ${_cooldown}s'
                          : 'Resend the email',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _cooldown > 0
                            ? AppColors.onSurfaceVariant
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Check your spam folder if it hasn't arrived.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // "Sign in" rather than "Sign out": someone who just
                  // registered was never signed in (register issues no
                  // tokens), so this is the step that actually gets them into
                  // the app once they've clicked the link. Clearing state
                  // first keeps a half-registered session from lingering.
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go(AppConstants.loginRoute);
                    },
                    child: Text(
                      'Back to sign in',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
