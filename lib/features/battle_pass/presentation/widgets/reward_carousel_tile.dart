import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

/// Общий наклон (shear) для всех "боевых" элементов трека — плитки,
/// значок награды, чип количества, рамка кнопки, стрелка. Иконки/текст
/// внутри остаются прямыми — это отдельный неповёрнутый слой поверх.
const double kRewardTileSkewAngle = -0.12;

/// Фоновая подложка, наклонённая через shear-transform — контент поверх неё
/// (иконки, текст) кладётся отдельным неповёрнутым слоем, а не внутрь этого
/// виджета, чтобы не наклонять его вместе с фоном.
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

/// Какой значок сидит в углу плитки: премиум-корона (награда доступна
/// только с прокачкой) или обычный подарок (награда бесплатная).
enum RewardBadgeKind { premium, gift }

/// Значок "BP_Reward_Sticker" — наклонный квадрат 55×50 с иконкой внутри
/// (см. Figma-скрин с замером). Наклон общий (тот же shear, что у плиток),
/// иконку поворачиваем вместе с фоном — на референсе видно, что весь бейдж
/// читается как единая наклонная деталь.
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

/// Плитка одной награды трека — переиспользуется и тизером премиума
/// (`PremiumTeaserCluster`), и обычными уровнями (`RewardTile`): везде одна
/// и та же наклонная карточка с картинкой, бейджем и чипом количества.
class RewardCarouselTile extends StatelessWidget {
  const RewardCarouselTile({
    required this.asset,
    required this.gradient,
    this.badge = RewardBadgeKind.gift,
    this.showBadge = true,
    this.quantityLabel,
    this.borderColor,
    this.showGlow = false,
    this.glowColor,
    this.glowBlurRadius = 24,
    this.glowSpreadRadius = 2,
    this.claimed = false,
    this.locked = false,
    this.borderIgnoresOpacity = false,
    this.onTap,
    this.footer,
    this.width = defaultWidth,
    this.height = 240,
    super.key,
  });

  static const double defaultWidth = 242;

  final String asset;
  final Gradient gradient;
  final RewardBadgeKind badge;

  /// Награда уже забрана — значок подарка/премиума в углу уже не значит
  /// ничего (см. превью юбилейного уровня в rewards_track.dart).
  final bool showBadge;

  final String? quantityLabel;
  final Color? borderColor;

  /// "Backlight_BP_Card" — мягкое свечение вокруг рамки. Только для
  /// выбранной для клейма плитки или превью юбилейного уровня; у
  /// премиум-тизера рамка тоже есть (белая, для подсветки выбора), но
  /// свечения к ней не полагается.
  final bool showGlow;

  /// Цвет свечения — по умолчанию совпадает с рамкой, но может отличаться
  /// (см. превью юбилейного уровня: рамка #DA7128, а свечение #E23600).
  final Color? glowColor;
  final double glowBlurRadius;
  final double glowSpreadRadius;

  final bool claimed;
  final bool locked;

  /// Рамка рисуется отдельным, полностью непрозрачным слоем поверх
  /// притушенной (claimed/locked) карточки, а не тускнеет вместе с ней —
  /// см. превью юбилейного уровня в rewards_track.dart.
  final bool borderIgnoresOpacity;

  final VoidCallback? onTap;

  /// Плашка "Забрать" на нижнем крае карточки — рисуется только когда
  /// награду реально можно взять. Чисто декоративная (`IgnorePointer`):
  /// тап по ней должен попадать на тот же `InkWell`, что и по всей карточке,
  /// а не перехватываться отдельно.
  final Widget? footer;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const cardWidthInset = 42.0;
    const cardHeightInset = 56.0;
    const cardInsetLeft = 21.0;
    const cardInsetTop = 28.0;
    const claimedOpacity = 0.5;
    const fullOpacity = 1.0;
    const borderWidth = 4.0;
    const glowAlphaFallback = 0.6;
    const imageInsetLeft = 45.0;
    const imageInsetTop = 44.0;
    const imageWidthInset = 48.0;
    const imageHeightInset = 32.0;
    const badgeLeft = 40.0;
    const badgeTop = 40.0;
    const quantityChipRight = 34.0;
    const quantityChipGapAboveFooter = 7.0;
    const quantityChipBottomInset = 44.0;
    const animationDuration = Duration(milliseconds: 220);
    const footerScaleHidden = 0.85;
    const footerScaleVisible = 1.0;
    const footerOpacityHidden = 0.0;
    const footerOpacityVisible = 1.0;
    const glowScale = 1.12;
    const normalScale = 1.0;
    const claimedBadgeRight = 24.0;
    const claimedBadgeTop = 44.0;

