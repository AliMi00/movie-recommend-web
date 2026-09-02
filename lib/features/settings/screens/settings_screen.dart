import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/local_storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../discovery/screens/discovery_screen.dart'; // for genres list reuse

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Wipes liked/disliked/history and watchlist. Destructive and not
  /// recoverable, so it asks first rather than firing straight off the tap.
  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear user data?'),
        content: const Text(
          'This permanently clears your liked and disliked movies, swipe '
          'history, and watchlist. Your account and preferences are kept. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Clear data'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final storage = await LocalStorageService.getInstance();
    await storage.clearUserData();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User data cleared')));
    }
  }

  Future<void> _showAboutDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('About CinReco'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text('Credits', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'This product uses the TMDB API but is not endorsed or certified by TMDB.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Reopens the first-run intro carousel on demand. Clearing the stored flag
  /// first means that if the user backs out midway it will still be waiting
  /// for them, matching what a fresh install would do.
  Future<void> _replayIntro() async {
    final storage = await LocalStorageService.getInstance();
    await storage.saveBool(AppConstants.onboardingIntroSeenKey, false);
    if (!mounted) return;
    context.push(AppConstants.onboardingRoute);
  }

  Future<void> _resendVerification() async {
    final email = ref.read(authProvider).user?.email;
    if (email == null) return;
    final sent = await ref
        .read(authProvider.notifier)
        .resendVerificationEmail(email);
    if (!mounted) return;
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

  Future<void> _quickEditGenres() async {
    final genres = ref.read(selectedGenresProvider);
    final selected = {...genres};
    final allGenres = [
      'Action',
      'Adventure',
      'Drama',
      'Romance',
      'Comedy',
      'Science Fiction',
      'Horror',
      'Thriller',
    ];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.outline,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.category, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Preferred Genres',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allGenres.map((g) {
                        final active = selected.contains(g);
                        return FilterChip(
                          label: Text(g),
                          selected: active,
                          onSelected: (_) {
                            setModal(() {
                              if (active) {
                                selected.remove(g);
                              } else {
                                selected.add(g);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(selectedGenresProvider.notifier).state =
                                  selected;
                              Navigator.of(ctx).pop();
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailVerified = ref.watch(authProvider).user?.emailVerified ?? true;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (!emailVerified)
            ListTile(
              leading: const Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.error,
              ),
              title: const Text('Verify your email'),
              subtitle: const Text('Tap to resend the verification link'),
              onTap: _resendVerification,
            ),
          ListTile(
            leading: const Icon(Icons.flash_on),
            title: const Text('Quick Edit Preferred Genres'),
            subtitle: const Text('Inline adjust'),
            onTap: _quickEditGenres,
          ),
          ListTile(
            leading: const Icon(Icons.replay_rounded),
            title: const Text('Replay Intro'),
            subtitle: const Text('Show the welcome walkthrough again'),
            onTap: _replayIntro,
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear User Data'),
            subtitle: const Text('Reset liked/disliked/history and watchlist'),
            onTap: _resetData,
            trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Legal & Support',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms of service and use'),
            onTap: () => context.push(AppConstants.termsRoute),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our data privacy policy'),
            onTap: () => context.push(AppConstants.privacyRoute),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility_new_rounded),
            title: const Text('Accessibility Statement'),
            subtitle: const Text('Conformance status and known gaps'),
            onTap: () => context.push(AppConstants.accessibilityRoute),
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0 • Credits'),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _showAboutDialog,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
