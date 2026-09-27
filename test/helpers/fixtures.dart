import 'package:matreshka/features/exports.dart';

const freeReward = Reward(
  id: 1,
  name: 'free',
  iconAsset: '',
  amount: 1,
  rarity: RewardRarity.common,
  claimed: false,
);

const premiumReward = Reward(
  id: 2,
  name: 'premium',
  iconAsset: '',
  amount: 1,
  rarity: RewardRarity.epic,
  claimed: false,
);

BattlePassLevel level(
  int number,
  LevelState state, {
  bool withPremium = true,
}) => BattlePassLevel(
  number: number,
  requiredXp: number * 1000,
  state: state,
  freeReward: freeReward,
  premiumReward: withPremium ? premiumReward : null,
);

BattlePassSeason season({
  bool premiumOwned = true,
  int currentLevel = 3,
  List<BattlePassLevel>? levels,
}) => BattlePassSeason(
  seasonId: 1,
  seasonName: 'test',
  premiumOwned: premiumOwned,
  currentLevel: currentLevel,
  currentXp: currentLevel * 1000 - 500,
  maxLevel: 4,
  levels:
      levels ??
      [
        level(1, LevelState.claimable),
        level(2, LevelState.claimable),
        level(3, LevelState.current),
        level(4, LevelState.locked),
      ],
  seasonEndsAt: DateTime(2030),
);
