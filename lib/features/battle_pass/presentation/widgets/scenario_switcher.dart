import 'package:flutter/material.dart';

import '../../../exports.dart';

/// Dev-переключатель сценариев мок-бэкенда (не часть макета).
class ScenarioSwitcher extends StatefulWidget {
  const ScenarioSwitcher({
    required this.current,
    required this.onChanged,
    super.key,
  });

  final BattlePassScenario current;
  final ValueChanged<BattlePassScenario> onChanged;

  @override
  State<ScenarioSwitcher> createState() => _ScenarioSwitcherState();
}

class _ScenarioSwitcherState extends State<ScenarioSwitcher> {
  static const _labels = {
    BattlePassScenario.premiumLocked: AppStrings.devScenarioPremiumLocked,
    BattlePassScenario.premiumUnlockedWithReward:
        AppStrings.devScenarioPremiumUnlockedWithReward,
    BattlePassScenario.maxLevel: AppStrings.devScenarioMaxLevel,
    BattlePassScenario.premiumUnlockedNoReward:
        AppStrings.devScenarioPremiumUnlockedNoReward,
    BattlePassScenario.maxLevelNoReward: AppStrings.devScenarioMaxLevelNoReward,
    BattlePassScenario.completed: AppStrings.battlePassEndedTitle,
    BattlePassScenario.rewardsEndedPremiumOwned:
        AppStrings.devScenarioRewardsEndedPremiumOwned,
    BattlePassScenario.rewardsEndedPremiumNotOwned:
        AppStrings.devScenarioRewardsEndedPremiumNotOwned,
  };

  // Подсказка к маленькой кнопке — показывается при каждом запуске.
  bool _showHint = true;

  void _dismissHint() {
    if (_showHint) setState(() => _showHint = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;

    const buttonBgAlpha = 0.55;
    const buttonIconSize = 22.0;

    return Stack(
      children: [
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: PopupMenuButton<BattlePassScenario>(
                initialValue: widget.current,
                onSelected: widget.onChanged,
                tooltip: AppStrings.devScenarioSwitcherTooltip,
                itemBuilder: (context) => [
                  for (final scenario in BattlePassScenario.values)
                    PopupMenuItem(
                      value: scenario,
                      child: Row(
                        children: [
                          if (scenario == widget.current)
                            const Icon(Icons.check, size: 18)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _labels[scenario] ?? scenario.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.appColorBlack.withValues(
                      alpha: buttonBgAlpha,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_horiz,
                    color: colors.appColorWhite,
                    size: buttonIconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showHint) _ScenarioSwitcherHint(onDismiss: _dismissHint),
      ],
    );
  }
}

/// Затемнение экрана и выноска со стрелкой на кнопку; снимается тапом.
class _ScenarioSwitcherHint extends StatelessWidget {
  const _ScenarioSwitcherHint({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const overlayAlpha = 0.6;
    const bubbleMaxWidth = 280.0;
    const bubblePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    const bubbleBorderWidth = 1.5;
    const bubbleGlowBlurRadius = 20.0;
    const bubbleGlowSpreadRadius = 1.0;
    const calloutRight = 12.0;
    const calloutBottom = 74.0;
    const arrowSize = 32.0;
    // Стрелка заходит под рамку, чтобы не было видно шва.
    const arrowOverlap = -4.0;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: ColoredBox(
          color: colors.appColorBlack.withValues(alpha: overlayAlpha),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  right: calloutRight,
                  bottom: calloutBottom,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: bubbleMaxWidth,
                        ),
                        child: Container(
                          padding: bubblePadding,
                          decoration: BoxDecoration(
                            color: colors.taskCardHeaderBg,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(24),
                            ),
                            border: Border.all(
                              color: colors.glowGold,
                              width: bubbleBorderWidth,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.glowShadow,
                                blurRadius: bubbleGlowBlurRadius,
                                spreadRadius: bubbleGlowSpreadRadius,
                              ),
                            ],
                          ),
                          child: Text(
                            AppStrings.devScenarioSwitcherTooltip,
                            textAlign: TextAlign.center,
                            style: theme.appTypography.mobileTypo.p1Med
                                .copyWith(color: colors.accentGold),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, arrowOverlap),
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: arrowSize,
                          color: colors.glowGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
