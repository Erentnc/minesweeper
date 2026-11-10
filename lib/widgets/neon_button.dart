import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';

/// Uygulama genelinde buton tekrarlarını önleyen neon temalı yeniden kullanılabilir buton.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.accentColor = AppColors.neonCyan,
    this.isPrimary = false,
    this.width = double.infinity,
    this.height = AppDimensions.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color accentColor;
  final bool isPrimary;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.42,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      accentColor,
                      AppColors.neonIndigo,
                    ],
                  )
                : null,
            color: isPrimary ? null : AppColors.surfaceElevated,
            border: Border.all(
              color: accentColor.withValues(alpha: isPrimary ? 0.9 : 0.6),
              width: 1.5,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color:
                          accentColor.withValues(alpha: isPrimary ? 0.35 : 0.14),
                      blurRadius: isPrimary ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20,
                        color: isPrimary ? AppColors.background : accentColor,
                      ),
                      const SizedBox(width: AppDimensions.sm),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color:
                                isPrimary ? AppColors.background : accentColor,
                          ),
                        ),
                      ),
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
