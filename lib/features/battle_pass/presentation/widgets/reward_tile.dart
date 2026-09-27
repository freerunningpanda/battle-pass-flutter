import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Плитка уровня трека с ромбом и линией прогресса до следующего уровня.
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

  /// Порог следующего уровня — линия прогресса красится по реальному опыту.
  /// `null` у последнего уровня: линии дальше нет.
  final int? nextRequiredXp;

  final int currentXp;

  final VoidCallback onClaim;
  final VoidCallback onUnlockPremium;

  @override
  State<RewardTile> createState() => _RewardTileState();
}

class _RewardTileState extends State<RewardTile> {
  /// Доступная награда забирается в два тапа: первый выделяет плитку и
  /// показывает "Забрать", второй забирает.
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
    final claimable = level.state == LevelState.claimable;
    final showPremiumBadge = _hasPremiumUpgrade;
    // Плитка с премиум-апгрейдом ведёт к покупке, а не к получению.
    final showClaimUi = claimable && _selected && !showPremiumBadge;

    final tile = RewardCarouselTile(
      asset: reward?.iconAsset ?? _placeholderAsset,
      // Фиолетовый — общий для экрана цвет "тут премиум".
      gradient: widget.gold
          ? _rarityGradient(colors, RewardRarity.legendary)
          : showPremiumBadge
          ? _purpleGradient(colors)
          : _rarityGradient(colors, reward?.rarity),
      badge: showPremiumBadge && !widget.hidePremiumBadge
          ? RewardBadgeKind.premium
          : (widget.highlighted || !widget.hideGiftBadge)
          ? RewardBadgeKind.gift
          : null,
      quantityLabel: (reward != null && reward.amount > 1)
          ? '×${reward.amount}'
          : null,
      highlight: showClaimUi
          ? TileHighlight(
              colors.claimReadyBorder,
              glow: TileGlow(
                color: colors.claimReadyBorder.withValues(alpha: 0.6),
              ),
            )
          : widget.highlighted
          ? TileHighlight(colors.textPrimary)
          : null,
      claimed: level.state == LevelState.claimed,
      onTap: _onTap,
      footer: showClaimUi ? const _ClaimButton() : null,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        const SizedBox(height: 12),
        _LevelTrackNode(
          number: level.number,
          requiredXp: level.requiredXp,
          currentXp: widget.currentXp,
          nextRequiredXp: widget.nextRequiredXp,
        ),
      ],
    );
  }

  bool get _hasPremiumUpgrade {
    final premium = widget.level.premiumReward;
    return premium != null && !premium.claimed && !widget.premiumOwned;
  }

  void _onTap() {
    final level = widget.level;
    switch (level.state) {
      case LevelState.locked:
        _showHint(
          '${AppStrings.levelLockedHintPrefix}${level.number}'
          '${AppStrings.levelLockedHintSuffix}',
        );
      // Текущий уровень ещё не пройден — подсказываем, сколько опыта не
      // хватает, даже если на нём есть премиум-апгрейд.
      case LevelState.current:
        _showHint(
          '${AppStrings.levelMissingXpHintPrefix}'
          '${level.requiredXp - widget.currentXp}'
          '${AppStrings.levelMissingXpHintSuffix}',
        );
      case _ when _hasPremiumUpgrade:
        widget.onUnlockPremium();
      case LevelState.claimable when _selected:
        widget.onClaim();
      case LevelState.claimable:
        setState(() => _selected = true);
      case LevelState.claimed:
        _showHint(AppStrings.rewardAlreadyClaimedHint);
    }
  }

  void _showHint(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

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

/// Плашка "Забрать" на нижнем крае выбранной плитки.
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

    // Плашку наклоняет RewardCarouselTile; здесь — встречный наклон, чтобы
    // текст остался прямым.
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: claimGreenGradient,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
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

/// Ромб уровня и линия прогресса от него до ромба следующего уровня —
/// целиком, а не половинками с двух сторон, чтобы доля опыта ложилась на
/// всё расстояние между уровнями.
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

  final int? nextRequiredXp;

  /// Линия заходит под ромб следующего уровня на половину своей толщины —
  /// у острого кончика ромба иначе виден треугольный зазор; плюс запас на
  /// сглаживание пикселей на стыке.
  static const _lineWidth =
      TrackGeometry.levelExtent -
      TrackGeometry.diamondHalfSpan +
      TrackGeometry.lineThickness / 2 +
      2;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    // Линия начинается от центра своего ромба.
    const lineLeft = TrackGeometry.tileWidth / 2;

    Color colorFor(int xp) =>
        currentXp >= xp ? colors.trackNodeReached : colors.trackNodeDefault;
    final ownColor = colorFor(requiredXp);
    final next = nextRequiredXp;

    return SizedBox(
      width: TrackGeometry.tileWidth,
      height: TrackGeometry.diamondSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (next != null)
            Positioned(
              left: lineLeft,
              width: _lineWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // Та же доля, что в XP-индикаторе вверху экрана.
                  gradient: _progressGradient(
                    ownColor,
                    colorFor(next),
                    next > 0 ? (currentXp / next).clamp(0.0, 1.0) : 1.0,
                  ),
                ),
                child: const SizedBox(height: TrackGeometry.lineThickness),
              ),
            ),
          LevelDiamond(number: number, color: ownColor),
        ],
      ),
    );
  }

  static Gradient _progressGradient(Color from, Color to, double fraction) =>
      LinearGradient(
        colors: [from, from, to, to],
        stops: [0, fraction, fraction, 1],
      );
}
