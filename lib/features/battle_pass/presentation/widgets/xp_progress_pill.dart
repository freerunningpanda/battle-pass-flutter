import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Кольцо прогресса уровня с номером в центре и опытом под ним.
class XpProgressPill extends StatelessWidget {
  const XpProgressPill({required this.season, super.key});

  final BattlePassSeason season;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const fullProgress = 1.0;
    const noProgress = 0.0;
    const pillLeft = 346.0;
    const pillTop = 37.0;
    const ringStrokeWidth = 8.0;

    final currentXp = season.currentXp;
    final nextLevelXp = season.nextLevelXp;
    final progress = nextLevelXp == null || nextLevelXp == 0
        ? fullProgress
        : (currentXp / nextLevelXp).clamp(noProgress, fullProgress);
    // На макс. уровне порога нет — подпись "текущее/текущее" при полном
    // кольце: текст "Максимальный уровень" не помещается под кольцом.
    final xpLabelTarget = nextLevelXp ?? currentXp;
    return Positioned(
      left: pillLeft,
      top: pillTop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Без tight-размера индикатор рисуется в дефолтные ~36px.
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: ringStrokeWidth,
                    backgroundColor: colors.progressRingTrack,
                    valueColor: AlwaysStoppedAnimation(colors.progressRingFill),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${season.currentLevel}',
                      maxLines: 1,
                      style: theme.appTypography.mobileTypo.semibold42.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Не шире кольца — длинный опыт иначе наезжает на таймер.
          SizedBox(
            width: 100,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$currentXp${AppStrings.xpProgressSeparator}$xpLabelTarget',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: theme.appTypography.mobileTypo.p1Med.copyWith(
                  color: colors.progressRingFill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
