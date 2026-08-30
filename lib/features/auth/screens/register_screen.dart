import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/private_project_banner.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _handleTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _handlePrivacyTap;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _handleTermsTap() {
    context.push(AppConstants.termsRoute);
  }

  void _handlePrivacyTap() {
    context.push(AppConstants.privacyRoute);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service')),
      );
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.register(email, password, username);

    if (success && mounted) {
      context.go('/preferences');
    }
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider registration coming soon!')),
    );
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
                        'Create Account',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Join Cinreco and start discovering',
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

                      AuthTextField(
                        controller: _usernameController,
                        label: 'Username',
                        prefixIcon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Invalid email'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
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
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'Too short' : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        validator: (v) =>
                            (v != _passwordController.text) ? 'Mismatch' : null,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (v) =>
                                setState(() => _acceptTerms = v ?? false),
                            activeColor: AppColors.tertiary,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms',
                                    style: const TextStyle(
                                      color: AppColors.tertiary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: _termsRecognizer,
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: AppColors.tertiary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: _privacyRecognizer,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      AuthButton(
                        text: 'Create Account',
                        onPressed: _handleRegister,
                        isLoading: authState.isLoading,
                      ),

                      if (authState.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            authState.error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      const AuthDivider(text: 'Or sign up with'),
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
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.tertiary,
                                fontWeight: FontWeight.bold,
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
