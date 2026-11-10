import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/core/router/app_router.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/providers/game_provider.dart';
import 'package:mayin_tarlasi/widgets/neon_background.dart';
import 'package:mayin_tarlasi/widgets/neon_button.dart';

/// Kullanıcının özel tarla boyutunu ve mayın sayısını ayarladığı ekran.
class CustomSetupScreen extends ConsumerStatefulWidget {
  const CustomSetupScreen({super.key});

  @override
  ConsumerState<CustomSetupScreen> createState() => _CustomSetupScreenState();
}

class _CustomSetupScreenState extends ConsumerState<CustomSetupScreen> {
  int _gridSize = AppDimensions.defaultCustomGridSize;
  int _mineCount = AppDimensions.defaultCustomMines;

  int get _maxMines => DifficultyConfig.maxMinesFor(_gridSize, _gridSize);

  void _onGridSizeChanged(double value) {
    setState(() {
      _gridSize = value.round();
      if (_mineCount > _maxMines) {
        _mineCount = _maxMines;
      }
    });
  }

  void _startCustomGame() {
    final config = DifficultyConfig.custom(
      gridSize: _gridSize,
      mineCount: _mineCount,
    );
    ref.read(selectedDifficultyProvider.notifier).select(config);
    Navigator.pushNamed(context, AppRoutes.game);
  }

  @override
  Widget build(BuildContext context) {
    final totalCells = _gridSize * _gridSize;
    final density = ((_mineCount / totalCells) * 100).toStringAsFixed(1);

    return NeonBackground(
      accentColor: AppColors.neonPurple,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(AppStrings.customSetupTitle),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      AppStrings.customSetupHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _SliderPanel(
                      label: AppStrings.gridSizeLabel,
                      valueLabel: '$_gridSize × $_gridSize',
                      accentColor: AppColors.neonCyan,
                      value: _gridSize.toDouble(),
                      min: AppDimensions.minCustomGridSize.toDouble(),
                      max: AppDimensions.maxCustomGridSize.toDouble(),
                      divisions: AppDimensions.maxCustomGridSize -
                          AppDimensions.minCustomGridSize,
                      onChanged: _onGridSizeChanged,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _SliderPanel(
                      label: AppStrings.mineCountLabel,
                      valueLabel: '$_mineCount Mayın',
                      accentColor: AppColors.neonPurple,
                      value: _mineCount.toDouble(),
                      min: AppDimensions.minCustomMines.toDouble(),
                      max: _maxMines.toDouble(),
                      divisions: _maxMines - AppDimensions.minCustomMines,
                      onChanged: (value) {
                        setState(() {
                          _mineCount = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: AppColors.neonPurple.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(
                            label: 'TOPLAM KARE',
                            value: '$totalCells',
                            color: AppColors.textPrimary,
                          ),
                          _SummaryItem(
                            label: 'MAYIN',
                            value: '$_mineCount',
                            color: AppColors.neonPurple,
                          ),
                          _SummaryItem(
                            label: 'YOĞUNLUK',
                            value: '%$density',
                            color: AppColors.neonCyan,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    NeonButton(
                      label: AppStrings.startCustomGame,
                      icon: Icons.play_arrow_rounded,
                      accentColor: AppColors.neonPurple,
                      isPrimary: true,
                      onPressed: _startCustomGame,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderPanel extends StatelessWidget {
  const _SliderPanel({
    required this.label,
    required this.valueLabel,
    required this.accentColor,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final Color accentColor;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions > 0 ? divisions : null,
            activeColor: accentColor,
            thumbColor: accentColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: color,
          ),
        ),
      ],
    );
  }
}
