import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matreshka/features/exports.dart';

import '../../../helpers/fixtures.dart';

class _FakeRepository implements BattlePassRepository {
  bool failClaims = false;

  @override
  Future<Result<BattlePassSeason>> getSeason() async =>
      Result.success(season());

  @override
  Future<Result<BattlePassSeason>> claimLevel(
    BattlePassSeason season,
    int levelNumber,
  ) async => failClaims
      ? Result.failure(const Failure('claim failed'))
      : Result.success(season.claimLevel(levelNumber));

  @override
  Future<Result<BattlePassSeason>> claimAllRewards(
    BattlePassSeason season,
  ) async => Result.success(season.claimAll());
}

void main() {
  late _FakeRepository repository;
  late DemoScenarioStore scenario;

  BattlePassCubit buildCubit() => BattlePassCubit(
    getSeason: GetSeason(repository),
    claimLevel: ClaimLevel(repository),
    claimAllRewards: ClaimAllRewards(repository),
    demoScenario: scenario,
  );

  List<LevelState> states(BattlePassState state) =>
      (state as BattlePassLoaded).season.levels.map((l) => l.state).toList();

  setUp(() {
    repository = _FakeRepository();
    scenario = DemoScenarioStore();
  });

  blocTest<BattlePassCubit, BattlePassState>(
    'при создании загружает сезон текущего сценария',
    build: buildCubit,
    expect: () => [
      BattlePassLoaded(
        season: season(),
        scenario: BattlePassScenario.premiumLocked,
      ),
    ],
  );

  blocTest<BattlePassCubit, BattlePassState>(
    'смена сценария переключает мок-бэкенд без промежуточной загрузки',
    build: buildCubit,
    act: (cubit) => cubit.switchScenario(BattlePassScenario.maxLevel),
    skip: 1,
    expect: () => [
      isA<BattlePassLoaded>().having(
        (s) => s.scenario,
        'scenario',
        BattlePassScenario.maxLevel,
      ),
    ],
    verify: (_) => expect(scenario.current, BattlePassScenario.maxLevel),
  );

  blocTest<BattlePassCubit, BattlePassState>(
    'claimLevel забирает уровень',
    build: buildCubit,
    act: (cubit) => cubit.claimLevel(1),
    skip: 1,
    expect: () => [
      predicate<BattlePassState>((s) => states(s).first == LevelState.claimed),
    ],
  );

  blocTest<BattlePassCubit, BattlePassState>(
    'параллельные claimLevel не затирают друг друга',
    build: buildCubit,
    act: (cubit) => Future.wait([cubit.claimLevel(1), cubit.claimLevel(2)]),
    verify: (cubit) => expect(states(cubit.state).take(2), [
      LevelState.claimed,
      LevelState.claimed,
    ]),
  );

  blocTest<BattlePassCubit, BattlePassState>(
    'ошибка получения не роняет экран, а отдаётся разовой ошибкой',
    build: buildCubit,
    act: (cubit) {
      repository.failClaims = true;
      return cubit.claimLevel(1);
    },
    skip: 1,
    expect: () => [
      isA<BattlePassLoaded>()
          .having((s) => s.season, 'season', season())
          .having((s) => s.actionError?.message, 'error', 'claim failed'),
    ],
  );

  blocTest<BattlePassCubit, BattlePassState>(
    'claimAllRewards забирает все доступные уровни',
    build: buildCubit,
    act: (cubit) => cubit.claimAllRewards(),
    skip: 1,
    expect: () => [
      predicate<BattlePassState>(
        (s) =>
            states(s).where((state) => state == LevelState.claimable).isEmpty,
      ),
    ],
  );
}
