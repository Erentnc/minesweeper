import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mayin_tarlasi/animations/confetti_animation.dart';
import 'package:mayin_tarlasi/core/constants/app_strings.dart';
import 'package:mayin_tarlasi/main.dart';
import 'package:mayin_tarlasi/models/cell_model.dart';
import 'package:mayin_tarlasi/models/difficulty.dart';
import 'package:mayin_tarlasi/providers/game_provider.dart';
import 'package:mayin_tarlasi/screens/home/home_screen.dart';
import 'package:mayin_tarlasi/screens/splash/splash_screen.dart';
import 'package:mayin_tarlasi/widgets/mine_cell.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MayinTarlasiApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1800));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Açılışta logo ekranı görünür ve ardından ana sayfaya geçilir',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MayinTarlasiApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text(AppStrings.appTitle), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(AppStrings.startGame), findsOneWidget);
  });

  testWidgets('Ana sayfadan zorluk seçimi, bayrak modu ve oyun ekranı akışı',
      (WidgetTester tester) async {
    await _pumpPastSplash(tester);

    expect(find.text(AppStrings.appTitle), findsOneWidget);
    expect(find.text(AppStrings.startGame), findsOneWidget);

    await tester.tap(find.text(AppStrings.startGame));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.text(AppStrings.selectDifficulty), findsOneWidget);
    expect(find.text(AppStrings.easy), findsOneWidget);
    expect(find.text(AppStrings.medium), findsOneWidget);
    expect(find.text(AppStrings.hard), findsOneWidget);
    expect(find.text(AppStrings.custom), findsOneWidget);

    await tester.tap(find.text(AppStrings.easy));
    await tester.pumpAndSettle();

    expect(find.text('KOLAY • 5×5'), findsOneWidget);
    expect(find.byType(MineCell), findsNWidgets(25));
    expect(find.text('03'), findsOneWidget);
    expect(find.text('🙂'), findsOneWidget);

    // Bayrak moduna geçip bir hücreye bayrak koyduğumuzda sayaç 02'ye düşer
    await tester.tap(find.text(AppStrings.flagMode));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MineCell).first);
    await tester.pumpAndSettle();

    expect(find.text('02'), findsOneWidget);
  });

  testWidgets('Mayına basıldığında patlama animasyonu ve sonuç diyaloğu görünür',
      (WidgetTester tester) async {
    await _pumpPastSplash(tester);

    await tester.tap(find.text(AppStrings.startGame));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.easy));
    await tester.pumpAndSettle();

    // Deterministik tek mayınlı bir test tahtası yükle
    final element = tester.element(find.byType(MineCell).first);
    final container = ProviderScope.containerOf(element);
    container.read(gameProvider.notifier).loadTestBoard(
      config: DifficultyConfig.easy,
      grid: List.generate(
        5,
        (r) => List.generate(
          5,
          (c) => CellModel(
            row: r,
            col: c,
            isMine: r == 0 && c == 0,
            neighborMines: (r <= 1 && c <= 1 && !(r == 0 && c == 0)) ? 1 : 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // (0,0) mayınına dokun
    await tester.tap(find.byType(MineCell).first);
    await tester.pump();
    expect(find.text('😵'), findsOneWidget);

    // Patlama gecikmesi (560ms) sonrası sonuç diyalogu açılır
    await tester.pumpAndSettle(const Duration(milliseconds: 700));
    expect(find.text(AppStrings.lossTitle), findsOneWidget);
  });

  testWidgets('Oyun kazanıldığında konfeti ve yeni rekor rozeti görünür',
      (WidgetTester tester) async {
    await _pumpPastSplash(tester);

    await tester.tap(find.text(AppStrings.startGame));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.easy));
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(MineCell).first);
    final container = ProviderScope.containerOf(element);
    container.read(gameProvider.notifier).loadTestBoard(
      config: DifficultyConfig.custom(gridSize: 6, mineCount: 3)
          .copyWithEasyForTest(),
      grid: List.generate(
        5,
        (r) => List.generate(
          5,
          (c) => CellModel(
            row: r,
            col: c,
            isMine: r == 4 && c == 4,
            neighborMines: (r >= 3 && c >= 3 && !(r == 4 && c == 4)) ? 1 : 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MineCell).first);
    await tester.pump();
    expect(find.byType(ConfettiOverlay), findsOneWidget);
    expect(find.text('😎'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text(AppStrings.winTitle), findsOneWidget);
    expect(find.text(AppStrings.newRecordBadge), findsOneWidget);
  });

  testWidgets('İstatistikler ve Ayarlar ekranları açılır ve ayar değişir',
      (WidgetTester tester) async {
    await _pumpPastSplash(tester);

    await tester.tap(find.text(AppStrings.statsTitle));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.text(AppStrings.totalGames), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.settingsTitle));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.text(AppStrings.firstClickSafetyLabel), findsOneWidget);
    expect(find.text(AppStrings.themeAccentLabel), findsOneWidget);

    await tester.tap(find.text('Synthwave'));
    await tester.pumpAndSettle();
  });

  testWidgets('Özel oyun kurulum ekranı akışı', (WidgetTester tester) async {
    await _pumpPastSplash(tester);

    await tester.tap(find.text(AppStrings.startGame));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(AppStrings.custom),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(AppStrings.custom));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.customSetupTitle), findsOneWidget);
    expect(find.text('12 × 12'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(AppStrings.startCustomGame),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(AppStrings.startCustomGame));
    await tester.pumpAndSettle();

    expect(find.text('ÖZEL • 12×12'), findsOneWidget);
    expect(find.byType(MineCell), findsNWidgets(144));
  });
}

extension on DifficultyConfig {
  DifficultyConfig copyWithEasyForTest() {
    return const DifficultyConfig(
      difficulty: GameDifficulty.easy,
      label: AppStrings.easy,
      subtitle: 'Test',
      rows: 5,
      cols: 5,
      mineCount: 1,
      accentColor: Colors.green,
    );
  }
}
