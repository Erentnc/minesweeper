import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';

/// Neon Minesweeper ekranları için ince sibernetik ızgara ve ortam parıltısı
/// sağlayan arka plan bileşeni.
class NeonBackground extends StatelessWidget {
  const NeonBackground({
    super.key,
    required this.child,
    this.accentColor = AppColors.neonCyan,
  });

  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF070A19),
                AppColors.background,
                Color(0xFF0E112B),
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -90,
          child: _AmbientGlowOrb(
            color: accentColor.withValues(alpha: 0.14),
            size: 320,
          ),
        ),
        Positioned(
          bottom: -140,
          left: -100,
          child: _AmbientGlowOrb(
            color: AppColors.neonPurple.withValues(alpha: 0.10),
            size: 340,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CyberGridPainter(
                gridColor: accentColor.withValues(alpha: 0.045),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AmbientGlowOrb extends StatelessWidget {
  const _AmbientGlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  const _CyberGridPainter({required this.gridColor});

  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 36.0;
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor;
  }
}

