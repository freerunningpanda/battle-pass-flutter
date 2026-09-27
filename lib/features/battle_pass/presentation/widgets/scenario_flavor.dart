import '../../../exports.dart';

/// Контент центрального предмета под каждый сценарий — не часть схемы
/// данных боевого пропуска. Отличия в разметке — см. [ScenarioLayout].
class ScenarioFlavor {
  const ScenarioFlavor({
    required this.itemAsset,
    required this.itemTitle,
    required this.infoText,
    this.tag,
    this.itemOffsetY = 0,
    this.itemScale = 1,
  });

  final String itemAsset;
  final String itemTitle;

  /// Текст диалога по тапу на инфо-иконку.
  final String infoText;

  /// Тег над названием; `null` — без тега.
  final String? tag;

  /// Сдвиг картинки по вертикали (отрицательный — выше).
  final double itemOffsetY;

  /// Масштаб картинки сверх BoxFit.contain.
  final double itemScale;

  static ScenarioFlavor of(BattlePassScenario scenario) => switch (scenario) {
    BattlePassScenario.premiumLocked => const ScenarioFlavor(
      itemAsset: AppAssets.imageItemLocked,
      itemTitle: AppStrings.itemTitleMegaPack,
      infoText: AppStrings.itemInfoMegaPackBody,
      tag: AppStrings.itemTagAvailableWithPremium,
    ),
    BattlePassScenario.premiumUnlockedWithReward => const ScenarioFlavor(
      itemAsset: AppAssets.imageItemPurchased,
      itemTitle: AppStrings.itemTitleFatalWomanOrMafiaBoss,
      infoText: AppStrings.itemInfoFatalWomanOrMafiaBossBody,
      tag: AppStrings.itemTagAvailableWithPremium,
      itemScale: 1.22,
    ),
    BattlePassScenario.rewardsEndedPremiumOwned ||
    BattlePassScenario.rewardsEndedPremiumNotOwned => const ScenarioFlavor(
      itemAsset: AppAssets.imageBullets,
      itemTitle: AppStrings.itemTitleMegaPack,
      infoText: AppStrings.itemInfoMegaPackBody,
      tag: AppStrings.itemTagAvailableWithPremium,
      itemScale: 1.12,
    ),
    BattlePassScenario.maxLevel ||
    BattlePassScenario.completed ||
    BattlePassScenario.premiumUnlockedNoReward ||
    BattlePassScenario.maxLevelNoReward => const ScenarioFlavor(
      itemAsset: AppAssets.imageItemMaxLevel,
      itemTitle: AppStrings.itemTitleMegaPack,
      infoText: AppStrings.itemInfoMegaPackBody,
      itemOffsetY: -70,
      itemScale: 1.06,
    ),
  };
}
