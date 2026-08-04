import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A Home-dashboard card showing profile-completeness as a checklist plus
/// a percentage — collapses to a slim "complete" strip (with a one-time
/// confetti burst) once every item is done, instead of a permanent nudge
/// that's no longer actionable.
class ProfileCompletenessCard extends ConsumerStatefulWidget {
  const ProfileCompletenessCard({
    super.key,
    required this.userId,
    required this.items,
    required this.onTap,
    required this.cardShape,
  });

  final String userId;

  /// Each entry is (label, done) — e.g. ("Bio", true).
  final List<(String, bool)> items;
  final VoidCallback onTap;
  final ShapeBorder cardShape;

  @override
  ConsumerState<ProfileCompletenessCard> createState() =>
      _ProfileCompletenessCardState();
}

class _ProfileCompletenessCardState
    extends ConsumerState<ProfileCompletenessCard> {
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    _maybeCelebrate();
  }

  @override
  void didUpdateWidget(covariant ProfileCompletenessCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeCelebrate();
  }

  double get _percent => widget.items.isEmpty
      ? 0
      : widget.items.where((i) => i.$2).length / widget.items.length;

  void _maybeCelebrate() {
    if (_percent < 1.0) return;
    final storage = ref.read(localStorageServiceProvider);
    if (storage.hasCelebratedProfileComplete(widget.userId)) return;
    storage.setCelebratedProfileComplete(widget.userId);
    setState(() => _celebrating = true);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _celebrating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final percent = _percent;
    final isComplete = percent >= 1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          shape: widget.cardShape,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: isComplete ? _buildComplete() : _buildChecklist(percent),
            ),
          ),
        ),
        if (_celebrating)
          Positioned.fill(child: IgnorePointer(child: _ConfettiBurst())),
      ],
    );
  }

  Widget _buildComplete() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Profile complete', style: AppTextStyles.titleSmall),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildChecklist(double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Profile strength', style: AppTextStyles.titleSmall),
            const Spacer(),
            Text(
              '${(percent * 100).round()}%',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: widget.items
              .map(
                (item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$2
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: item.$2 ? AppColors.success : AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.$1,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: item.$2
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.onTap,
            child: const Text('Complete profile'),
          ),
        ),
      ],
    );
  }
}

class _ConfettiBurst extends StatefulWidget {
  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();
  late final List<_Particle> _particles = List.generate(
    18,
    (i) => _Particle(Random(i * 37 + 1)),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  _Particle(Random random)
    : angle = random.nextDouble() * 2 * pi,
      distance = 40 + random.nextDouble() * 60,
      color = _palette[random.nextInt(_palette.length)],
      size = 4 + random.nextDouble() * 4;

  final double angle;
  final double distance;
  final Color color;
  final double size;

  static const _palette = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
  ];
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress);

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 24);
    final eased = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final opacity = (1 - progress).clamp(0.0, 1.0);
    for (final particle in particles) {
      final dx = cos(particle.angle) * particle.distance * eased;
      final dy = sin(particle.angle) * particle.distance * eased - (eased * 20);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center + Offset(dx, dy), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
