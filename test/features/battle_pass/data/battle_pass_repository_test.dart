import 'package:flutter_test/flutter_test.dart';
import 'package:matreshka/core/exports.dart';
import 'package:matreshka/features/exports.dart';

void main() {
  late DemoScenarioStore scenario;
  late BattlePassRepository repository;

  setUp(() {
    scenario = DemoScenarioStore();
    repository = BattlePassRepositoryImpl(
      mockApi: BattlePassMockApi(scenario: scenario),
    );
  });

  for (final value in BattlePassScenario.values) {
    test('сценарий ${value.name} разбирается без ошибок', () async {
      scenario.current = value;

      final result = await repository.getSeason();

      final season = switch (result) {
        Success(:final data) => data,
        ResultFailure(:final failure) => fail(failure.message),
      };
      expect(season.levels, hasLength(season.maxLevel));
      expect(
        season.levels.map((l) => l.number),
        List.generate(season.maxLevel, (i) => i + 1),
      );
    });
  }

  test('премиум куплен ровно в тех сценариях, где должен', () async {
    const notOwned = {
      BattlePassScenario.premiumLocked,
      BattlePassScenario.rewardsEndedPremiumNotOwned,
    };
    for (final value in BattlePassScenario.values) {
      scenario.current = value;
      final result = await repository.getSeason();
      expect(
        (result as Success<BattlePassSeason>).data.premiumOwned,
        !notOwned.contains(value),
        reason: value.name,
      );
    }
  });

  test('дедлайн сезона не сбрасывается при смене сценария', () async {
    final first = await repository.getSeason();
    scenario.current = BattlePassScenario.maxLevel;
    final second = await repository.getSeason();

    DateTime endsAt(Result<BattlePassSeason> r) =>
        (r as Success<BattlePassSeason>).data.seasonEndsAt;
    expect(endsAt(first), endsAt(second));
  });
}
