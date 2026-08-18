import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';
import '../../../data/models/movie_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'movie_card.dart';

class SwipeStack extends ConsumerStatefulWidget {
  final void Function(Movie, UserInteraction)? onSwipe;
  final void Function(Movie)? onTapDetails;
  const SwipeStack({super.key, this.onSwipe, this.onTapDetails});
  @override
  ConsumerState<SwipeStack> createState() => _SwipeStackState();
}

class _SwipeStackState extends ConsumerState<SwipeStack>
    with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late AnimationController _controller;
  Animation<Offset>? _slideBack;
  static const double swipeThreshold = 120;
  static const double velocityThreshold = 900; // pixels/second
  late AnimationController _labelController;
  late Animation<double> _labelScale;
  late Animation<double> _labelOpacity;
  late AnimationController _superBurstController;
  late Animation<double> _burstScale;
  late Animation<double> _burstOpacity;
  late AnimationController _particleController;
  UserInteraction _currentInteraction = UserInteraction.none;
  bool _superHapticFired = false;
  final List<_Particle> _particles = [];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _labelScale = CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeOutBack,
    );
    _labelOpacity = CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeIn,
    );
    _superBurstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _burstScale = Tween<double>(begin: .6, end: 2.6).animate(
      CurvedAnimation(
        parent: _superBurstController,
        curve: Curves.easeOutCubic,
      ),
    );
    _burstOpacity = Tween<double>(begin: .55, end: 0).animate(
      CurvedAnimation(parent: _superBurstController, curve: Curves.easeOut),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(() => setState(() => _updateParticles()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _labelController.dispose();
    _superBurstController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _animateBack() {
    _slideBack = Tween(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller
      ..reset()
      ..forward();
    _controller.addListener(
      () => setState(() => _dragOffset = _slideBack!.value),
    );
  }

  UserInteraction _interactionForOffset(Offset o) {
    if (o.dx > swipeThreshold) return UserInteraction.liked;
    if (o.dx < -swipeThreshold) return UserInteraction.disliked;
    if (o.dy < -swipeThreshold) return UserInteraction.superLiked;
    return UserInteraction.none;
  }

  Color? _overlay(UserInteraction i) {
    switch (i) {
      case UserInteraction.liked:
        return AppColors.like.withValues(alpha: .35);
      case UserInteraction.disliked:
        return AppColors.error.withValues(alpha: .35);
      case UserInteraction.superLiked:
        return AppColors.tertiary.withValues(alpha: .35);
      case UserInteraction.none:
        return null;
    }
  }

  Widget _feedbackLabel(UserInteraction interaction) {
    if (interaction == UserInteraction.none) return const SizedBox.shrink();
    String text;
    Color color;
    Alignment align = Alignment.topCenter;
    EdgeInsets pad = const EdgeInsets.only(top: 40);
    double angle = -0.2;
    switch (interaction) {
      case UserInteraction.liked:
        text = 'LIKE';
        color = AppColors.like;
        align = Alignment.topLeft;
        pad = const EdgeInsets.only(top: 60, left: 30);
        angle = -0.15;
        break;
      case UserInteraction.disliked:
        text = 'NOPE';
        color = AppColors.error;
        align = Alignment.topRight;
        pad = const EdgeInsets.only(top: 60, right: 30);
        angle = 0.15;
        break;
      case UserInteraction.superLiked:
        text = 'SUPER';
        color = AppColors.tertiary;
        align = Alignment.topCenter;
        pad = const EdgeInsets.only(top: 80);
        angle = 0;
        break;
      case UserInteraction.none:
        return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: pad,
          child: Align(
            alignment: align,
            child: ScaleTransition(
              scale: _labelScale,
              child: FadeTransition(
                opacity: _labelOpacity,
                child: Transform.rotate(
                  angle: angle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      text,
                      style: AppTextStyles.displaySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _superBurst() {
    if (_currentInteraction != UserInteraction.superLiked &&
        _superBurstController.isDismissed) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _superBurstController,
            _particleController,
          ]),
          builder: (_, __) {
            return CustomPaint(
              painter: _ParticlePainter(_particles),
              child: Opacity(
                opacity: _burstOpacity.value,
                child: Center(
                  child: Transform.scale(
                    scale: _burstScale.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.tertiary.withValues(alpha: .45),
                            AppColors.tertiary.withValues(alpha: .1),
                            Colors.transparent,
                          ],
                          stops: const [0, .4, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _triggerSuperLikeEffects() {
    if (_superBurstController.isAnimating) return;
    _superBurstController
      ..reset()
      ..forward();
    _particleController
      ..reset()
      ..forward();
    _spawnParticles();
    if (!_superHapticFired) {
      HapticFeedback.heavyImpact();
      _superHapticFired = true;
    }
  }

  void _spawnParticles() {
    _particles.clear();
    const int count = 24;
    for (int i = 0; i < count; i++) {
      final double angle = (i / count) * 6.28318;
      final double speed = 80 + (i % 5) * 12;
      _particles.add(_Particle(angle: angle, speed: speed));
    }
  }

  void _updateParticles() {
    final t = _particleController.value;
    for (final p in _particles) {
      p.progress = t;
    }
    if (_particleController.isCompleted) {
      _particles.clear();
      _superHapticFired = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(movieStackProvider);
    if (s.stack.isEmpty && s.isLoading) {
      // show placeholder skeleton stack
      final skeletons = List.generate(3, (i) {
        final positionIndex = 2 - i;
        final baseOffset = Offset(0, positionIndex * 12);
        final scale = 1 - positionIndex * 0.04;
        return KeyedSubtree(
          key: ValueKey('skeleton_$i'),
          child: Transform.translate(
            offset: baseOffset,
            child: Transform.scale(
              scale: scale,
              child: MovieCard(movie: _dummyMovie, isSkeleton: true),
            ),
          ),
        );
      });
      return Stack(children: skeletons);
    }
    if (s.stack.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.movie,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No more movies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(movieStackProvider.notifier).loadMore(),
              child: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    final cards = <Widget>[];
    for (var i = 0; i < s.stack.length; i++) {
      final movie = s.stack[i];
      final isTop = i == s.stack.length - 1;
      final positionIndex = s.stack.length - 1 - i;
      final baseOffset = Offset(0, positionIndex * 12);
      final scale = 1 - positionIndex * 0.04;

      Widget card = isTop
          ? _buildTop(movie)
          : Transform.translate(
              offset: baseOffset,
              child: Transform.scale(
                scale: scale,
                child: MovieCard(movie: movie),
              ),
            );

      cards.add(KeyedSubtree(key: ValueKey(movie.id), child: card));
    }
    return Stack(children: cards);
  }

  bool _isAnimatingOut = false;

  void swipeTop(UserInteraction interaction) {
    final s = ref.read(movieStackProvider);
    if (s.stack.isEmpty || _isAnimatingOut) return;
    final movie = s.stack.last;

    Offset target;
    switch (interaction) {
      case UserInteraction.liked:
        target = const Offset(500, 0);
        break;
      case UserInteraction.disliked:
        target = const Offset(-500, 0);
        break;
      case UserInteraction.superLiked:
        target = const Offset(0, -600);
        break;
      case UserInteraction.none:
        return;
    }

    _animateSwipeOut(movie, interaction, target);
  }

  void _animateSwipeOut(
    Movie movie,
    UserInteraction interaction,
    Offset targetOffset,
  ) {
    if (_isAnimatingOut) return;
    _isAnimatingOut = true;

    if (interaction == UserInteraction.superLiked) {
      HapticFeedback.vibrate();
      _triggerSuperLikeEffects();
    }

    _currentInteraction = interaction;
    _labelController.forward();

    _slideBack = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.duration = const Duration(milliseconds: 180);
    _controller.reset();

    void updateListener() {
      setState(() => _dragOffset = _slideBack!.value);
    }

    _controller.removeListener(updateListener);
    _controller.addListener(updateListener);

    _controller.forward().then((_) {
      _controller.removeListener(updateListener);
      widget.onSwipe?.call(movie, interaction);
      ref.read(movieStackProvider.notifier).swipe(movie, interaction);
      setState(() {
        _dragOffset = Offset.zero;
        _isAnimatingOut = false;
      });
      _labelController.reset();
      _currentInteraction = UserInteraction.none;
      _superHapticFired = false;
    });
  }

  Widget _buildTop(Movie movie) {
    final interaction = _interactionForOffset(_dragOffset);
    if (interaction != _currentInteraction && !_isAnimatingOut) {
      _currentInteraction = interaction;
      if (interaction == UserInteraction.none) {
        _labelController.reverse();
      } else {
        _labelController.forward();
        if (interaction == UserInteraction.superLiked) {
          _triggerSuperLikeEffects();
        }
      }
    }

    final overlayColor = _overlay(
      _currentInteraction != UserInteraction.none
          ? _currentInteraction
          : interaction,
    );
    final rotation = (_dragOffset.dx / 300) * 0.3;

    return GestureDetector(
      onTap: () => widget.onTapDetails?.call(movie),
      onPanUpdate: (d) {
        if (_isAnimatingOut) return;
        setState(() => _dragOffset += d.delta);
      },
      onPanEnd: (details) {
        if (_isAnimatingOut) return;
        final velocity = details.velocity.pixelsPerSecond;
        final vMagnitude = velocity.distance;
        var finalInteraction = _interactionForOffset(_dragOffset);

        if (finalInteraction == UserInteraction.none &&
            vMagnitude > velocityThreshold) {
          if (velocity.dx.abs() > velocity.dy.abs()) {
            finalInteraction = velocity.dx > 0
                ? UserInteraction.liked
                : UserInteraction.disliked;
          } else if (velocity.dy < 0) {
            finalInteraction = UserInteraction.superLiked;
          }
        }

        if (finalInteraction != UserInteraction.none) {
          Offset target;
          switch (finalInteraction) {
            case UserInteraction.liked:
              target = Offset(500, _dragOffset.dy);
              break;
            case UserInteraction.disliked:
              target = Offset(-500, _dragOffset.dy);
              break;
            case UserInteraction.superLiked:
              target = Offset(_dragOffset.dx, -600);
              break;
            case UserInteraction.none:
              target = Offset.zero;
              break;
          }
          _animateSwipeOut(movie, finalInteraction, target);
        } else {
          _animateBack();
        }
      },
      child: Stack(
        children: [
          Transform.translate(
            offset: _dragOffset,
            child: MovieCard(
              movie: movie,
              rotation: rotation,
              overlay: overlayColor == null
                  ? null
                  : Container(color: overlayColor),
            ),
          ),
          _feedbackLabel(
            _currentInteraction != UserInteraction.none
                ? _currentInteraction
                : interaction,
          ),
          _superBurst(),
        ],
      ),
    );
  }
}

// Dummy movie for skeleton (minimal fields)
final Movie _dummyMovie = Movie(
  id: -1,
  title: 'Loading',
  overview: '',
  genres: const [''],
  releaseDate: '2024-01-01',
  voteAverage: 0,
  voteCount: 0,
  runtime: 0,
  cast: const [],
  director: '',
  posterUrl: null,
  backdropUrl: null,
  similarIds: const [],
);

class _Particle {
  _Particle({required this.angle, required this.speed});
  final double angle;
  final double speed;
  double progress = 0; // 0..1
  Offset position(Size size) {
    final double r = Curves.easeOut.transform(progress) * speed;
    return Offset(
      size.width / 2 + r * math.cos(angle),
      size.height / 2 + r * math.sin(angle),
    );
  }

  double opacity() => (1 - progress).clamp(0, 1);
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles);
  final List<_Particle> particles;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final pos = p.position(size);
      paint.color = Colors.blueAccent.withValues(alpha: .7 * p.opacity());
      canvas.drawCircle(pos, 4 * (1 - p.progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
