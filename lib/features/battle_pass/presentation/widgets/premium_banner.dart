import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

/// Карточка премиума в правом верхнем углу: апсейл (премиум не куплен) или
/// "Повысить уровень" (куплен).
class PremiumBanner extends StatelessWidget {
  const PremiumBanner({
    required this.premiumOwned,
    required this.onPressed,
    this.maxLevelReached = false,
    super.key,
  });

  final bool premiumOwned;
  final VoidCallback onPressed;

  /// Уровень максимальный: вместо кнопки — неактивная плашка.
  final bool maxLevelReached;

  static const double width = 605;
  static const double height = 690;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const bannerRight = 24.0;
    const bannerTop = 0.0;
    const artLeftUnlocked = -50.0;
    const artLeftLocked = 20.0;
    const artTopUnlocked = -278.0;
    const artTopLocked = -169.0;
    const contentLeft = 32.0;
    const contentRight = 32.0;
    const contentBottom = 40.0;
    const upgradeButtonIconHeight = 32.0;

    return Positioned(
      right: bannerRight,
      top: bannerTop,
      width: width,
      height: height,
      child: ClipRect(
        child: Stack(
          children: [
            // Иллюстрация больше карточки и обрезается её краями (по Figma).
            Positioned(
              left: premiumOwned ? artLeftUnlocked : artLeftLocked,
              top: premiumOwned ? artTopUnlocked : artTopLocked,
              width: 668,
              height: 1304,
              child: Image.asset(
                premiumOwned
                    ? AppAssets.imagePremiumBannerUnlockedArt
                    : AppAssets.imagePremiumBannerLockedArt,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: contentLeft,
              right: contentRight,
              bottom: contentBottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    premiumOwned
                        ? AppStrings.premiumBannerTitleLevelUp
                        : AppStrings.premiumBannerTitleUnlock,
                    textAlign: TextAlign.center,
                    style: theme.appTypography.mobileTypo.h4.copyWith(
                      color: colors.accentGold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: Text(
                      premiumOwned
                          ? AppStrings.premiumBannerSubtitleLevelUp
                          : AppStrings.premiumBannerSubtitleUnlock,
                      textAlign: TextAlign.center,
                      style: theme.appTypography.mobileTypo.p1Med.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  premiumOwned
                      // По ширине содержимого, прижата к левому краю.
                      ? Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32, top: 53),
                            child: maxLevelReached
                                ? const _MaxLevelReachedNotice()
                                : _UpgradeButton(
                                    label: AppStrings.increaseLevelButton,
                                    icon: AppAssets.iconArrowUp,
                                    iconHeight: upgradeButtonIconHeight,
                                    onPressed: onPressed,
                                  ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                            left: 125,
                            top: 27,
                            right: 80,
                          ),
                          child: _UpgradeButton(
                            label: AppStrings.unlockPremiumButton,
                            onPressed: onPressed,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Неактивная плашка вместо "Повысить уровень" на максимальном уровне.
class _MaxLevelReachedNotice extends StatelessWidget {
  const _MaxLevelReachedNotice();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    return Container(
      width: 400,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: colors.buttonOverlayStrong, // #E9E9F3 @ 0.1
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Text(
        AppStrings.maxLevelReachedNotice,
        textAlign: TextAlign.center,
        style: theme.appTypography.mobileTypo.p1Med.copyWith(
          color: colors.progressRingFill, // = textMuted
        ),
      ),
    );
  }
}

/// Золотая кнопка с глянцевым бликом (Rectangle 64755, blend "overlay").
class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({
    required this.label,
    required this.onPressed,
    this.icon = AppAssets.iconPremiumIcon,
    this.iconHeight = 20,
  });

  final String label;
  final VoidCallback onPressed;
  final String icon;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const glowBlurRadius = 40.0;
    const glowSpreadRadius = 4.0;

    final itemTagGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.itemTagGradientTop, colors.itemTagGradientBottom],
    );
    // Глянцевый блик поверх золотой кнопки (Rectangle 64755, blend "overlay").
    final buttonShineGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      colors: [
        colors.buttonShineStart,
        colors.buttonShineSoft,
        colors.buttonShineCore,
        colors.buttonShineFade,
        colors.buttonShineEnd,
      ],
    );

    return Container(
      height: 100,
      width: 400,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: colors.glowShadow,
            blurRadius: glowBlurRadius,
            spreadRadius: glowSpreadRadius,
          ),
        ],
      ),
      child: Material(
        color: colors.appColorTransparent,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(gradient: itemTagGradient),
          child: InkWell(
            onTap: onPressed,
            child: Ink(
              decoration: BoxDecoration(
                gradient: buttonShineGradient,
                backgroundBlendMode: BlendMode.overlay,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 32),
                  SvgPicture.asset(icon, width: 27, height: iconHeight),
                  const SizedBox(width: 27),
                  Text(
                    label,
                    style: theme.appTypography.mobileTypo.medium30.copyWith(
                      color: colors.itemTagText,
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
