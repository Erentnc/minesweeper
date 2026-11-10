import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/animations/explosion_animation.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/models/game_state.dart';
import 'package:mayin_tarlasi/widgets/mine_cell.dart';

/// Oyun tahtasını duyarlı boyutlandırma, patlama efektleri ve büyük tahtalar
/// için yakınlaştırma/kaydırma desteğiyle çizen widget.
class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.gameState,
    required this.onCellTap,
    required this.onCellSecondaryAction,
    this.onPressChanged,
  });

  final GameState gameState;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col) onCellSecondaryAction;
  final ValueChanged<bool>? onPressChanged;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final TransformationController _transformController =
      TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_handleTransformChanged);
  }

  @override
  void didUpdateWidget(covariant GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState.config != widget.gameState.config ||
        (oldWidget.gameState.isGameOver && !widget.gameState.isGameOver)) {
      _resetZoom();
    }
  }

  void _handleTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.05;
    if (zoomed != _isZoomed) {
      setState(() {
        _isZoomed = zoomed;
      });
    }
  }

  void _resetZoom() {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _transformController.removeListener(_handleTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameState;
    final rows = gameState.config.rows;
    final cols = gameState.config.cols;
    final isLost = gameState.status == GameStatus.lost;
    final exploded = gameState.explodedCell;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxAvailable = math.min(
          math.min(constraints.maxWidth, constraints.maxHeight),
          AppDimensions.boardMaxWidth,
        );

        const framePadding = 10.0;
        final spacing = cols >= 14 ? 2.0 : (cols >= 10 ? 3.0 : (cols >= 8 ? 4.0 : 6.0));
        final innerSize = math.max(0.0, maxAvailable - (framePadding * 2));
        final cellSize = (innerSize - spacing * (cols - 1)) / cols;
        final boardWidth =
            cellSize * cols + spacing * (cols - 1) + framePadding * 2;
        final boardHeight =
            cellSize * rows + spacing * (rows - 1) + framePadding * 2;

        final boardContent = Container(
          width: boardWidth,
          height: boardHeight,
          padding: const EdgeInsets.all(framePadding),
          decoration: BoxDecoration(
            color: AppColors.boardFrame,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: (isLost ? AppColors.neonRed : gameState.config.accentColor)
                  .withValues(alpha: 0.42),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isLost ? AppColors.neonRed : gameState.config.accentColor)
                        .withValues(alpha: isLost ? 0.25 : 0.12),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final row = index ~/ cols;
                  final col = index % cols;
                  final cell = gameState.grid[row][col];

                  return MineCell(
                    cell: cell,
                    cellSize: cellSize,
                    waveDistance: gameState.waveDistanceTo(row, col),
                    isGameLost: isLost,
                    onTap: () => widget.onCellTap(row, col),
                    onSecondaryAction: () =>
                        widget.onCellSecondaryAction(row, col),
                    onPressChanged: widget.onPressChanged,
                  );
                },
              ),
              if (isLost && exploded != null)
                Positioned.fill(
                  child: ExplosionOverlay(
                    key: ValueKey('explosion_${exploded.row}_${exploded.col}'),
                    epicenter: Offset(
                      (exploded.col + 0.5) / cols,
                      (exploded.row + 0.5) / rows,
                    ),
                  ),
                ),
            ],
          ),
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            BoardShakeWrapper(
              triggerShake: isLost,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 2.5,
                panEnabled: _isZoomed,
                boundaryMargin: const EdgeInsets.all(24),
                child: Center(child: boardContent),
              ),
            ),
            if (_isZoomed)
              Positioned(
                bottom: 8,
                right: 8,
                child: Material(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _resetZoom,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_out_map_rounded,
                            size: 16,
                            color: AppColors.neonCyan,
                          ),
                          SizedBox(width: 6),
                          Text(
                            AppStrings.resetZoom,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonCyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
