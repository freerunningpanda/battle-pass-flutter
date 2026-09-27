import 'package:equatable/equatable.dart';

import 'level.dart';

class BattlePassSeason extends Equatable {
  const BattlePassSeason({
    required this.seasonId,
    required this.seasonName,
    required this.premiumOwned,
    required this.currentLevel,
    required this.currentXp,
    required this.maxLevel,
    required this.levels,
    required this.seasonEndsAt,
  });

  final int seasonId;
  final String seasonName;
  final bool premiumOwned;
  final int currentLevel;
  final int currentXp;
  final int maxLevel;
  final List<BattlePassLevel> levels;
  final DateTime seasonEndsAt;

  bool get isMaxLevel => currentLevel >= maxLevel;

  /// Порог опыта, на котором закончится текущий уровень; `null` на
  /// максимальном уровне.
  int? get nextLevelXp =>
      isMaxLevel ? null : levels[currentLevel - 1].requiredXp;

  /// Сезон после получения наград уровня [levelNumber]: бесплатной и, если
  /// премиум куплен, премиальной. Недоступный для получения уровень не
  /// меняется.
  BattlePassSeason claimLevel(int levelNumber) => copyWith(
    levels: [
      for (final level in levels)
        level.number == levelNumber ? _claimed(level) : level,
    ],
  );

  /// Сезон после получения наград всех доступных уровней.
  BattlePassSeason claimAll() =>
      copyWith(levels: [for (final level in levels) _claimed(level)]);

  BattlePassLevel _claimed(BattlePassLevel level) {
    if (level.state != LevelState.claimable) return level;
    return level.copyWith(
      state: LevelState.claimed,
      freeReward: level.freeReward?.copyWith(claimed: true),
      premiumReward: premiumOwned
          ? level.premiumReward?.copyWith(claimed: true)
          : level.premiumReward,
    );
  }

  BattlePassSeason copyWith({
    bool? premiumOwned,
    int? currentLevel,
    int? currentXp,
    List<BattlePassLevel>? levels,
  }) => BattlePassSeason(
    seasonId: seasonId,
    seasonName: seasonName,
    premiumOwned: premiumOwned ?? this.premiumOwned,
    currentLevel: currentLevel ?? this.currentLevel,
    currentXp: currentXp ?? this.currentXp,
    maxLevel: maxLevel,
    levels: levels ?? this.levels,
    seasonEndsAt: seasonEndsAt,
  );

  @override
  List<Object?> get props => [
    seasonId,
    seasonName,
    premiumOwned,
    currentLevel,
    currentXp,
    maxLevel,
    levels,
    seasonEndsAt,
  ];
}
