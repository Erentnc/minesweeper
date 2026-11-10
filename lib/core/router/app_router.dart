import 'package:flutter/material.dart';
import 'package:mayin_tarlasi/screens/difficulty/custom_setup_screen.dart';
import 'package:mayin_tarlasi/screens/difficulty/difficulty_screen.dart';
import 'package:mayin_tarlasi/screens/game/game_screen.dart';
import 'package:mayin_tarlasi/screens/home/home_screen.dart';
import 'package:mayin_tarlasi/screens/settings/settings_screen.dart';
import 'package:mayin_tarlasi/screens/splash/splash_screen.dart';
import 'package:mayin_tarlasi/screens/stats/stats_screen.dart';

/// Uygulama içi rota adları.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String difficulty = '/difficulty';
  static const String customSetup = '/custom-setup';
  static const String game = '/game';
  static const String stats = '/stats';
  static const String settings = '/settings';
}

/// Uygulamanın merkezi rota oluşturucusu.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.difficulty => const DifficultyScreen(),
      AppRoutes.customSetup => const CustomSetupScreen(),
      AppRoutes.game => const GameScreen(),
      AppRoutes.stats => const StatsScreen(),
      AppRoutes.settings => const SettingsScreen(),
      _ => const SplashScreen(),
    };

    final isHomeFromSplash = settings.name == AppRoutes.home;

    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration(milliseconds: isHomeFromSplash ? 420 : 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        if (isHomeFromSplash) {
          return FadeTransition(opacity: curved, child: child);
        }
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
