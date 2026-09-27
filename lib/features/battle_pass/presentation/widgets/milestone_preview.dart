import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Увеличенная карточка ближайшего юбилейного уровня (10, 20…) у правого
/// края трека — видна, пока сам уровень не доскроллен до центра.
class MilestonePreview extends StatelessWidget {
  const MilestonePreview({
    required this.level,
    required this.onTap,
    this.style = MilestonePreviewStyle.regular,
    super.key,
  });

  final BattlePassLevel level;
  final VoidCallback onTap;

  final MilestonePreviewStyle style;

  static const double cardSize = 268;
  static const double _spacer = 12;

  /// Отступ от низа трека — ромб превью встаёт вровень с ромбами уровней.
  static const double bottomMargin = 14;

  /// Центр карточки по вертикали в координатах трека высотой [trackHeight]:
  /// карточка растёт вверх от нижнего края, стрелки целятся в её центр.
  static double cardCenterY(double trackHeight) =>
      trackHeight -
      bottomMargin -
      TrackGeometry.diamondSize -
      _spacer -
      cardSize / 2;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const previewGlowBlurRadius = 45.1;
    const previewGlowSpreadRadius = 0.0;

    final cardGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.rewardTileGrayDark, colors.milestonePreviewAccent],
    );

    final reward = level.freeReward;
    // Забранный уровень выглядит как обычная полученная плитка: без короны
    // и свечения, с белой рамкой.
    final claimed = level.state == LevelState.claimed;
    final showCrown = switch (style) {
      MilestonePreviewStyle.regular || MilestonePreviewStyle.maxLevel => true,
      MilestonePreviewStyle.noCrown || MilestonePreviewStyle.plain => false,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RewardCarouselTile(
          asset: reward?.iconAsset ?? '',
          gradient: cardGradient,
          badge: !claimed && showCrown ? RewardBadgeKind.premium : null,
          highlight: TileHighlight(
            (claimed || style == MilestonePreviewStyle.plain)
                ? colors.textPrimary
                : colors.milestonePreviewAccent,
            glow: claimed
                ? null
                : TileGlow(
                    color: colors.milestonePreviewGlow,
                    blurRadius: previewGlowBlurRadius,
                    spreadRadius: previewGlowSpreadRadius,
                  ),
          ),
          claimed: claimed,
          onTap: onTap,
          width: cardSize,
          height: cardSize,
        ),
        const SizedBox(height: _spacer),
        LevelDiamond(
          number: level.number,
          color: style == MilestonePreviewStyle.maxLevel
              ? colors.milestoneDiamondMaxLevel
              : colors.trackNodeDefault,
        ),
      ],
    );
  }
}
