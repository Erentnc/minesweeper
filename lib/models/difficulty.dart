import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';

/// Oyunun desteklediği zorluk seviyeleri.
enum GameDifficulty {
  easy,
  medium,
  hard,
  custom,
}

/// Seçilen zorluk seviyesinin tahta boyutunu, mayın sayısını ve görsel
/// kimliğini tanımlayan yapılandırma sınıfı.
@immutable
class DifficultyConfig {
  const DifficultyConfig({
    required this.difficulty,
    required this.label,
    required this.subtitle,
    required this.rows,
    required this.cols,
    required this.mineCount,
    required this.accentColor,
  });

  final GameDifficulty difficulty;
  final String label;
  final String subtitle;
  final int rows;
  final int cols;
  final int mineCount;
  final Color accentColor;

  /// Toplam hücre sayısı.
  int get totalCells => rows * cols;

  /// Mayınsız güvenli hücre sayısı.
  int get safeCells => totalCells - mineCount;

  /// Tahta boyutunun yüzde kaçının mayın olduğu.
  double get mineDensityPercent =>
      totalCells == 0 ? 0 : (mineCount / totalCells) * 100;

  static const DifficultyConfig easy = DifficultyConfig(
    difficulty: GameDifficulty.easy,
    label: AppStrings.easy,
    subtitle: 'Başlangıç için ideal, hızlı turlar',
    rows: 5,
    cols: 5,
    mineCount: 3,
    accentColor: AppColors.neonGreen,
  );

  static const DifficultyConfig medium = DifficultyConfig(
    difficulty: GameDifficulty.medium,
    label: AppStrings.medium,
    subtitle: 'Dengeli taktik ve dikkat gerektirir',
    rows: 8,
    cols: 8,
    mineCount: 10,
    accentColor: AppColors.neonCyan,
  );

  static const DifficultyConfig hard = DifficultyConfig(
    difficulty: GameDifficulty.hard,
    label: AppStrings.hard,
    subtitle: 'Yoğun mayın alanı, gerçek meydan okuma',
    rows: 10,
    cols: 10,
    mineCount: 15,
    accentColor: AppColors.neonRed,
  );

  /// Özel seviye oluşturur ve mayın sayısının oynanabilir sınırlar içinde
  /// kalmasını garanti eder.
  factory DifficultyConfig.custom({
    required int gridSize,
    required int mineCount,
  }) {
    final clampedSize = gridSize.clamp(
      AppDimensions.minCustomGridSize,
      AppDimensions.maxCustomGridSize,
    );
    final maxAllowedMines = maxMinesFor(clampedSize, clampedSize);
    final clampedMines = mineCount.clamp(
      AppDimensions.minCustomMines,
      maxAllowedMines,
    );

    return DifficultyConfig(
      difficulty: GameDifficulty.custom,
      label: AppStrings.custom,
      subtitle: '$clampedSize×$clampedSize tarlada $clampedMines mayın',
      rows: clampedSize,
      cols: clampedSize,
      mineCount: clampedMines,
      accentColor: AppColors.neonPurple,
    );
  }

  /// Özel oyunlarda tahtanın oynanabilir kalması için izin verilen maksimum mayın.
  static int maxMinesFor(int rows, int cols) {
    final total = rows * cols;
    final maxByRatio = (total * 0.45).floor();
    return maxByRatio.clamp(AppDimensions.minCustomMines, total - 1);
  }

  static const List<DifficultyConfig> presets = [
    easy,
    medium,
    hard,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DifficultyConfig &&
        other.difficulty == difficulty &&
        other.rows == rows &&
        other.cols == cols &&
        other.mineCount == mineCount;
  }

  @override
  int get hashCode => Object.hash(difficulty, rows, cols, mineCount);
}

