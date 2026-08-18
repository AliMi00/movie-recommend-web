import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cinejo_frontend/data/models/user_model.dart';
import 'package:cinejo_frontend/data/repositories/auth_repository.dart';
import 'package:cinejo_frontend/features/auth/providers/auth_provider.dart';
import 'package:cinejo_frontend/features/auth/screens/forgot_password_screen.dart';

/// Records exactly what was asked of it and returns a scripted result —
/// enough to prove the screen calls the real auth flow instead of the old
/// `Future.delayed` stub, without needing a live backend.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.forgotPasswordResult = true});

  final bool forgotPasswordResult;
  String? lastForgotPasswordEmail;

  @override
  Future<bool> forgotPassword(String email) async {
    lastForgotPasswordEmail = email;
    return forgotPasswordResult;
  }

  @override
  Future<bool> resendVerificationEmail(String email) async => true;

  @override
  Future<AuthResult> login(String email, String password) async =>
      AuthResult.failure('not used in this test');
  @override
  Future<AuthResult> register(String email, String password, String username) async =>
      AuthResult.failure('not used in this test');
  @override
  Future<void> logout() async {}
  @override
  Future<bool> deleteAccount() async => false;
  @override
  Future<User?> getCurrentUser() async => null;
  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {}
  @override
  Future<UserPreferences?> getUserPreferences() async => null;
  @override
  Future<Map<String, dynamic>> getUserStats() async => {};
}

Widget _harness(_FakeAuthRepository repo) {
  final router = GoRouter(
    initialLocation: '/forgot-password',
    routes: [
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('LOGIN'))),
    ],
  );
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('submitting a valid email calls the real API and shows success', (tester) async {
    final repo = _FakeAuthRepository();
    await tester.pumpWidget(_harness(repo));

    await tester.enterText(find.byType(TextFormField), 'someone@example.com');
    await tester.tap(find.text('Send Reset Link'));
    // Not pumpAndSettle: the old implementation had a real 2-second delay
    // (Future.delayed), so a bounded pump proves the new one doesn't rely on
    // one — this would time out well before 2s if that stub ever came back.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repo.lastForgotPasswordEmail, 'someone@example.com');
    expect(find.text('Email Sent!'), findsOneWidget);
  });

  testWidgets('a failed request shows an error, not a false success', (tester) async {
    final repo = _FakeAuthRepository(forgotPasswordResult: false);
    await tester.pumpWidget(_harness(repo));

    await tester.enterText(find.byType(TextFormField), 'someone@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Email Sent!'), findsNothing);
    expect(find.textContaining('Could not reach the server'), findsOneWidget);
  });
}
