import '../../../exports.dart';

/// Что показывает экран в конкретном сценарии — вся вариативность UI между
/// сценариями собрана здесь, а не условиями по `scenario` в build.
/// Контент (тексты/картинки центрального предмета) — см. [ScenarioFlavor].
class ScenarioLayout {
  const ScenarioLayout({
    this.track = const TrackAppearance(),
    this.claimAllButton = false,
    this.inlineTaskClaim = false,
    this.endedNotice = false,
    this.levelUpEnabledAtMax = false,
  });

  final TrackAppearance track;

  /// Кнопка "Забрать все награды" под баннером (если есть что забирать).
  final bool claimAllButton;

  /// "Забрать опыт" прямо с тизера заданий.
  final bool inlineTaskClaim;

  /// Итоговое сообщение вместо тизера заданий.
  final bool endedNotice;

  /// Кнопка "Повысить уровень" активна даже на максимальном уровне.
  final bool levelUpEnabledAtMax;

  static ScenarioLayout of(BattlePassScenario scenario) => switch (scenario) {
    BattlePassScenario.premiumLocked => const ScenarioLayout(),
    BattlePassScenario.premiumUnlockedWithReward ||
    BattlePassScenario.premiumUnlockedNoReward => const ScenarioLayout(
      track: TrackAppearance(hideGiftBadges: true),
    ),
    BattlePassScenario.maxLevel => const ScenarioLayout(
      track: TrackAppearance(milestonePreview: MilestonePreviewStyle.maxLevel),
      claimAllButton: true,
      inlineTaskClaim: true,
    ),
    BattlePassScenario.maxLevelNoReward => const ScenarioLayout(
      track: TrackAppearance(
        milestonePreview: MilestonePreviewStyle.maxLevel,
        hideGiftBadges: true,
      ),
    ),
    BattlePassScenario.completed => const ScenarioLayout(
      track: TrackAppearance(
        milestonePreview: MilestonePreviewStyle.plain,
        hideGiftBadges: true,
      ),
      endedNotice: true,
      levelUpEnabledAtMax: true,
    ),
    BattlePassScenario.rewardsEndedPremiumOwned => const ScenarioLayout(
      track: TrackAppearance(
        milestonePreview: MilestonePreviewStyle.noCrown,
        seasonEndTeaser: SeasonEndTeaser.unlocksAfterMaxLevel,
        hideGiftBadges: true,
        highlightedLevel: 97,
      ),
    ),
    BattlePassScenario.rewardsEndedPremiumNotOwned => const ScenarioLayout(
      track: TrackAppearance(
        milestonePreview: MilestonePreviewStyle.noCrown,
        seasonEndTeaser: SeasonEndTeaser.requiresPremium,
        hideGiftBadges: true,
        hidePremiumBadges: true,
        highlightedLevel: 97,
        goldLevel: 100,
      ),
    ),
  };
}
