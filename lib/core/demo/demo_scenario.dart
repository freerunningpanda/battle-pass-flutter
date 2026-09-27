/// Состояния экрана "БП / Главная" из Figma — сценарии мок-бэкенда.
/// Это не часть предметной области: domain о них не знает, моки читают
/// текущий сценарий из [DemoScenarioStore].
enum BattlePassScenario {
  premiumLocked,
  premiumUnlockedWithReward,
  maxLevel,
  premiumUnlockedNoReward,
  maxLevelNoReward,
  completed,
  rewardsEndedPremiumOwned,
  rewardsEndedPremiumNotOwned,
}

/// Текущий сценарий мок-бэкенда — общий для моков боевого пропуска и
/// заданий. В реальном приложении на его месте был бы сервер.
class DemoScenarioStore {
  BattlePassScenario current = BattlePassScenario.premiumLocked;
}
