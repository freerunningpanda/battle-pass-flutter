import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Три премиум-награды в начале трека и плашка "Получи все сразу!", которая
/// ведёт к покупке премиума. Награды можно выделять по одной.
class PremiumTeaserCluster extends StatefulWidget {
  const PremiumTeaserCluster({
    required this.onUnlock,
    this.hidePremiumBadge = false,
    super.key,
  });

  final VoidCallback onUnlock;

  /// Корона не показывается ни у одной из 3 наград блока.
  final bool hidePremiumBadge;

  static const double width = 676;

  @override
  State<PremiumTeaserCluster> createState() => _PremiumTeaserClusterState();
}

class _PremiumTeaserClusterState extends State<PremiumTeaserCluster> {
  static const _assets = [
    AppAssets.imagePremiumTeaserBag,
    AppAssets.imagePremiumTeaserBracelet,
    AppAssets.imagePremiumTeaserFuel,
  ];
  static const _quantityLabels = [null, AppStrings.quantityLabelX2, null];

  static const _defaultSelectedIndex = 2;
  int _selectedIndex = _defaultSelectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;

    const tileStride = 216.0;
    const stickerLeft = 6.0;
    const stickerTop = 236.0;

    // Градиенты по редкости: common, rare, epic.
    final gradients = [
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.rewardTileGrayDark,
          colors.rewardTileGrayMid,
          colors.rewardTileGrayLight,
        ],
      ),
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.rewardTileBlueDark,
          colors.rewardTileBlueMid,
          colors.rewardTileBlueLight,
        ],
      ),
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.rewardTilePurpleDark,
          colors.rewardTilePurpleMid,
          colors.rewardTilePurpleLight,
        ],
      ),
    ];

    return SizedBox(
      width: PremiumTeaserCluster.width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < _assets.length; i++)
            Positioned(
              left: i * tileStride,
              child: RewardCarouselTile(
                asset: _assets[i],
                quantityLabel: _quantityLabels[i],
                gradient: gradients[i],
                badge: widget.hidePremiumBadge ? null : RewardBadgeKind.premium,
                highlight: _selectedIndex == i
                    ? TileHighlight(colors.textPrimary)
                    : null,
                onTap: () => setState(() => _selectedIndex = i),
              ),
            ),
          Positioned(
            left: stickerLeft,
            top: stickerTop,
            width: 626,
            child: _UnlockSticker(onTap: widget.onUnlock),
          ),
        ],
      ),
    );
  }
}

class _UnlockSticker extends StatelessWidget {
  const _UnlockSticker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const textShadowBlurRadius = 14.4;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SkewedBox(
                width: 626,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.unlockStickerBg,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
              ),
              Text(
                AppStrings.premiumTeaserUnlockAll,
                textAlign: TextAlign.center,
                style: theme.appTypography.mobileTypo.medium30Tight.copyWith(
                  color: colors.accentGold,
                  shadows: [
                    Shadow(
                      color: colors.unlockStickerTextShadow,
                      blurRadius: textShadowBlurRadius,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
