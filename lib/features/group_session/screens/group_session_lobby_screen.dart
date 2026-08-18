import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/group_session_providers.dart';

class GroupSessionLobbyScreen extends ConsumerStatefulWidget {
  final String code;

  const GroupSessionLobbyScreen({super.key, required this.code});

  @override
  ConsumerState<GroupSessionLobbyScreen> createState() =>
      _GroupSessionLobbyScreenState();
}

class _GroupSessionLobbyScreenState
    extends ConsumerState<GroupSessionLobbyScreen> {
  final _emailController = TextEditingController();
  final _moodController = TextEditingController();
  bool _isInviting = false;
  String? _statusMessage;
  bool _isSuccess = false;
  bool _isEditingMood = false;
  bool _isUpdatingMood = false;

  @override
  void dispose() {
    _emailController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _statusMessage = 'Please enter a valid email address.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isInviting = true;
      _statusMessage = null;
    });

    try {
      await ref.read(activeGroupSessionProvider.notifier).inviteMember(email);
      setState(() {
        _statusMessage = 'Invitation sent to $email!';
        _isSuccess = true;
        _emailController.clear();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to send invite: $e';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isInviting = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied to clipboard!'),
        backgroundColor: AppColors.surfaceContainerHigh,
      ),
    );
  }

  Future<void> _saveMood() async {
    final newMood = _moodController.text.trim();
    setState(() {
      _isUpdatingMood = true;
    });

    try {
      await ref
          .read(activeGroupSessionProvider.notifier)
          .updateSessionMood(newMood);
      setState(() {
        _isEditingMood = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update vibe: $e'),
          backgroundColor: AppColors.dislike,
        ),
      );
    } finally {
      setState(() {
        _isUpdatingMood = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeGroupSessionProvider);
    final currentUserId = ref.watch(authProvider).user?.id;

    if (session == null) {
      return Scaffold(
        body: Container(
          color: AppColors.background,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () {
            ref.read(activeGroupSessionProvider.notifier).leaveSession();
            context.pop();
          },
        ),
        title: Text(
          'SESSION LOBBY',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.onSurface),
            onPressed: () =>
                ref.read(activeGroupSessionProvider.notifier).refreshMembers(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Glowing mesh gradient background
            Positioned(
              top: -80,
              left: -50,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            // Main Room Code Display Card
                            GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 20,
                              ),
                              borderRadius: 24,
                              child: Column(
                                children: [
                                  Text(
                                    'SHARE THIS ROOM CODE',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: _copyToClipboard,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.glassBorder,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.08),
                                            blurRadius: 16,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            session.sessionCode,
                                            style: AppTextStyles.displaySmall
                                                .copyWith(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 4,
                                                  color: AppColors.secondary,
                                                ),
                                          ),
                                          const SizedBox(width: 14),
                                          const Icon(
                                            Icons.copy_rounded,
                                            color: AppColors.secondary,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().scale(
                                    delay: 150.ms,
                                    duration: 300.ms,
                                  ),
                                  const SizedBox(height: 16),
                                  _isEditingMood
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _moodController,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color:
                                                          AppColors.onSurface,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter session vibe...',
                                                  hintStyle: TextStyle(
                                                    color: AppColors.outline
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    borderSide:
                                                        const BorderSide(
                                                          color: AppColors
                                                              .glassBorder,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _isUpdatingMood
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: AppColors
                                                              .secondary,
                                                        ),
                                                  )
                                                : Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.check_rounded,
                                                          color: AppColors.like,
                                                          size: 18,
                                                        ),
                                                        onPressed: _saveMood,
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.close_rounded,
                                                          color:
                                                              AppColors.dislike,
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _isEditingMood =
                                                                false;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                          ],
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            _moodController.text =
                                                session.mood ?? '';
                                            setState(() {
                                              _isEditingMood = true;
                                            });
                                          },
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary
                                                    .withValues(alpha: 0.05),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors.glassBorder
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.auto_awesome,
                                                    color: AppColors.secondary,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      session.mood != null &&
                                                              session
                                                                  .mood!
                                                                  .isNotEmpty
                                                          ? 'Vibe: "${session.mood}"'
                                                          : 'Set Room Vibe ✨',
                                                      style: AppTextStyles
                                                          .bodySmall
                                                          .copyWith(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color: AppColors
                                                                .onSurfaceVariant,
                                                            fontSize: 12,
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.edit_rounded,
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                    size: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Invite Friend Panel (only for creator or everyone, typically anyone in lobby can invite)
                            GlassContainer(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'INVITE A CINEPHILE',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _emailController,
                                          style: AppTextStyles.bodyMedium,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            hintText: 'friend@email.com',
                                            hintStyle: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.outline,
                                                ),
                                            filled: true,
                                            fillColor:
                                                AppColors.surfaceContainerLow,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 12,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: AppColors.glassBorder,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: _isInviting
                                              ? null
                                              : _handleInvite,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondaryContainer,
                                            foregroundColor:
                                                AppColors.onSecondaryContainer,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isInviting
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Icon(
                                                  Icons.send_rounded,
                                                  size: 20,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_statusMessage != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _statusMessage!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: _isSuccess
                                            ? AppColors.like
                                            : AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Members List
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'PARTICIPANTS (${session.members.length})',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.8,
                                  ),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: session.members.length,
                              itemBuilder: (context, index) {
                                final member = session.members[index];
                                final isMe =
                                    member.userId.toString() == currentUserId;

                                Color statusColor = AppColors.tertiary;
                                IconData statusIcon = Icons.pending_outlined;

                                if (member.isAccepted) {
                                  statusColor = AppColors.like;
                                  statusIcon = Icons.check_circle_rounded;
                                } else if (member.isDeclined) {
                                  statusColor = AppColors.dislike;
                                  statusIcon = Icons.cancel_rounded;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.all(14),
                                    borderRadius: 16,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: statusColor
                                              .withValues(alpha: 0.1),
                                          child: Icon(
                                            statusIcon,
                                            color: statusColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                member.email,
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                isMe
                                                    ? 'You (Creator)'
                                                    : 'Participant',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors
                                                          .onSurfaceVariant
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                      fontSize: 11,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: statusColor.withValues(
                                                alpha: 0.3,
                                              ),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            member.status.toUpperCase(),
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                                  color: statusColor,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Launch consensual matching list!
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(
                              '/group-session/recommendations/${session.sessionCode}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryContainer,
                            foregroundColor: AppColors.onSecondaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: AppColors.secondaryContainer
                                .withValues(alpha: 0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'VIEW CONSENSUS MATCHES',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
