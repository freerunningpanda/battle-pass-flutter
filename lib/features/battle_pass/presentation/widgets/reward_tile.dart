import 'package:flutter/material.dart';

import '../../../exports.dart';

class RewardTile extends StatefulWidget {
  const RewardTile({
    required this.level,
    required this.premiumOwned,
    required this.currentXp,
    required this.onClaim,
    required this.onUnlockPremium,
    this.nextRequiredXp,
    this.hideGiftBadge = false,
    this.highlighted = false,
    this.hidePremiumBadge = false,
    this.gold = false,
    super.key,
  });

  final BattlePassLevel level;
  final bool premiumOwned;

  /// Значок подарка в углу не показывается (корону это не затрагивает).
  final bool hideGiftBadge;

  /// Белая рамка и значок подарка даже при [hideGiftBadge]. Зелёная рамка
  /// "к клейму готово" всё равно перевешивает — см. showClaimUi ниже.
  final bool highlighted;

  /// Корона не показывается даже у уровней с доступным премиум-апгрейдом —
  /// заливка и переход на покупку по тапу при этом не меняются.
  final bool hidePremiumBadge;

  /// Всегда золотой градиент (как у legendary) — перевешивает фиолетовую
  /// заливку "тут премиум" у уровня с доступным премиум-апгрейдом.
  final bool gold;

  /// Порог опыта следующего по порядку уровня — нужен, чтобы соединительная
  /// линия трека красилась по реальному прогрессу (currentXp относительно
  /// порогов), а не по грубому состоянию уровня. `null` для последнего
  /// уровня трека — линии дальше некуда идти.
  final int? nextRequiredXp;

  /// Накопленный опыт сезона — нужен, чтобы на тапе по своему текущему
  /// уровню показать реальную нехватку XP, а не общую фразу (иначе не
  /// понятно, почему уровень, на который "уже дошли", ещё не открывается).
  final int currentXp;

  final VoidCallback onClaim;
  final VoidCallback onUnlockPremium;

  @override
  State<RewardTile> createState() => _RewardTileState();
}

class _RewardTileState extends State<RewardTile> {
  /// Обычная (не премиум) доступная награда изначально выглядит как ещё не
  /// открытая — рамка и кнопка "Забрать" появляются только после первого
  /// тапа, а забирает уже второй.
  bool _selected = false;

