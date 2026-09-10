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

  Future<void> _resend() async {
    final email = ref.read(authProvider).user?.email;
    if (email == null || _sending) return;
    setState(() => _sending = true);
    final sent = await ref
        .read(authProvider.notifier)
        .resendVerificationEmail(email);
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Verification email sent — check your inbox.'
              : 'Could not reach the server. Try again shortly.',
        ),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Still not verified. Click the link in the email, then try again.",
          ),
        ),
      );
    }
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
                    onPressed: _sending ? null : _resend,
                    child: Text(
                      _sending ? 'Sending…' : 'Resend the email',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondary,
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
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go(AppConstants.welcomeRoute);
                    },
                    child: Text(
                      'Sign out',
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
