import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Карточка "следующий сезон" в конце трека — колонка той же высоты, что и
/// плитка уровня, со своим продолжением линии прогресса.
class NextSeasonTeaser extends StatelessWidget {
  const NextSeasonTeaser({
    required this.maxLevel,
    this.requiresPremium = false,
    super.key,
  });

  final int maxLevel;

  /// Текст "нужна прокачка" вместо "откроются после уровня N".
  final bool requiresPremium;

  /// Отступ по краям: слева — как у карточки плитки уровня, справа — запас
  /// под наклон рамки (Transform не резервирует под него место в раскладке).
  static const double horizontalPadding = 21;

  /// Номер последнего ромба в конце пунктира (по Figma).
  static const _nextSeasonLevel = 120;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TeaserCard(maxLevel: maxLevel, requiresPremium: requiresPremium),
          const SizedBox(height: 12),
          _TeaserTrackRow(
            nextLevel: maxLevel + 1,
            finalLevel: _nextSeasonLevel,
          ),
        ],
      ),
    );
  }
}

class _TeaserCard extends StatelessWidget {
  const _TeaserCard({required this.maxLevel, this.requiresPremium = false});

  final int maxLevel;
  final bool requiresPremium;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    // Рамка того же размера и наклона, что карточка плитки уровня; текст
    // наклонён обратно, чтобы остаться прямым.
    const borderWidth = 1.5;

    return SizedBox(
      height: 240.0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(kRewardTileSkewAngle),
            child: Container(
              width: 439.0,
              height: 184.0,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.progressRingFill,
                  width: borderWidth,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(24)),
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.skewX(-kRewardTileSkewAngle),
                child: Text.rich(
                  TextSpan(
                    style: theme.appTypography.mobileTypo.medium26Tall.copyWith(
                      color: colors.progressRingFill, // = textMuted
                    ),
                    children: requiresPremium
                        ? [
                            TextSpan(
                              text:
                                  '${AppStrings.seasonEndTeaserRewardsPrefix}'
                                  '$maxLevel'
                                  '${AppStrings.seasonEndTeaserRewardsSuffix}',
                            ),
                            const TextSpan(
                              text: AppStrings
                                  .seasonEndTeaserRequiresPremiumMiddle,
                            ),
                            TextSpan(
                              text: AppStrings
                                  .seasonEndTeaserRequiresPremiumSuffix,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ]
                        : [
                            const TextSpan(
                              text: AppStrings.seasonEndTeaserUnlockPrefix,
                            ),
                            TextSpan(
                              text:
                                  '$maxLevel'
                                  '${AppStrings.seasonEndTeaserUnlockLevelSuffix}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Продолжение линии прогресса за последним уровнем: линия к `nextLevel`,
/// пунктир вместо промежуточных уровней и финальный ромб `finalLevel`.
class _TeaserTrackRow extends StatelessWidget {
  const _TeaserTrackRow({required this.nextLevel, required this.finalLevel});

  final int nextLevel;
  final int finalLevel;

  static const _dashWidths = [20.0, 32.0, 32.0, 32.0, 20.0];
  static const _dashGap = 10.0;
  static const _dashRowWidth = 20.0 * 2 + 32.0 * 3 + _dashGap * 4;

  static const _lineThickness = TrackGeometry.lineThickness;

  /// От левого края виджета до видимого края ромба последнего уровня: линию
  /// к нему этот виджет дорисовывает сам (у последнего уровня исходящей
  /// линии нет). +6 — скругление углов ромба срезает его кончик.
  static const _backReach =
      TrackGeometry.tileWidth / 2 -
      TrackGeometry.diamondHalfSpan +
      TrackGeometry.separatorWidth +
      NextSeasonTeaser.horizontalPadding +
      6;

  /// Зазор между видимыми краями соседних ромбов — обе линии этого ряда
  /// такой же длины, как между обычными уровнями.
  static const _segmentGap =
      TrackGeometry.levelExtent - 2 * TrackGeometry.diamondHalfSpan;

  static const _leadingLineWidth = _segmentGap - _backReach;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;
    // Один градиент на весь ряд чёрточек, а не на каждую (по дизайну).
    final dashGradient = LinearGradient(
      colors: [
        colors.screenBackground,
        colors.dashGradientMid,
        colors.screenBackground,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    return SizedBox(
      width: 439.0,
      height: TrackGeometry.diamondSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -_backReach,
            top: (TrackGeometry.diamondSize - _lineThickness) / 2,
            width: _backReach,
            height: _lineThickness,
            child: ColoredBox(color: colors.trackNodeDefault),
          ),
          Row(
            children: [
              SizedBox(
                width: _leadingLineWidth,
                child: ColoredBox(
                  color: colors.trackNodeDefault,
                  child: const SizedBox(height: 10),
                ),
              ),
              LevelDiamond(number: nextLevel, color: colors.trackNodeDefault),
              const SizedBox(width: 12),
              CustomPaint(
                size: const Size(_dashRowWidth, _lineThickness),
                painter: _DashesPainter(dashGradient),
              ),
              const SizedBox(width: 12),
              LevelDiamond(number: finalLevel, color: colors.trackNodeDefault),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashesPainter extends CustomPainter {
  _DashesPainter(this.gradient);

  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = gradient.createShader(Offset.zero & size);
    final radius = Radius.circular(size.height / 2);
    var left = 0.0;
    for (final width in _TeaserTrackRow._dashWidths) {
      canvas.drawRRect(
        RRect.fromLTRBR(left, 0, left + width, size.height, radius),
        paint,
      );
      left += width + _TeaserTrackRow._dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashesPainter oldDelegate) =>
      gradient != oldDelegate.gradient;
}
