import 'package:flutter_test/flutter_test.dart';
import 'package:matreshka/features/exports.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('BattlePassSeason.claimLevel', () {
    test('с премиумом забирает обе награды уровня', () {
      final claimed = season().claimLevel(1).levels.first;

      expect(claimed.state, LevelState.claimed);
      expect(claimed.freeReward!.claimed, isTrue);
      expect(claimed.premiumReward!.claimed, isTrue);
    });

    test('без премиума премиальную награду не трогает', () {
      final claimed = season(premiumOwned: false).claimLevel(1).levels.first;

      expect(claimed.state, LevelState.claimed);
      expect(claimed.freeReward!.claimed, isTrue);
      expect(claimed.premiumReward!.claimed, isFalse);
    });

    test('уровень без премиальной награды забирается целиком', () {
      final source = season(
        levels: [level(1, LevelState.claimable, withPremium: false)],
      );

      final claimed = source.claimLevel(1).levels.single;

      expect(claimed.state, LevelState.claimed);
      expect(claimed.premiumReward, isNull);
    });

    test('недоступные уровни не меняются', () {
      final source = season();

      expect(source.claimLevel(3), source);
      expect(source.claimLevel(4), source);
      expect(source.claimLevel(99), source);
    });

    test('остальные уровни не затрагиваются', () {
      final result = season().claimLevel(1);

      expect(result.levels[1].state, LevelState.claimable);
    });
  });

  group('BattlePassSeason.claimAll', () {
    test('забирает все доступные уровни и только их', () {
      final states = season().claimAll().levels.map((l) => l.state);

      expect(states, [
        LevelState.claimed,
        LevelState.claimed,
        LevelState.current,
        LevelState.locked,
      ]);
    });

    test('без премиума премиальные награды остаются неполученными', () {
      final levels = season(premiumOwned: false).claimAll().levels;

      expect(levels.take(2).every((l) => !l.premiumReward!.claimed), isTrue);
    });
  });

  group('BattlePassSeason.nextLevelXp', () {
    test('порог текущего уровня', () {
      expect(season(currentLevel: 3).nextLevelXp, 3000);
    });

    test('null на максимальном уровне', () {
      expect(season(currentLevel: 4).nextLevelXp, isNull);
    });
  });
}
