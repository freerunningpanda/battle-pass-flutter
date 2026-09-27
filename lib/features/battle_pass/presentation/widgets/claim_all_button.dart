import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Кнопка "Забрать все награды".
class ClaimAllButton extends StatelessWidget {
  const ClaimAllButton({
    required this.label,
    required this.gradient,
    required this.onPressed,
    super.key,
  });

  final String label;
  final LinearGradient gradient;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Material(
        color: colors.appColorTransparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          onTap: onPressed,
          child: Container(
            width: 400,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.appTypography.mobileTypo.semibold24.copyWith(
                color: colors.appColorWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
