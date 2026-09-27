import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

/// Итоговое сообщение с обратным отсчётом вместо карточки заданий, когда
/// боевой пропуск завершён.
class BattlePassEndedNotice extends StatelessWidget {
  const BattlePassEndedNotice({required this.deadline, super.key});

  final DateTime deadline;

  static const double _cardWidth = 466;
  static const double _stickerHeight = 92;

  // Иконка выступает над карточкой на половину своей высоты.
  static const double _cardTop = 305;
  static const double _stickerTop = _cardTop - _stickerHeight / 2;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    const noticeLeft = 346.0;
    const stickerGlowTop = -8.0;
    const stickerGlowBlurRadius = 40.0;
    const stickerGlowSpreadRadius = 1.0;

    return Positioned(
      left: noticeLeft,
      top: _stickerTop,
      width: _cardWidth,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 46),
            child: _Card(deadline: deadline),
          ),
          Positioned(
            top: stickerGlowTop,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: theme.appColors.mainColors.glowShadow,
                    blurRadius: stickerGlowBlurRadius,
                    spreadRadius: stickerGlowSpreadRadius,
                  ),
                ],
              ),
              child: SvgPicture.asset(AppAssets.iconStickerBig),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.deadline});

  final DateTime deadline;

  static const _borderWidth = 4.0;
  static const _outerRadius = 40.0;

  // Геометрия диагонального блика (по Figma).
  static const _sheenBegin = Alignment(-0.99, -0.14); // ≈ 97.91deg
  static const _sheenEnd = Alignment(0.99, 0.14);
  static const _sheenStops = [0.0, 0.5745, 0.7907, 0.9241, 1.0];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    // Фон — два слоя (заливка и блик), поэтому два DecoratedBox.
    final flatBg = colors.endedNoticeFlatBg; // rgba(117,83,27,0.6)
    final sheenGradient = LinearGradient(
      begin: _sheenBegin,
      end: _sheenEnd,
      stops: _sheenStops,
      colors: [
        colors.endedNoticeSheenTransparent,
        colors.endedNoticeSheenTransparent,
        colors.endedNoticeSheenHighlight, // rgba(200,166,111,0.3)
        colors.endedNoticeSheenTransparent,
        colors.endedNoticeSheenTransparent,
      ],
    );
    // Кольцо рамки рисуется отдельно поверх контента: фон карточки
    // полупрозрачный, и заливка под рамкой просвечивала бы сквозь него.
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors.levelUpBorderOrange,
        colors.levelUpBorderYellow,
        colors.levelUpBorderLight,
        colors.levelUpBorderAmber,
        colors.levelUpBorderCoral,
      ],
      stops: const [0.0, 0.37, 0.40, 0.73, 1.0],
    );

    const cardGlowBlurRadius = 40.0;
    const cardGlowSpreadRadius = 2.0;

    return Container(
      width: BattlePassEndedNotice._cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_outerRadius),
        boxShadow: [
          BoxShadow(
            color: colors.glowShadow,
            blurRadius: cardGlowBlurRadius,
            spreadRadius: cardGlowSpreadRadius,
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _GradientBorderPainter(
          radius: _outerRadius,
          borderWidth: _borderWidth,
          borderColor: colors.glowGold,
          borderGradient: borderGradient,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_outerRadius - _borderWidth),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: sheenGradient),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(color: flatBg)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppStrings.battlePassEndedTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: theme.appTypography.mobileTypo.h4.copyWith(
                          color: theme.appColors.mainColors.appColorWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.battlePassEndedSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.appTypography.mobileTypo.medium26.copyWith(
                        color: colors.timerText, // #E9E9F3 @ 0.4
                      ),
                    ),
                    const SizedBox(height: 28),
                    _TimerPill(deadline: deadline),
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

/// Кольцо рамки (evenOdd-путь, середина не закрашивается): сплошной
/// [borderColor] и поверх — блик [borderGradient] в режиме overlay.
/// saveLayer ограничивает смешивание самим кольцом.
class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.radius,
    required this.borderWidth,
    required this.borderColor,
    required this.borderGradient,
  });

  final double radius;
  final double borderWidth;
  final Color borderColor;
  final Gradient borderGradient;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Offset.zero & size;
    final outerRRect = RRect.fromRectAndRadius(outer, Radius.circular(radius));
    final inner = outer.deflate(borderWidth);
    final innerRadius = (radius - borderWidth).clamp(0.0, double.infinity);
    final innerRRect = RRect.fromRectAndRadius(
      inner,
      Radius.circular(innerRadius),
    );
    final ringPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(outerRRect)
      ..addRRect(innerRRect);

    canvas.saveLayer(outer, Paint());
    canvas.drawPath(ringPath, Paint()..color = borderColor);
    canvas.drawPath(
      ringPath,
      Paint()
        ..shader = borderGradient.createShader(outer)
        ..blendMode = BlendMode.overlay,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      radius != oldDelegate.radius ||
      borderWidth != oldDelegate.borderWidth ||
      borderColor != oldDelegate.borderColor ||
      borderGradient != oldDelegate.borderGradient;
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.deadline});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    // Более пологая диагональ, чем у рамки: чип широкий и низкий.
    final pillGradient = LinearGradient(
      begin: const Alignment(-1.0, -0.4),
      end: const Alignment(1.0, 0.4),
      colors: [
        colors.levelUpBorderOrange,
        colors.levelUpBorderYellow,
        colors.levelUpBorderAmber,
        colors.levelUpBorderCoral,
      ],
      stops: const [0.0, 0.28, 0.72, 1.0],
    );

    return Container(
      // Ширина из Figma — минимальная: длинный остаток не должен обрезаться.
      constraints: const BoxConstraints(minWidth: 214, minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      decoration: BoxDecoration(
        gradient: pillGradient,
        borderRadius: const BorderRadius.all(Radius.circular(60)),
      ),
      child: EventCountdownText(
        deadline: deadline,
        style: theme.appTypography.mobileTypo.semibold30.copyWith(
          color: colors.countdownPillText,
        ),
      ),
    );
  }
}
