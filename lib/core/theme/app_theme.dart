import 'package:flutter/material.dart';

import '../exports.dart';
import 'exports.dart';

/// Тема приложения: цвета и типографика подключены как [ThemeExtension] и
/// читаются из контекста — `context.theme.appColors`/`appTypography`.
abstract final class AppTheme {
  static final ThemeData appTheme = () {
    final colors = AppColors();
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: colors.mainColors.screenBackground,
      extensions: [colors, AppTypography()],
    );
  }();
}

extension AppThemeExtension on ThemeData {
  BaseColors get appColors => extension<AppColors>()!;

  AppTypography get appTypography => extension<AppTypography>()!;
}
