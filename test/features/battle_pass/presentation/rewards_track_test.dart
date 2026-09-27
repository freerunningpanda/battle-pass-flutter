import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matreshka/core/exports.dart';
import 'package:matreshka/features/exports.dart';

Future<BattlePassSeason> _season(BattlePassScenario scenario) async {
  final repository = BattlePassRepositoryImpl(
    mockApi: BattlePassMockApi(
      scenario: DemoScenarioStore()..current = scenario,
    ),
  );
  return (await repository.getSeason() as Success<BattlePassSeason>).data;
}

Future<ScrollPosition> _pumpTrack(
  WidgetTester tester,
  BattlePassScenario scenario,
) async {
  tester.view
    ..physicalSize = const Size(AppDimens.designWidth, AppDimens.designHeight)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final season = await tester.runAsync(() => _season(scenario));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.appTheme,
      home: Scaffold(
        body: Stack(
          children: [
            RewardsTrack(
              season: season!,
              appearance: ScenarioLayout.of(scenario).track,
              onClaim: (_) {},
              onUnlockPremium: () {},
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.state<ScrollableState>(find.byType(Scrollable)).position;
}

void main() {
  testWidgets('без премиума трек открывается с начала', (tester) async {
    final position = await _pumpTrack(tester, BattlePassScenario.premiumLocked);

    expect(position.pixels, 0);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
  });

  testWidgets('с премиумом трек сдвигается на один уровень', (tester) async {
    final position = await _pumpTrack(
      tester,
      BattlePassScenario.premiumUnlockedWithReward,
    );

    expect(position.pixels, 254);
  });

  testWidgets('"Конец наград" открывается ровно в конце трека', (tester) async {
    final position = await _pumpTrack(
      tester,
      BattlePassScenario.rewardsEndedPremiumOwned,
    );

    expect(position.pixels, position.maxScrollExtent);
    expect(position.maxScrollExtent, greaterThan(0));
  });

  testWidgets('стрелка к юбилейному уровню ставит его по центру', (
    tester,
  ) async {
    final position = await _pumpTrack(tester, BattlePassScenario.premiumLocked);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    final viewport = position.viewportDimension;
    const leading = PremiumTeaserCluster.width + 12;
    final expected = leading + 9 * 254 - (viewport - 254) / 2;
    expect(position.pixels, closeTo(expected, 0.5));
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  });
}
