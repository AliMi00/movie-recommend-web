import 'package:flutter/material.dart';
import '../../../data/models/movie_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final Widget? overlay;
  final double? scale;
  final double? rotation;
  final bool isSkeleton;

  const MovieCard({
    super.key,
    required this.movie,
    this.overlay,
    this.scale,
    this.rotation,
    this.isSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = isSkeleton
        ? _Skeleton()
        : Stack(
            fit: StackFit.expand,
            children: [
              _PosterImage(path: movie.fullPosterPath),
              // Subtle gradient for text legibility
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.cardOverlayGradient,
                ),
              ),

              // Top Badges
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (movie.reason != null && movie.reason!.isNotEmpty)
                      _ReasonBadge(reason: movie.reason!),
                    if (movie.isSuperLiked)
                      const _Badge(
                        icon: Icons.star_rounded,
                        color: AppColors.tertiary,
                        label: 'SUPER',
                      ),
                  ],
                ),
              ),

              // Bottom Info Section
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: _Info(movie: movie),
              ),

              if (overlay != null) overlay!,
            ],
          );

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF001356,
            ).withValues(alpha: 0.3), // Dark blue tint shadow
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // rounded-lg
        child: cardContent,
      ),
    );

    Widget child = card;
    if (scale != null || rotation != null) {
      child = Transform.scale(
        scale: scale ?? 1,
        child: Transform.rotate(angle: rotation ?? 0, child: card),
      );
    }
    return child;
  }
}

class _ReasonBadge extends StatelessWidget {
  final String reason;
  const _ReasonBadge({required this.reason});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: 20,
      opacity: 0.1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              reason.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _Badge({required this.icon, required this.color, required this.label});

  @override
  State<_Badge> createState() => _BadgeState();
}

class _BadgeState extends State<_Badge> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          borderRadius: 14,
          opacity: 0.15,
          border: Border.all(
            color: widget.color.withValues(alpha: 0.5),
            width: 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.color,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  final String? path;
  const _PosterImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(color: AppColors.surfaceContainerLowest);
    if (path == null || path!.isEmpty) return fallback;

    final p = path!;
    final isNetwork = p.startsWith('http');

    return isNetwork
        ? Image.network(
            p,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.surfaceContainerLowest,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (ctx, err, stack) {
              debugPrint('Image load error: $err for path: $p');
              return fallback;
            },
          )
        : Image.asset(
            p,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => fallback,
          );
  }
}

class _Info extends StatelessWidget {
  final Movie movie;
  const _Info({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title with tight letter spacing as per design
        Text(
          movie.title,
          style: AppTextStyles.movieTitle.copyWith(
            color: AppColors.onMedia,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Metadata using Inter for legibility
        Row(
          children: [
            Text(
              '${movie.releaseYear} • ${movie.formattedRuntime}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onMediaVariant,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            // Vivid Gold rating badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    movie.formattedRating,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.tertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Description with Inter handles metadata/summaries
        Text(
          movie.overview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onMediaVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Skeleton extends StatefulWidget {
  const _Skeleton();
  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bar({double h = 14, double w = 120}) {
      return AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final shimmer = _c.value;
          return Container(
            height: h,
            width: w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment(-1 + shimmer * 2, -0.2),
                end: Alignment(1 + shimmer * 2, 0.2),
                // Darker-than-surface sweep: the skeleton sits on a white
                // clay card now, so a white shimmer would be invisible.
                colors: const [
                  AppColors.surfaceContainerHigh,
                  AppColors.surfaceContainerHighest,
                  AppColors.surfaceContainerHigh,
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: AppColors.surfaceContainerLowest,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                bar(h: 22, w: 180),
                const SizedBox(height: 8),
                bar(w: 140),
                const SizedBox(height: 16),
                bar(w: double.infinity),
                const SizedBox(height: 6),
                bar(w: double.infinity),
                const SizedBox(height: 6),
                bar(w: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
