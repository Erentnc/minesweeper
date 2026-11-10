import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';

/// Oyun kazanıldığında ekranın üstünden neon konfeti parçacıkları yağdıran efekt.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiPiece> _pieces;

  static const _palette = [
    AppColors.neonCyan,
    AppColors.neonGreen,
    AppColors.neonPurple,
    AppColors.neonOrange,
    AppColors.neonYellow,
    AppColors.neonIndigo,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    final rng = math.Random(101);
    _pieces = List.generate(48, (i) {
      return _ConfettiPiece(
        startX: 0.15 + rng.nextDouble() * 0.7,
        startY: -0.05 - rng.nextDouble() * 0.15,
        driftX: (rng.nextDouble() - 0.5) * 0.45,
        fallSpeed: 0.85 + rng.nextDouble() * 0.65,
        rotationSpeed: (rng.nextDouble() - 0.5) * 10.0,
        width: 6.0 + rng.nextDouble() * 5.0,
        height: 10.0 + rng.nextDouble() * 6.0,
        color: _palette[i % _palette.length],
      );
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
            size: Size.infinite,
            painter: _ConfettiPainter(
              progress: _controller.value,
              pieces: _pieces,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.startX,
    required this.startY,
    required this.driftX,
    required this.fallSpeed,
    required this.rotationSpeed,
    required this.width,
    required this.height,
    required this.color,
  });

  final double startX;
  final double startY;
  final double driftX;
  final double fallSpeed;
  final double rotationSpeed;
  final double width;
  final double height;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.progress,
    required this.pieces,
  });

  final double progress;
  final List<_ConfettiPiece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final fade = progress > 0.75
        ? ((1.0 - progress) / 0.25).clamp(0.0, 1.0)
        : 1.0;

    for (final piece in pieces) {
      final t = progress;
      final x = (piece.startX + piece.driftX * t + math.sin(t * 9 + piece.startX * 10) * 0.03) *
          size.width;
      final y = (piece.startY + piece.fallSpeed * t * t + 0.35 * t) * size.height;

      if (y < -24 || y > size.height + 24) continue;

      final paint = Paint()
        ..color = piece.color.withValues(alpha: fade)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotationSpeed * t);
      final flipScale = math.cos(t * 14 + piece.startX * 12);
      canvas.scale(1.0, flipScale.abs().clamp(0.25, 1.0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.width,
            height: piece.height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

