import 'package:flutter_test/flutter_test.dart';
import 'package:matreshka/features/exports.dart';

void main() {
  List<BattlePassScenario> where(bool Function(ScenarioLayout) test) =>
      BattlePassScenario.values
          .where((s) => test(ScenarioLayout.of(s)))
          .toList();

  test('кнопка "Забрать все" — только на макс. уровне', () {
    expect(where((l) => l.claimAllButton), [BattlePassScenario.maxLevel]);
  });

  test('трек открывается в конце только в "Конец наград"', () {
    expect(where((l) => l.track.startScrolledToEnd), [
      BattlePassScenario.rewardsEndedPremiumOwned,
      BattlePassScenario.rewardsEndedPremiumNotOwned,
    ]);
  });

  test('итоговое сообщение вместо заданий — только когда БП завершён', () {
    expect(where((l) => l.endedNotice), [BattlePassScenario.completed]);
  });
}
