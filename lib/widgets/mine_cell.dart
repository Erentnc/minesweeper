import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/animations/cell_reveal_animation.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/models/cell_model.dart';

/// Tek bir mayın tarlası hücresini neon stil, dalga açılma animasyonu ve
/// basma geri bildirimiyle çizen widget.
class MineCell extends StatefulWidget {
  const MineCell({
    super.key,
    required this.cell,
    required this.cellSize,
    required this.waveDistance,
    required this.isGameLost,
    required this.onTap,
    required this.onSecondaryAction,
    this.onPressChanged,
  });

  final CellModel cell;
  final double cellSize;
  final int waveDistance;
  final bool isGameLost;
  final VoidCallback onTap;
  final VoidCallback onSecondaryAction;
  final ValueChanged<bool>? onPressChanged;

  @override
  State<MineCell> createState() => _MineCellState();
}

class _MineCellState extends State<MineCell> {
  bool _isPressed = false;

  void _setPressed(bool pressed) {
    if (_isPressed == pressed) return;
    setState(() {
      _isPressed = pressed;
    });
    widget.onPressChanged?.call(pressed);
  }

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;
    final isWrongFlag = widget.isGameLost && cell.isFlagged && !cell.isMine;
    final borderRadius =
        BorderRadius.circular((widget.cellSize * 0.18).clamp(4.0, 10.0));

    return GestureDetector(
      onTapDown: (_) {
        if (!cell.isRevealed && !cell.isFlagged) {
          _setPressed(true);
        }
      },
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      onLongPress: () {
        _setPressed(false);
        widget.onSecondaryAction();
      },
      onSecondaryTap: widget.onSecondaryAction,
      child: CellRevealAnimation(
        isRevealed: cell.isRevealed,
        isFlagged: cell.isFlagged,
        waveDistance: widget.waveDistance,
        isPressed: _isPressed,
        child: Container(
          decoration: _buildDecoration(cell, borderRadius, isWrongFlag),
          child: Center(
            child: _buildContent(cell, isWrongFlag),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(
    CellModel cell,
    BorderRadius borderRadius,
    bool isWrongFlag,
  ) {
    if (cell.isRevealed) {
      if (cell.isExploded) {
        return BoxDecoration(
          gradient: const RadialGradient(
            colors: [
              Color(0xFFFF6E7F),
              AppColors.neonRed,
            ],
          ),
          borderRadius: borderRadius,
          border: Border.all(color: Colors.white, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonRed.withValues(alpha: 0.75),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        );
      }

      if (cell.isMine) {
        return BoxDecoration(
          color: AppColors.neonRed.withValues(alpha: 0.18),
          borderRadius: borderRadius,
          border: Border.all(
            color: AppColors.neonRed.withValues(alpha: 0.6),
          ),
        );
      }

      return BoxDecoration(
        color: AppColors.cellRevealed,
        borderRadius: borderRadius,
        border: Border.all(
          color: cell.neighborMines > 0
              ? AppColors.numberColor(cell.neighborMines).withValues(alpha: 0.22)
              : AppColors.cellRevealedBorder,
        ),
      );
    }

    if (isWrongFlag) {
      return BoxDecoration(
        color: AppColors.neonOrange.withValues(alpha: 0.2),
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.neonOrange, width: 1.4),
      );
    }

    if (cell.isFlagged) {
      return BoxDecoration(
        color: AppColors.cellClosed,
        borderRadius: borderRadius,
        border: Border.all(
          color: AppColors.neonOrange.withValues(alpha: 0.85),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonOrange.withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        ],
      );
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isPressed
            ? [AppColors.cellClosed, AppColors.cellRevealed]
            : [AppColors.cellClosedHighlight, AppColors.cellClosed],
      ),
      borderRadius: borderRadius,
      border: Border.all(
        color: _isPressed
            ? AppColors.neonCyan.withValues(alpha: 0.7)
            : AppColors.cellClosedBorder,
      ),
      boxShadow: _isPressed
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  Widget? _buildContent(CellModel cell, bool isWrongFlag) {
    final iconSize = (widget.cellSize * 0.54).clamp(12.0, 28.0);
    final fontSize = (widget.cellSize * 0.5).clamp(11.0, 24.0);

    if (!cell.isRevealed) {
      if (isWrongFlag) {
        return Icon(
          Icons.close_rounded,
          size: iconSize,
          color: AppColors.neonOrange,
        );
      }
      if (cell.isFlagged) {
        return Icon(
          Icons.flag_rounded,
          size: iconSize,
          color: AppColors.neonOrange,
          shadows: [
            Shadow(
              color: AppColors.neonOrange.withValues(alpha: 0.75),
              blurRadius: 8,
            ),
          ],
        );
      }
      return null;
    }

    if (cell.isMine) {
      return _NeonMineIcon(
        size: iconSize,
        isExploded: cell.isExploded,
      );
    }

    if (cell.neighborMines > 0) {
      final numberColor = AppColors.numberColor(cell.neighborMines);
      return Text(
        '${cell.neighborMines}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: numberColor,
          shadows: [
            Shadow(
              color: numberColor.withValues(alpha: 0.65),
              blurRadius: 8,
            ),
          ],
        ),
      );
    }

    return null;
  }
}

class _NeonMineIcon extends StatelessWidget {
  const _NeonMineIcon({
    required this.size,
    required this.isExploded,
  });

  final double size;
  final bool isExploded;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MinePainter(
        color: isExploded ? Colors.white : AppColors.neonRed,
        coreColor: isExploded ? AppColors.neonYellow : Colors.white,
      ),
    );
  }
}

class _MinePainter extends CustomPainter {
  const _MinePainter({
    required this.color,
    required this.coreColor,
  });

  final Color color;
  final Color coreColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.31;

    final spikePaint = Paint()
      ..color = color
      ..strokeWidth = (size.width * 0.1).clamp(1.4, 2.8)
      ..strokeCap = StrokeCap.round;

    // 8 yönlü mayın dikenleri
    final spikeReach = size.width * 0.46;
    canvas.drawLine(
      Offset(center.dx - spikeReach, center.dy),
      Offset(center.dx + spikeReach, center.dy),
      spikePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - spikeReach),
      Offset(center.dx, center.dy + spikeReach),
      spikePaint,
    );
    final diag = spikeReach * 0.72;
    canvas.drawLine(
      Offset(center.dx - diag, center.dy - diag),
      Offset(center.dx + diag, center.dy + diag),
      spikePaint,
    );
    canvas.drawLine(
      Offset(center.dx + diag, center.dy - diag),
      Offset(center.dx - diag, center.dy + diag),
      spikePaint,
    );

    // Ana gövde
    canvas.drawCircle(center, radius, Paint()..color = color);

    // Parlak çekirdek yansıması
    canvas.drawCircle(
      Offset(center.dx - radius * 0.28, center.dy - radius * 0.28),
      radius * 0.3,
      Paint()..color = coreColor.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _MinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.coreColor != coreColor;
  }
}
