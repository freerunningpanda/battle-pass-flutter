import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Геометрия трека наград — общая для раскладки уровней, линий прогресса
/// между ромбами и расчёта скролла. Меняется в одном месте.
abstract final class TrackGeometry {
  static const double tileWidth = RewardCarouselTile.defaultWidth;

  /// Стрелка-разделитель между уровнями.
  static const double separatorWidth = 12;

  /// Шаг уровня — и расстояние между центрами соседних ромбов.
  static const double levelExtent = tileWidth + separatorWidth;

  static const double diamondSize = 34;

  /// Половина диагонали ромба [diamondSize], повёрнутого на 45°: на столько
  /// его кончик выступает от центра.
  static const double diamondHalfSpan = diamondSize * math.sqrt2 / 2;

  static const double lineThickness = 10;
}

/// Ромб с номером уровня под плиткой трека.
class LevelDiamond extends StatelessWidget {
  const LevelDiamond({required this.number, required this.color, super.key});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: TrackGeometry.diamondSize,
        height: TrackGeometry.diamondSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        child: Transform.rotate(
          angle: -math.pi / 4,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              // Трёхзначные номера сжимаются, а не обрезаются.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$number',
                  style: theme.appTypography.mobileTypo.bold14.copyWith(
                    color: theme.appColors.mainColors.appColorWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
