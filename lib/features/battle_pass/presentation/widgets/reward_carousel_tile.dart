import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

/// Общий наклон элементов трека. Иконки и текст поверх остаются прямыми.
const double kRewardTileSkewAngle = -0.12;

/// Наклонённая подложка; контент кладётся поверх отдельным слоем.
class SkewedBox extends StatelessWidget {
  const SkewedBox({
    required this.width,
    required this.height,
    required this.decoration,
    super.key,
  });

  final double width;
  final double height;
  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(kRewardTileSkewAngle),
      child: Container(width: width, height: height, decoration: decoration),
    );
  }
}

/// Значок в углу плитки: корона (нужен премиум) или подарок.
enum RewardBadgeKind { premium, gift }

class RewardBadge extends StatelessWidget {
  const RewardBadge({this.kind = RewardBadgeKind.gift, super.key});

  final RewardBadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final premium = kind == RewardBadgeKind.premium;
    return SvgPicture.asset(
      premium
          ? AppAssets.iconRewardBadgePremium
          : AppAssets.iconRewardBadgeGift,
    );
  }
}

/// Свечение вокруг рамки плитки ("Backlight_BP_Card" из Figma).
class TileGlow {
  const TileGlow({
    required this.color,
    this.blurRadius = 24,
    this.spreadRadius = 2,
  });

  final Color color;
  final double blurRadius;
  final double spreadRadius;
}

/// Рамка плитки и, если задано, свечение. Плитка со свечением ещё и
/// подрастает целиком.
class TileHighlight {
  const TileHighlight(this.color, {this.glow});

  final Color color;
  final TileGlow? glow;
}

/// Плитка одной награды трека — общая для премиум-тизера, обычных уровней
/// и превью юбилейного уровня: наклонная карточка с картинкой, бейджем и
/// чипом количества.
class RewardCarouselTile extends StatelessWidget {
  const RewardCarouselTile({
    required this.asset,
    required this.gradient,
    this.badge,
    this.quantityLabel,
    this.highlight,
    this.claimed = false,
    this.onTap,
    this.footer,
    this.width = defaultWidth,
    this.height = 240,
    super.key,
  });

  static const double defaultWidth = 242;

  final String asset;
  final Gradient gradient;

  /// Значок в углу; `null` — без значка.
  final RewardBadgeKind? badge;

  final String? quantityLabel;
  final TileHighlight? highlight;

  /// Награда получена: карточка притушена (рамка — нет), в углу галочка.
  final bool claimed;

  final VoidCallback? onTap;

  /// Плашка на нижнем крае карточки (например, "Забрать"). Декоративная —
  /// тап по ней идёт в тот же `InkWell`, что и по всей карточке.
  final Widget? footer;

  final double width;
  final double height;

  static const _claimedOpacity = 0.5;
  static const _claimedImageOpacity = AlwaysStoppedAnimation(_claimedOpacity);
  static const _animationDuration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const cardWidthInset = 42.0;
    const cardHeightInset = 56.0;
    const cardInsetLeft = 21.0;
    const cardInsetTop = 28.0;
    const borderWidth = 4.0;
    const imageInsetLeft = 45.0;
    const imageInsetTop = 44.0;
    const imageWidthInset = 48.0;
    const imageHeightInset = 32.0;
    const badgeLeft = 40.0;
    const badgeTop = 40.0;
    const quantityChipRight = 34.0;
    const quantityChipGapAboveFooter = 7.0;
    const quantityChipBottomInset = 44.0;
    const quantityChipHeight = 36.0;
    const footerMargin = 8.0;
    const footerHeight = 48.0;
    const footerHiddenScale = 0.85;
    const glowScale = 1.12;
    const claimedBadgeRight = 24.0;
    const claimedBadgeTop = 44.0;

    final cardWidth = width - cardWidthInset;
    final cardHeight = height - cardHeightInset;
    final footerTop = cardInsetTop + cardHeight - footerMargin - footerHeight;
    // С плашкой снизу чип количества поднимается над ней.
    final quantityChipTop = footer != null
        ? footerTop - quantityChipGapAboveFooter - quantityChipHeight
        : height - quantityChipBottomInset - quantityChipHeight;

    // Притушенность полученной плитки заложена в цвета и картинку, а не
    // слоем Opacity на всю плитку — в скролле это отдельный слой на каждую.
    final opacity = claimed ? _claimedOpacity : 1.0;
    final glow = highlight?.glow;

    return AnimatedScale(
      duration: _animationDuration,
      curve: Curves.easeOut,
      scale: glow != null ? glowScale : 1,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: cardInsetLeft,
              top: cardInsetTop,
              width: cardWidth,
              height: cardHeight,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.skewX(kRewardTileSkewAngle),
                    child: AnimatedContainer(
                      duration: _animationDuration,
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        gradient: claimed
                            ? gradient.withOpacity(_claimedOpacity)
                            : gradient,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
                        border: highlight == null
                            ? null
                            : Border.all(
                                color: highlight!.color,
                                width: borderWidth,
                              ),
                        boxShadow: glow == null
                            ? null
                            : [
                                BoxShadow(
                                  color: glow.color,
                                  blurRadius: glow.blurRadius,
                                  spreadRadius: glow.spreadRadius,
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: imageInsetLeft,
              top: imageInsetTop,
              width: cardWidth - imageWidthInset,
              height: cardHeight - imageHeightInset,
              child: IgnorePointer(
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  opacity: claimed ? _claimedImageOpacity : null,
                ),
              ),
            ),
            if (badge case final badge?)
              Positioned(
                left: badgeLeft,
                top: badgeTop,
                child: IgnorePointer(
                  // Маленький значок — слой Opacity здесь дешёвый.
                  child: Opacity(
                    opacity: opacity,
                    child: RewardBadge(kind: badge),
                  ),
                ),
              ),
            if (quantityLabel case final label?)
              Positioned(
                right: quantityChipRight,
                top: quantityChipTop,
                child: IgnorePointer(
                  child: SizedBox(
                    width: 69,
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SkewedBox(
                          width: 69,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colors.quantityChipBg.withValues(
                              alpha: colors.quantityChipBg.a * opacity,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                        ),
                        Text(
                          label,
                          style: theme.appTypography.mobileTypo.semibold26
                              .copyWith(
                                color: colors.appColorWhite.withValues(
                                  alpha: opacity,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: cardInsetLeft + footerMargin,
              width: cardWidth - footerMargin * 2,
              top: footerTop,
              height: footerHeight,
              child: IgnorePointer(
                child: Transform(
                  // Наклон вокруг центра карточки, а не своего — иначе
                  // плашка вылезает за скошенный край карточки.
                  origin: Offset(0, cardInsetTop + cardHeight / 2 - footerTop),
                  transform: Matrix4.skewX(kRewardTileSkewAngle),
                  // Плашка всегда в дереве, чтобы появление анимировалось.
                  child: AnimatedScale(
                    duration: _animationDuration,
                    curve: Curves.easeOut,
                    scale: footer != null ? 1 : footerHiddenScale,
                    child: AnimatedOpacity(
                      duration: _animationDuration,
                      opacity: footer != null ? 1 : 0,
                      child: footer ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
            if (claimed)
              const Positioned(
                right: claimedBadgeRight,
                top: claimedBadgeTop,
                child: IgnorePointer(child: _ClaimedBadge()),
              ),
          ],
        ),
      ),
    );
  }
}

/// Галочка "получено" в правом верхнем углу.
class _ClaimedBadge extends StatelessWidget {
  const _ClaimedBadge();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(AppAssets.iconDone, width: 48, height: 26);
  }
}
