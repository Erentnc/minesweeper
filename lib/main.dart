import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/core/router/app_router.dart';
import 'package:mayin_tarlasi/core/services/storage_service.dart';
import 'package:mayin_tarlasi/core/theme/app_theme.dart';
import 'package:mayin_tarlasi/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        preloadedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MayinTarlasiApp(),
    ),
  );
}

/// Mayın Tarlası uygulamasının kök widget'ı.
class MayinTarlasiApp extends ConsumerWidget {
  const MayinTarlasiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(
      settingsProvider.select((settings) => settings.accentTheme),
    );

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkThemeFor(accent),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
