import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';

/// Mayın patladığında oyun tahtasına kısa ve etkili bir darbe sarsıntısı uygular.
class BoardShakeWrapper extends StatefulWidget {
  const BoardShakeWrapper({
    super.key,
    required this.triggerShake,
    required this.child,
  });

  final bool triggerShake;
  final Widget child;

  @override
  State<BoardShakeWrapper> createState() => _BoardShakeWrapperState();
}

class _BoardShakeWrapperState extends State<BoardShakeWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    if (widget.triggerShake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant BoardShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.triggerShake && widget.triggerShake) {
      _controller.forward(from: 0.0);
    } else if (oldWidget.triggerShake && !widget.triggerShake) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        if (t == 0 || t == 1) return child!;
        final damping = 1.0 - t;
        final dx = math.sin(t * math.pi * 6) * 9.0 * damping;
        final dy = math.cos(t * math.pi * 4) * 4.5 * damping;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Patlayan mayının merkezinden yayılan neon şok dalgası ve kıvılcım parçacıkları.
class ExplosionOverlay extends StatefulWidget {
  const ExplosionOverlay({
    super.key,
    required this.epicenter,
  });

  /// Tahta üzerindeki normalize merkez koordinatı (0..1 x 0..1).
  final Offset epicenter;

  @override
  State<ExplosionOverlay> createState() => _ExplosionOverlayState();
}

class _ExplosionOverlayState extends State<ExplosionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Spark> _sparks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    final rng = math.Random(42);
    _sparks = List.generate(18, (index) {
      final angle = (index / 18) * math.pi * 2 + (rng.nextDouble() - 0.5) * 0.28;
      final speed = 0.55 + rng.nextDouble() * 0.45;
      final size = 2.5 + rng.nextDouble() * 3.0;
      final color = index.isEven ? AppColors.neonRed : AppColors.neonOrange;
      return _Spark(angle: angle, speed: speed, size: size, color: color);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ExplosionPainter(
              progress: Curves.easeOutCubic.transform(_controller.value),
              epicenter: widget.epicenter,
              sparks: _sparks,
            ),
          );
        },
      ),
    );
  }
}

class _Spark {
  const _Spark({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  final double angle;
  final double speed;
  final double size;
  final Color color;
}

class _ExplosionPainter extends CustomPainter {
  const _ExplosionPainter({
    required this.progress,
    required this.epicenter,
    required this.sparks,
  });

  final double progress;
  final Offset epicenter;
  final List<_Spark> sparks;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(
      epicenter.dx * size.width,
      epicenter.dy * size.height,
    );
    final maxRadius = math.max(size.width, size.height) * 0.65;
    final fade = (1.0 - progress).clamp(0.0, 1.0);

    // Merkez flaşı
    if (progress < 0.4) {
      final flashFade = 1.0 - (progress / 0.4);
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45 * flashFade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, 18 + 32 * progress, flashPaint);
    }

    // Dış şok dalgası halkası
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (4.5 * fade).clamp(1.0, 4.5)
      ..color = AppColors.neonRed.withValues(alpha: 0.8 * fade);
    canvas.drawCircle(center, maxRadius * progress, outerPaint);

    // İkinci sıcak turuncu halka
    if (progress > 0.12) {
      final innerProgress = ((progress - 0.12) / 0.88).clamp(0.0, 1.0);
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (3.0 * (1.0 - innerProgress)).clamp(0.8, 3.0)
        ..color = AppColors.neonOrange.withValues(alpha: 0.7 * (1.0 - innerProgress));
      canvas.drawCircle(center, maxRadius * 0.75 * innerProgress, innerPaint);
    }

    // Kıvılcım parçacıkları
    for (final spark in sparks) {
      final distance = maxRadius * 0.55 * spark.speed * progress;
      final offset = Offset(
        center.dx + math.cos(spark.angle) * distance,
        center.dy + math.sin(spark.angle) * distance,
      );
      final sparkPaint = Paint()
        ..color = spark.color.withValues(alpha: fade)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, spark.size * fade, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExplosionPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.epicenter != epicenter;
  }
}