  @override
  void didUpdateWidget(covariant RewardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level.state != widget.level.state) {
      _selected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;

    final level = widget.level;
    final reward = level.freeReward;
    final locked = level.state == LevelState.locked;
    final claimable = level.state == LevelState.claimable;
    final claimed = level.state == LevelState.claimed;
    // Свой текущий уровень тоже не забрать — XP на него ещё не набран,
    // поэтому визуально он ничем не должен отличаться от запертого: тот же
    // замок вместо картинки. Тап всё равно ведёт на конкретное "не хватает
    // N XP" через ветку ниже, а не на общее "откроется на N уровне".
    final visuallyLocked = locked || level.state == LevelState.current;
    final showPremiumBadge =
        level.premiumReward != null &&
        !widget.premiumOwned &&
        level.premiumReward?.claimed != true;
    // Корона всегда перевешивает: даже если бесплатная награда сама по себе
    // claimable, плитку с премиум-апгрейдом нельзя "забрать в два тапа" —
    // тап по ней должен вести к покупке прокачки, а не показывать "Забрать".
    final showClaimUi = claimable && _selected && !showPremiumBadge;

    final tile = RewardCarouselTile(
      asset: reward?.iconAsset ?? _placeholderAsset,
      // Уровни с доступным премиум-апгрейдом всегда красим в фиолетовый —
      // тот же цвет, что у fuel в премиум-тизере, это общий язык "тут премиум".
      gradient: widget.gold
          ? _rarityGradient(colors, RewardRarity.legendary)
          : showPremiumBadge
          ? _purpleGradient(colors)
          : _rarityGradient(colors, reward?.rarity),
      badge: showPremiumBadge && !widget.hidePremiumBadge
          ? RewardBadgeKind.premium
          : RewardBadgeKind.gift,
      showBadge:
          (showPremiumBadge && !widget.hidePremiumBadge) ||
          widget.highlighted ||
          !widget.hideGiftBadge,
      quantityLabel: (reward != null && reward.amount > 1)
          ? '×${reward.amount}'
          : null,
      borderColor: showClaimUi
          ? colors.claimReadyBorder
          : widget.highlighted
          ? colors.textPrimary
          : null,
      showGlow: showClaimUi,
      claimed: claimed,
      locked: visuallyLocked,
      // Плитка всегда кликабельна. Доступная бесплатная награда открывается
      // в два тапа: первый показывает рамку и кнопку "Забрать", второй —
      // уже забирает; премиум-плитка сразу ведёт к покупке прокачки, но
      // только если уровень уже достигнут — запертый ИЛИ текущий уровень
      // (XP ещё не набран) остаётся запертым независимо от короны, ведёт
      // к покупке прокачки нельзя раньше, чем сам уровень открылся.
      onTap: visuallyLocked
          ? () => _showTapHint(
              context,
              locked: locked,
              claimed: false,
              requiredXp: level.requiredXp,
            )
          : showPremiumBadge
          ? widget.onUnlockPremium
          : claimable
          ? (_selected
                ? widget.onClaim
                : () => setState(() => _selected = true))
          : () => _showTapHint(
              context,
              locked: locked,
              claimed: claimed,
              requiredXp: level.requiredXp,
            ),
      footer: showClaimUi ? const _ClaimButton() : null,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        AppSizedBoxes.verticalSizedBoxH12,
        _LevelTrackNode(
          number: level.number,
          requiredXp: level.requiredXp,
          currentXp: widget.currentXp,
          nextRequiredXp: widget.nextRequiredXp,
        ),
      ],
    );
  }

  void _showTapHint(
    BuildContext context, {
    required bool locked,
    required bool claimed,
    required int requiredXp,
  }) {
    final missingXp = requiredXp - widget.currentXp;
    final message = locked
        ? '${AppStrings.levelLockedHintPrefix}${widget.level.number}'
              '${AppStrings.levelLockedHintSuffix}'
        : claimed
        ? AppStrings.rewardAlreadyClaimedHint
        : '${AppStrings.levelMissingXpHintPrefix}$missingXp'
              '${AppStrings.levelMissingXpHintSuffix}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static const _placeholderAsset = AppAssets.imageRewardPlaceholder;

  static LinearGradient _tileGradient(Color dark, Color mid, Color light) =>
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [dark, mid, light],
      );

  Gradient _purpleGradient(MainColors colors) => _tileGradient(
    colors.rewardTilePurpleDark,
    colors.rewardTilePurpleMid,
    colors.rewardTilePurpleLight,
  );

  Gradient _rarityGradient(MainColors colors, RewardRarity? rarity) =>
      switch (rarity) {
        RewardRarity.legendary => _tileGradient(
          colors.rewardTileGoldDark,
          colors.rewardTileGoldMid,
          colors.rewardTileGoldLight,
        ),
        RewardRarity.epic => _purpleGradient(colors),
        RewardRarity.rare => _tileGradient(
          colors.rewardTileBlueDark,
          colors.rewardTileBlueMid,
          colors.rewardTileBlueLight,
        ),
        RewardRarity.common || null => _tileGradient(
          colors.rewardTileGrayDark,
          colors.rewardTileGrayMid,
          colors.rewardTileGrayLight,
        ),
      };
}

/// Плашка "Забрать" на нижнем крае карточки — единственный визуальный
/// признак того, что награду реально можно взять тапом; без неё плитка
/// (значок подарка/премиума сам по себе) некликабельна.
class _ClaimButton extends StatelessWidget {
  const _ClaimButton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    final claimGreenGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.claimGreenTop, colors.claimGreenBottom],
    );

    // Сам наклон вокруг общего с карточкой центра накладывает снаружи
    // RewardCarouselTile (см. footer в reward_carousel_tile.dart) — здесь
    // только компенсирующий встречный наклон, чтобы текст остался прямым.
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: claimGreenGradient,
        borderRadius: AppRadius.circular14,
      ),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.skewX(-kRewardTileSkewAngle),
        child: Text(
          AppStrings.claimButtonLabel,
          textAlign: TextAlign.center,
          style: theme.appTypography.mobileTypo.medium26.copyWith(
            color: colors.appColorWhite,
          ),
        ),
      ),
    );
  }
}

