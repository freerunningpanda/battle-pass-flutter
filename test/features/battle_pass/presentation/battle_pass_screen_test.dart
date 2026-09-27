import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matreshka/features/exports.dart';

void main() {
  // По умолчанию flutter test рисует текст шрифтом Ahem другой ширины —
  // без настоящего шрифта ловились бы ложные переполнения.
  setUpAll(() async {
    final font = FontLoader('Geologica')
      ..addFont(rootBundle.load('assets/fonts/Geologica-Variable.ttf'));
    await font.load();
  });
  setUp(initDependencyInjection);
  tearDown(sl.reset);

  testWidgets('экран строится и переключается по всем сценариям', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(AppDimens.designWidth, AppDimens.designHeight)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.appTheme, home: const BattlePassScreen()),
    );
    await tester.pumpAndSettle();

    final cubit = BlocProvider.of<BattlePassCubit>(
      tester.element(find.byType(Scaffold).first),
    );
    for (final scenario in BattlePassScenario.values) {
      await cubit.switchScenario(scenario);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: scenario.name);
      expect(find.byType(RewardsTrack), findsOneWidget);
    }
  });
}
