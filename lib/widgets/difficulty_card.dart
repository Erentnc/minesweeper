import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';

/// Zorluk seçimi ekranında kullanılan neon vurgulu seviye kartı.
class DifficultyCard extends StatelessWidget {
  const DifficultyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gridLabel,
    required this.minesLabel,
    required this.accentColor,
    required this.icon,
    required this.onTap,
    this.recordLabel,
  });

  final String title;
  final String subtitle;
  final String gridLabel;
  final String minesLabel;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;
  final String? recordLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: AppDimensions.sm,
                        runSpacing: AppDimensions.xs,
                        children: [
                          _InfoChip(
                            label: gridLabel,
                            color: AppColors.textPrimary,
                          ),
                          _InfoChip(
                            label: minesLabel,
                            color: accentColor,
                          ),
                          if (recordLabel != null)
                            _InfoChip(
                              label: recordLabel!,
                              color: AppColors.neonYellow,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: accentColor.withValues(alpha: 0.8),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