/// Ромб уровня + соединительная линия трека под плиткой. Каждый узел рисует
/// ТОЛЬКО отрезок ОТ своего ромба ДО следующего (а не половинки с обеих
/// сторон) — так фактическая доля прогресса (currentXp относительно порогов
/// requiredXp двух соседних уровней) кладётся на реальную геометрическую
/// длину между их центрами, а не на случайную часть её. Соседний узел слева
/// от своего ромба ничего не рисует — сегмент до него уже нарисован этим.
class _LevelTrackNode extends StatelessWidget {
  const _LevelTrackNode({
    required this.number,
    required this.requiredXp,
    required this.currentXp,
    required this.nextRequiredXp,
  });

  final int number;
  final int requiredXp;
  final int currentXp;

  /// Порог следующего уровня; `null` для последнего уровня трека — рисовать
  /// отрезок дальше некуда.
  final int? nextRequiredXp;

  /// Расстояние между центрами соседних ромбов: ширина плитки (242) плюс
  /// ширина разделителя-стрелки между ними (см. `_TrackSeparator`, ~12 —
  /// определяется её содержимым, явной ширины у неё нет).
  static const _diamondStride = 254.0;

  /// Ромб 34×34, повёрнутый на 45° — половина его диагонали (34·√2/2), т.е.
  /// на сколько его левый кончик выступает влево от центра; отрезок обрезан
  /// примерно на это расстояние до центра следующего ромба, иначе остаток
  /// (когда прогресс близок к 100%) прячется у него под иконкой.
  static const _diamondHalfSpan = 24.04;

  /// Толщина линии — половина её нужна отдельно: у ромба острый кончик
  /// (в точности на _diamondHalfSpan от центра его высота равна нулю), так
  /// что при стыковке линии ровно с кончиком по бокам виден треугольный
  /// зазор. Забираемся вглубь ромба ещё на половину толщины линии — там он
  /// уже достаточно "вырос" по высоте, чтобы полностью перекрыть линию.
  static const _lineThickness = 10.0;

  /// 45° — угол поворота ромба (и обратный поворот его содержимого).
  static const _diamondRotationAngle = 0.785398;

  /// Небольшой запас поверх точного расчёта ширины соединительной линии —
  /// иначе из-за сглаживания пикселей на стыке остаётся тонкий зазор.
  static const _lineWidthPadding = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const lineLeft = 121.0; // от центра этой плитки — ровно на ромбе

    final reached = currentXp >= requiredXp;
    final ownColor = reached
        ? colors.trackNodeReached
        : colors.trackNodeDefault;

    return SizedBox(
      width: AppSizes.horizontalSize242,
      height: AppSizes.verticalSize34,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (nextRequiredXp != null)
            Positioned(
              left: lineLeft,
              width:
                  _diamondStride -
                  _diamondHalfSpan +
                  _lineThickness / 2 +
                  _lineWidthPadding,
              child: Builder(
                builder: (context) {
                  final nextReached = currentXp >= nextRequiredXp!;
                  final outColor = nextReached
                      ? colors.trackNodeReached
                      : colors.trackNodeDefault;
                  // currentXp/nextRequiredXp — та же доля, что показана в
                  // XP-пилюле наверху экрана (см. battle_pass_screen.dart,
                  // xpToNextLevel = requiredXp текущего уровня), чтобы полоса
                  // читалась согласованно с тем числом.
                  final fraction = nextRequiredXp! > 0
                      ? (currentXp / nextRequiredXp!).clamp(0.0, 1.0)
                      : (reached ? 1.0 : 0.0);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ownColor, ownColor, outColor, outColor],
                        stops: [0, fraction, fraction, 1],
                      ),
                    ),
                    child: AppSizedBoxes.verticalSizedBoxH10,
                  );
                },
              ),
            ),
          Transform.rotate(
            angle: _diamondRotationAngle,
            child: Container(
              width: AppSizes.allSize34,
              height: AppSizes.allSize34,
              decoration: BoxDecoration(
                color: ownColor,
                borderRadius: AppRadius.circular6,
              ),
              child: Transform.rotate(
                angle: -_diamondRotationAngle,
                child: Center(
                  child: Padding(
                    // Трёхзначные уровни (100+) не помещаются в ромб на
                    // полный fontSize — сжимаем, а не обрезаем цифры.
                    padding: AppPadding.horizontalPadding3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$number',
                        style: theme.appTypography.mobileTypo.bold14.copyWith(
                          color: colors.appColorWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
