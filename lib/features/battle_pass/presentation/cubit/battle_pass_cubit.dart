import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../exports.dart';

class BattlePassCubit extends Cubit<BattlePassState> {
  BattlePassCubit({
    required GetSeason getSeason,
    required ClaimLevel claimLevel,
    required ClaimAllRewards claimAllRewards,
    required DemoScenarioStore demoScenario,
  }) : _getSeason = getSeason,
       _claimLevel = claimLevel,
       _claimAllRewards = claimAllRewards,
       _demoScenario = demoScenario,
       super(const BattlePassLoading()) {
    switchScenario(demoScenario.current);
  }

  final GetSeason _getSeason;
  final ClaimLevel _claimLevel;
  final ClaimAllRewards _claimAllRewards;
  final DemoScenarioStore _demoScenario;

  /// Действия над сезоном выполняются строго по очереди: каждое берёт
  /// сезон, уже обновлённый предыдущим.
  Future<void> _queue = Future.value();

  /// Без промежуточного [BattlePassLoading] — экран не мигает при смене
  /// сценария, старый сезон остаётся до прихода нового.
  Future<void> switchScenario(BattlePassScenario scenario) =>
      _enqueue(() async {
        _demoScenario.current = scenario;
        final result = await _getSeason(const NoParams());
        emit(
          result.fold(
            onSuccess: (season) =>
                BattlePassLoaded(season: season, scenario: scenario),
            onFailure: (failure) => BattlePassError(failure.message),
          ),
        );
      });

  /// Мок-покупка премиума: реального IAP нет, переключаем сценарий.
  Future<void> purchasePremium() =>
      switchScenario(BattlePassScenario.premiumUnlockedWithReward);

  /// Мок-повышение уровня: так же переключаем сценарий.
  Future<void> increaseLevel() => switchScenario(BattlePassScenario.maxLevel);

  Future<void> claimLevel(int levelNumber) => _updateSeason(
    (season) =>
        _claimLevel(ClaimLevelParams(season: season, levelNumber: levelNumber)),
  );

  Future<void> claimAllRewards() => _updateSeason(_claimAllRewards.call);

  Future<void> _updateSeason(
    Future<Result<BattlePassSeason>> Function(BattlePassSeason season) action,
  ) => _enqueue(() async {
    final current = state;
    if (current is! BattlePassLoaded) return;
    final result = await action(current.season);
    emit(
      result.fold(
        onSuccess: (season) =>
            BattlePassLoaded(season: season, scenario: current.scenario),
        onFailure: (failure) => BattlePassLoaded(
          season: current.season,
          scenario: current.scenario,
          actionError: ActionError(failure.message),
        ),
      ),
    );
  });

  Future<void> _enqueue(Future<void> Function() task) =>
      _queue = _queue.then((_) => isClosed ? null : task());
}
