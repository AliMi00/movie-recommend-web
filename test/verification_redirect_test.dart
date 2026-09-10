import 'package:flutter_test/flutter_test.dart';

import 'package:cinreco/core/constants/app_constants.dart';
import 'package:cinreco/core/router/app_router.dart';

/// The router-level guard that keeps an unverified account out of the app.
///
/// The backend gates user-data endpoints behind get_verified_user_id and
/// answers 403 EMAIL_NOT_VERIFIED. Without this guard the app would still
/// navigate an unverified user to /home and render panels that all fail with
/// no explanation.
void main() {
  group('unverified account', () {
    test('is redirected away from app screens', () {
      for (final target in [
        AppConstants.homeRoute,
        AppConstants.discoveryRoute,
        AppConstants.watchHistoryRoute,
        AppConstants.settingsRoute,
        AppConstants.profileRoute,
      ]) {
        expect(
          verificationRedirect(
            isAuthenticated: true,
            emailVerified: false,
            target: target,
          ),
          AppConstants.verifyEmailRoute,
          reason: '$target should bounce to the verify screen',
        );
      }
    });

    test('may still reach the legal pages', () {
      // Linked from cinreco.com and the store listings — these have to render
      // for anyone, in any auth state.
      for (final target in [
        AppConstants.termsRoute,
        AppConstants.privacyRoute,
        AppConstants.accessibilityRoute,
      ]) {
        expect(
          verificationRedirect(
            isAuthenticated: true,
            emailVerified: false,
            target: target,
          ),
          isNull,
          reason: '$target must stay reachable while unverified',
        );
      }
    });

    test('is not bounced off the verify screen itself', () {
      // Guarding this would be an infinite redirect.
      expect(
        verificationRedirect(
          isAuthenticated: true,
          emailVerified: false,
          target: AppConstants.verifyEmailRoute,
        ),
        isNull,
      );
    });

    test('can still sign out via welcome/login', () {
      for (final target in [
        AppConstants.welcomeRoute,
        AppConstants.loginRoute,
        AppConstants.registerRoute,
      ]) {
        expect(
          verificationRedirect(
            isAuthenticated: true,
            emailVerified: false,
            target: target,
          ),
          isNull,
        );
      }
    });
  });

  group('verified account', () {
    test('navigates freely', () {
      expect(
        verificationRedirect(
          isAuthenticated: true,
          emailVerified: true,
          target: AppConstants.homeRoute,
        ),
        isNull,
      );
    });

    test('is moved off the verify screen', () {
      // What carries the user onward after they click the emailed link and
      // come back to a tab still sitting on the gate.
      expect(
        verificationRedirect(
          isAuthenticated: true,
          emailVerified: true,
          target: AppConstants.verifyEmailRoute,
        ),
        AppConstants.homeRoute,
      );
    });
  });

  test('signed-out navigation is left alone', () {
    // Splash/welcome already own that flow; the guard must not interfere or
    // it would fight them for control of the first frame.
    expect(
      verificationRedirect(
        isAuthenticated: false,
        emailVerified: false,
        target: AppConstants.homeRoute,
      ),
      isNull,
    );
  });
}
