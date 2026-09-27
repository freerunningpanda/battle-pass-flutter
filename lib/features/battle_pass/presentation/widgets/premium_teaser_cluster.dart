import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Блок из 3 премиум-наград в начале трека (узел "Frame 1539", id 1:1275) +
/// плашка "Получи все сразу!" (Premium_Awards_Stiker, id 1:1297) под ним.
/// Награды этого блока взять нельзя напрямую — плашка "продаёт" премиум:
/// тап переключает сценарий на "премиум куплен" (см. README про мок-покупку),
/// после чего блок пропадает — он не имеет смысла, когда премиум уже куплен.
/// Сами иконки кликабельны — можно выбрать (подсветить), какая из наград
/// интересна, ровно один элемент одновременно.
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

    // Фоновые градиенты плиток тизера — по редкости: common / rare / epic
    // (тот же порядок, что и у RewardTile, см. AppColors.rewardTile*Gradient
    // до перехода на тему).
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
                badge: RewardBadgeKind.premium,
                showBadge: !widget.hidePremiumBadge,
                borderColor: _selectedIndex == i ? colors.textPrimary : null,
                onTap: () => setState(() => _selectedIndex = i),
              ),
            ),
          Positioned(
            left: stickerLeft,
            top: stickerTop,
            width: AppSizes.horizontalSize626,
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
          height: AppSizes.verticalSize60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SkewedBox(
                width: AppSizes.horizontalSize626,
                height: AppSizes.verticalSize60,
                decoration: BoxDecoration(
                  color: colors.unlockStickerBg,
                  borderRadius: AppRadius.circular20,
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
