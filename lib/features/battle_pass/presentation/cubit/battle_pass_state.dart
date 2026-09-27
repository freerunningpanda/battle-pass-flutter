import 'package:equatable/equatable.dart';

import '../../../exports.dart';

sealed class BattlePassState extends Equatable {
  const BattlePassState();

  @override
  List<Object?> get props => [];
}

final class BattlePassLoading extends BattlePassState {
  const BattlePassLoading();
}

final class BattlePassLoaded extends BattlePassState {
  const BattlePassLoaded({
    required this.season,
    required this.scenario,
    this.actionError,
  });

  final BattlePassSeason season;
  final BattlePassScenario scenario;

  /// Ошибка последнего действия (получения наград) — экран остаётся
  /// загруженным, ошибка показывается разово.
  final ActionError? actionError;

  @override
  List<Object?> get props => [season, scenario, actionError];
}

final class BattlePassError extends BattlePassState {
  const BattlePassError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Сравнивается по ссылке, а не по тексту: одна и та же ошибка дважды
/// подряд — два разных состояния, и обе показываются.
final class ActionError {
  ActionError(this.message);

  final String message;
}
