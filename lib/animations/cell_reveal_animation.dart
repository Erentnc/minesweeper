import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hücre açıldığında dalga gecikmeli ölçek/opaklık animasyonu ve basılı tutma
/// geri bildirimi sağlayan sarmalayıcı widget.
class CellRevealAnimation extends StatefulWidget {
  const CellRevealAnimation({
    super.key,
    required this.isRevealed,
    required this.isFlagged,
    required this.waveDistance,
    required this.isPressed,
    required this.child,
  });

  final bool isRevealed;
  final bool isFlagged;
  final int waveDistance;
  final bool isPressed;
  final Widget child;

  @override
  State<CellRevealAnimation> createState() => _CellRevealAnimationState();
}

class _CellRevealAnimationState extends State<CellRevealAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.72, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant CellRevealAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isRevealed && widget.isRevealed) {
      _triggerRevealAnimation();
    } else if (oldWidget.isRevealed && !widget.isRevealed) {
      _delayTimer?.cancel();
      _controller.value = 1.0;
    } else if (oldWidget.isFlagged != widget.isFlagged && !widget.isRevealed) {
      _controller.forward(from: 0.0);
    }
  }

  void _triggerRevealAnimation() {
    _delayTimer?.cancel();
    final delayMs = math.min(200, widget.waveDistance * 22);
    if (delayMs <= 0) {
      _controller.forward(from: 0.0);
      return;
    }

    _controller.value = 0.0;
    _delayTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.isPressed && !widget.isRevealed ? 0.91 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final opacity = widget.isRevealed
              ? _controller.value.clamp(0.15, 1.0)
              : 1.0;
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

