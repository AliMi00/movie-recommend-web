import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/private_project_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(email, password);

    if (success && mounted) {
      final authState = ref.read(authProvider);

      // Navigate based on user state
      if (authState.isFirstTimeUser) {
        context.go('/preferences');
      } else {
        context.go('/home');
      }
    }
  }

  /// Fills in the shared demo credentials (configured per-deployment via
  /// [AppConfig.demoEmail]/[demoPassword]) and signs in immediately, so a
  /// recruiter/visitor can try the app without registering their own account.
  Future<void> _handleDemoLogin() async {
    final config = ref.read(appConfigProvider);
    if (!config.hasDemoAccount) return;
    _emailController.text = config.demoEmail;
    _passwordController.text = config.demoPassword;
    await _handleLogin();
  }

  void _handleForgotPassword() {
    context.go('/forgot-password');
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$provider login coming soon!')));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: Stack(
          children: [
            // Ambient top glow
            Positioned(
              top: -150,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.8,
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const AuthLogo(size: 60),
                      const SizedBox(height: 32),

                      Text(
                        'Welcome Back',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sign in to continue your journey',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),
                      const PrivateProjectBanner(),

                      const SizedBox(height: 24),

                      AutofillGroup(
                        child: Column(
                          children: [
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.email_outlined,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icons.lock_outline,
                              autofillHints: const [AutofillHints.password],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(
                                  () => _rememberMe = value ?? false,
                                ),
                                activeColor: AppColors.tertiary,
                              ),
                              Text(
                                'Remember me',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _handleForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      AuthButton(
                        text: 'Sign In',
                        onPressed: _handleLogin,
                        isLoading: authState.isLoading,
                      ),

                      if (ref.watch(appConfigProvider).hasDemoAccount) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: authState.isLoading
                                ? null
                                : _handleDemoLogin,
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: const Text('Continue with Demo Account'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.tertiary,
                              side: BorderSide(
                                color: AppColors.tertiary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (authState.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                onPressed: () => ref
                                    .read(authProvider.notifier)
                                    .clearError(),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      const AuthDivider(text: 'Or continue with'),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: SocialAuthButton(
                              provider: 'Google',
                              icon: Icons.account_circle,
                              onPressed: () => _handleSocialLogin('Google'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SocialAuthButton(
                              provider: 'Apple',
                              icon: Icons.apple,
                              onPressed: () => _handleSocialLogin('Apple'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
