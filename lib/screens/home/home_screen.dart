import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/constants/app_colors.dart';
import 'package:mayin_tarlasi/core/constants/app_dimensions.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/core/router/app_router.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:mayin_tarlasi/widgets/neon_background.dart';
import 'package:mayin_tarlasi/widgets/neon_button.dart';

/// Neon temalı uygulama ana ekranı.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(settingsProvider).accentTheme;

    return NeonBackground(
      accentColor: accent.primary,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxContentWidth,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 18),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HeroEmblem(
                        primaryColor: accent.primary,
                        secondaryColor: accent.secondary,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [accent.primary, accent.secondary],
                        ).createShader(bounds),
                        child: const Text(
                          AppStrings.appTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.primary.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.primary.withValues(alpha: 0.18),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          AppStrings.appSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                            color: accent.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      const Text(
                        AppStrings.homeTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl + 4),
                      NeonButton(
                        label: AppStrings.startGame,
                        icon: Icons.play_arrow_rounded,
                        accentColor: accent.primary,
                        isPrimary: true,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.difficulty);
                        },
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Row(
                        children: [
                          Expanded(
                            child: NeonButton(
                              label: AppStrings.statsTitle,
                              icon: Icons.bar_chart_rounded,
                              accentColor: AppColors.neonYellow,
                              height: 50,
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.stats);
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm + 4),
                          Expanded(
                            child: NeonButton(
                              label: AppStrings.settingsTitle,
                              icon: Icons.settings_rounded,
                              accentColor: accent.secondary,
                              height: 50,
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.settings,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.md),
                      NeonButton(
                        label: AppStrings.exitGame,
                        icon: Icons.power_settings_new_rounded,
                        accentColor: AppColors.neonPurple,
                        height: 48,
                        onPressed: SystemNavigator.pop,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroEmblem extends StatelessWidget {
  const _HeroEmblem({
    required this.primaryColor,
    required this.secondaryColor,
  });

  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      height: 152,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.34),
                  blurRadius: 38,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: secondaryColor.withValues(alpha: 0.24),
                  blurRadius: 52,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/mine_logo.png',
            width: 152,
            height: 152,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Icon(
              Icons.brightness_7_rounded,
              size: 64,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
