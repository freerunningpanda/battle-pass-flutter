import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Класс [AppTypography] содержит типографику приложения.
/// Все изменения в типографике производятся в этом классе.

class AppTypography extends BaseTypography<AppTypography> {
  /// Конструктор для типографики приложения
  AppTypography() : super(mobileTypo: _MobileTypo());

  @override
  ThemeExtension<AppTypography> copyWith() => AppTypography();

  @override
  ThemeExtension<AppTypography> lerp(
    covariant ThemeExtension<AppTypography>? other,
    double t,
  ) {
    if (other == null) return this;
    return AppTypography();
  }
}

class _MobileTypo extends MobileTypo {
  static const String _fontFamily = 'Geologica';

  // letterSpacing в Figma — "-1%" от fontSize, отсюда fontSize * -0.01.
  static const _letterSpacingPercent = -0.01;

  _MobileTypo()
    : super(
        h4: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 36,
          height: 1.3,
          letterSpacing: 36 * _letterSpacingPercent,
        ),
        p4Reg: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 22,
          height: 1.2,
          letterSpacing: 22 * _letterSpacingPercent,
        ),
        p1Med: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 22,
          height: 1.2,
          letterSpacing: 22 * _letterSpacingPercent,
        ),
        p2Med: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 30,
          height: 1.2,
          letterSpacing: 30 * _letterSpacingPercent,
        ),
        p4Med: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 22,
          height: 1.2,
          letterSpacing: 22 * _letterSpacingPercent,
        ),
        bold14: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        semibold24: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        medium26: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 26,
          height: 1.2,
          letterSpacing: 26 * _letterSpacingPercent,
        ),
        semibold26: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 26,
          height: 1.2,
          letterSpacing: 26 * _letterSpacingPercent,
        ),
        medium26Tall: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 26,
          height: 1.35,
          letterSpacing: 26 * _letterSpacingPercent,
        ),
        medium30: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 30,
          height: 1.2,
          letterSpacing: 30 * _letterSpacingPercent,
        ),
        semibold30: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 30,
          height: 1.2,
          letterSpacing: 30 * _letterSpacingPercent,
        ),
        // Свой трекинг по спеке премиум-тизера.
        medium30Tight: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 30,
          height: 1.2,
          letterSpacing: -1.0,
        ),
        semibold42: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 42,
          height: 1.3,
          letterSpacing: 42 * _letterSpacingPercent,
        ),
        semibold48: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 48,
          height: 0.93,
          letterSpacing: 48 * _letterSpacingPercent,
        ),
      );
}
