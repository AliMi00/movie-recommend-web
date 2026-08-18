import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';
import '../providers/group_session_providers.dart';

class GroupSessionDashboardScreen extends ConsumerStatefulWidget {
  const GroupSessionDashboardScreen({super.key});

  @override
  ConsumerState<GroupSessionDashboardScreen> createState() => _GroupSessionDashboardScreenState();
}

class _GroupSessionDashboardScreenState extends ConsumerState<GroupSessionDashboardScreen> {
  final _codeController = TextEditingController();
  final _moodController = TextEditingController();
  bool _isCreating = false;
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateSession() async {
    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      await ref.read(activeGroupSessionProvider.notifier).createSession(
            mood: _moodController.text.trim().isEmpty ? null : _moodController.text.trim(),
          );
      final activeSession = ref.read(activeGroupSessionProvider);
      if (activeSession != null && mounted) {
        context.push('/group-session/lobby/${activeSession.sessionCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create session: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _handleJoinSession() async {
    final code = _codeController.text.trim();
    if (code.length < 5) {
      setState(() {
        _errorMessage = 'Please enter a valid session code (5-6 characters).';
      });
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      await ref.read(activeGroupSessionProvider.notifier).joinSession(code);
      final activeSession = ref.read(activeGroupSessionProvider);
      if (activeSession != null && mounted) {
        context.push('/group-session/lobby/${activeSession.sessionCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to join session. Check the code and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.add_to_photos_rounded, size: 24, color: AppColors.secondary),
                    const SizedBox(width: 12),
                    Text(
                      'Create Collaborative Session',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Set the mood or vibe for your group (optional). CineJo will curate consensual matches based on this prompt!',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _moodController,
                  autofocus: true,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.psychology_outlined, color: AppColors.secondary),
                    hintText: 'e.g. fast-paced neon action thriller',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isCreating
                        ? null
                        : () async {
                            setModalState(() => _isCreating = true);
                            await _handleCreateSession();
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.onSecondaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isCreating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'LAUNCH LOBBY',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJoinBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.group_add_rounded, size: 24, color: AppColors.secondary),
                    const SizedBox(width: 12),
                    Text(
                      'Join Lobby',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the 6-character room code shared by your friend to join their swiping lobby.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _codeController,
                  autofocus: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'F3H8A9',
                    hintStyle: AppTextStyles.headlineMedium.copyWith(
                      letterSpacing: 8,
                      color: AppColors.outline.withValues(alpha: 0.3),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.length == 6) {
                      setModalState(() {});
                    }
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isJoining || _codeController.text.trim().length < 5
                        ? null
                        : () async {
                            setModalState(() => _isJoining = true);
                            await _handleJoinSession();
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.onSecondaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isJoining
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'ENTER ROOM',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invitationsAsync = ref.watch(pendingInvitationsProvider);
    final activeSession = ref.watch(activeGroupSessionProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'COLLABORATIVE ROOM',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Ambient glow blobs
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiary.withValues(alpha: 0.04),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Swipe Together. Watch Consensually.',
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Connect with friends, sync your taste preferences, and instantly find the perfect film to watch together.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          const SizedBox(height: 28),

                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.errorContainer.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().shake(duration: 300.ms),
                            const SizedBox(height: 20),
                          ],

                          // Resume ongoing session card
                          if (activeSession != null) ...[
                            GestureDetector(
                              onTap: () => context.push('/group-session/lobby/${activeSession.sessionCode}'),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(20),
                                borderRadius: 20,
                                opacity: 0.1,
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 1.5),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.play_circle_fill_rounded,
                                          color: AppColors.secondary, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ACTIVE SESSION',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.secondary,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Room Code: ${activeSession.sessionCode}',
                                            style: AppTextStyles.titleMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          if (activeSession.mood != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Mood: "${activeSession.mood}"',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                                fontStyle: FontStyle.italic,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded,
                                        color: AppColors.onSurfaceVariant, size: 18),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Creation Actions
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showCreateBottomSheet,
                                  child: GlassContainer(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                    borderRadius: 20,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add_to_photos_rounded,
                                              color: AppColors.secondary, size: 28),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Start Lobby',
                                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Host a collaborative room',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                            fontSize: 11,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showJoinBottomSheet,
                                  child: GlassContainer(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                    borderRadius: 20,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: AppColors.tertiary.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.group_add_rounded,
                                              color: AppColors.tertiary, size: 28),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Join Room',
                                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Enter shared room code',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                            fontSize: 11,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms, duration: 450.ms),

                          const SizedBox(height: 32),
                          Text(
                            'PENDING INVITATIONS',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // Invitations list
                    invitationsAsync.when(
                      data: (invites) {
                        if (invites.isEmpty) {
                          return SliverToBoxAdapter(
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                              borderRadius: 20,
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.mail_outline_rounded,
                                        size: 40, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No pending invites',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Invite notifications will show up here.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final invite = invites[index];
                              // Find matching member for current user
                              final myMember = invite.members.firstWhere(
                                (m) => m.status == 'pending',
                                orElse: () => invite.members.first,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(16),
                                  borderRadius: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.people_alt_rounded,
                                                color: AppColors.secondary, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Invitation Received',
                                                  style: AppTextStyles.bodyMedium
                                                      .copyWith(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  'Room Code: ${invite.sessionCode}',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (invite.mood != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Vibe: "${invite.mood}"',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                              color: AppColors.onSurface.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                await ref
                                                    .read(pendingInvitationsProvider.notifier)
                                                    .respond(myMember.id, 'accepted');
                                                // Automatically load active session
                                                await ref
                                                    .read(activeGroupSessionProvider.notifier)
                                                    .joinSession(invite.sessionCode);
                                                if (context.mounted) {
                                                  context.push('/group-session/lobby/${invite.sessionCode}');
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.like.withValues(alpha: 0.15),
                                                foregroundColor: AppColors.like,
                                                side: const BorderSide(color: AppColors.like, width: 0.5),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10)),
                                                elevation: 0,
                                              ),
                                              child: const Text('Accept'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () async {
                                                await ref
                                                    .read(pendingInvitationsProvider.notifier)
                                                    .respond(myMember.id, 'declined');
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: AppColors.dislike.withValues(alpha: 0.08),
                                                foregroundColor: AppColors.dislike,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: const Text('Decline'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: invites.length,
                          ),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.secondary),
                        ),
                      ),
                      error: (e, _) => SliverToBoxAdapter(
                        child: Text(
                          'Error loading invites: $e',
                          style: TextStyle(color: Colors.redAccent.shade100),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 48)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