    final cardWidth = width - cardWidthInset;
    final cardHeight = height - cardHeightInset;
    const footerMargin = 8.0;
    const footerHeight = 48.0;
    final footerTop = cardInsetTop + cardHeight - footerMargin - footerHeight;
    const quantityChipHeight = 36.0;
    // Когда снизу есть плашка "Забрать", чип количества не может стоять на
    // своём обычном месте (у нижнего края карточки) — она его перекрывает.
    // Сдвигаем чип строго над плашкой с отступом 7px, а без плашки
    // оставляем прежнее место у низа карточки.
    final quantityChipTop = footer != null
        ? footerTop - quantityChipGapAboveFooter - quantityChipHeight
        : height - quantityChipBottomInset - quantityChipHeight;
    final content = Opacity(
      opacity: claimed ? claimedOpacity : fullOpacity,
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
                  // Рамка и подсветка появляются по тапу (выбор для клейма) —
                  // AnimatedContainer вместо обычного, чтобы они плавно
                  // проступали, а не выскакивали внезапно (раньше из-за
                  // мгновенного boxShadow плитка визуально "выпрыгивала").
                  child: AnimatedContainer(
                    duration: animationDuration,
                    curve: Curves.easeOut,
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: AppRadius.circular24,
                      border: borderColor != null && !borderIgnoresOpacity
                          ? Border.all(color: borderColor!, width: borderWidth)
                          : null,
                      // "Backlight_BP_Card" из Figma — мягкое свечение вокруг
                      // выбранной для получения плитки, того же цвета, что
                      // рамка.
                      boxShadow: showGlow && (glowColor ?? borderColor) != null
                          ? [
                              BoxShadow(
                                // Явно заданный glowColor (см. превью
                                // юбилейного уровня) берётся как есть — по
                                // умолчанию же (обычный клейм) свечение
                                // мягче самой рамки, поэтому притушено.
                                color:
                                    glowColor ??
                                    borderColor!.withValues(
                                      alpha: glowAlphaFallback,
                                    ),
                                blurRadius: glowBlurRadius,
                                spreadRadius: glowSpreadRadius,
                              ),
                            ]
                          : null,
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
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
          if (showBadge)
            Positioned(
              left: badgeLeft,
              top: badgeTop,
              child: IgnorePointer(child: RewardBadge(kind: badge)),
            ),
          if (quantityLabel != null)
            Positioned(
              right: quantityChipRight,
              top: quantityChipTop,
              child: IgnorePointer(
                child: SizedBox(
                  width: AppSizes.horizontalSize69,
                  height: AppSizes.verticalSize36,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SkewedBox(
                        width: AppSizes.horizontalSize69,
                        height: AppSizes.verticalSize36,
                        decoration: BoxDecoration(
                          color: colors.quantityChipBg,
                          borderRadius: AppRadius.circular8,
                        ),
                      ),
                      Text(
                        quantityLabel!,
                        style: theme.appTypography.mobileTypo.semibold26
                            .copyWith(color: colors.appColorWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Builder(
            builder: (context) {
              // Наклоняем плашку footer вокруг того же центра, что и сама
              // карточка (28 + cardHeight/2), а не вокруг своего — иначе
              // при независимом наклоне вокруг собственного (более
              // высокого, раз плашка ниже и у́же карточки) центра сдвиг
              // получается меньше, чем у карточки на той же высоте, и
              // плашка вылезает за скошенный край.
              final origin = Offset(
                0,
                cardInsetTop + cardHeight / 2 - footerTop,
              );
              final visible = footer != null;
              return Positioned(
                left: cardInsetLeft + footerMargin,
                width: cardWidth - footerMargin * 2,
                top: footerTop,
                height: footerHeight,
                child: IgnorePointer(
                  child: Transform(
                    origin: origin,
                    transform: Matrix4.skewX(kRewardTileSkewAngle),
                    // Плашка не выскакивает мгновенно, а плавно проступает
                    // и подрастает вместе с рамкой/подсветкой карточки —
                    // держим её виджет в дереве и просто гасим/масштабируем,
                    // а не добавляем/убираем условно (иначе анимировать
                    // нечего, виджет появляется/исчезает мгновенно).
                    child: AnimatedScale(
                      duration: animationDuration,
                      curve: Curves.easeOut,
                      scale: visible ? footerScaleVisible : footerScaleHidden,
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        duration: animationDuration,
                        opacity: visible
                            ? footerOpacityVisible
                            : footerOpacityHidden,
                        child: footer ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
    // Выбранная для клейма плитка визуально подрастает целиком (картинка,
    // бейдж, рамка — всё вместе), а не только рамка/подсветка сами по себе:
    // Transform.scale не меняет раскладку соседей, поэтому нарочно перекрывает
    // их — так и задумано (см. референс из Figma).
    return AnimatedScale(
      duration: animationDuration,
      curve: Curves.easeOut,
      scale: showGlow ? glowScale : normalScale,
      child: SizedBox(
        width: width,
        height: height,
        child: claimed
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  content,
                  if (borderColor != null && borderIgnoresOpacity)
                    Positioned(
                      left: cardInsetLeft,
                      top: cardInsetTop,
                      width: cardWidth,
                      height: cardHeight,
                      child: IgnorePointer(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.skewX(kRewardTileSkewAngle),
                          child: Container(
                            width: cardWidth,
                            height: cardHeight,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor!,
                                width: borderWidth,
                              ),
                              borderRadius: AppRadius.circular24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Positioned(
                    right: claimedBadgeRight,
                    top: claimedBadgeTop,
                    child: IgnorePointer(child: _ClaimedBadge()),
                  ),
                ],
              )
            : content,
      ),
    );
  }
}

/// Зелёная галочка "уже забрано" — верхний правый угол, без своей подложки
/// (см. предоставленный done.svg): поверх наполовину прозрачной плитки.
class _ClaimedBadge extends StatelessWidget {
  const _ClaimedBadge();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconDone,
      width: AppSizes.horizontalSize48,
      height: AppSizes.verticalSize26,
    );
  }
}
