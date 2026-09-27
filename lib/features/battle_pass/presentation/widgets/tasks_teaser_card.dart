import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

/// Тизер заданий на главном экране: шапка с наградой и прогрессом поверх
/// карточки с описанием задания и переходом на экран заданий.
class TasksTeaserCard extends StatelessWidget {
  const TasksTeaserCard({
    required this.onTap,
    this.task,
    this.claimableInline = false,
    this.onClaimXp,
    super.key,
  });

  final VoidCallback onTap;
  final BattlePassTask? task;

  /// Выполненное задание забирается прямо с тизера ("Забрать опыт"), а не
  /// открывает экран заданий.
  final bool claimableInline;
  final VoidCallback? onClaimXp;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;

    const cardLeft = 346.0;
    const cardTop = 220.0;

    final task = this.task;
    if (task == null) return const SizedBox.shrink();

    final claimMode = claimableInline && task.completed;
    // В режиме получения прогресс остаётся на полной яркости.
    final cardTap = claimMode ? (task.claimed ? null : onClaimXp) : onTap;

    return Positioned(
      left: cardLeft,
      top: cardTop,
      width: 400,
      child: Material(
        color: colors.appColorTransparent,
        child: InkWell(
          onTap: cardTap,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RewardHeader(
                rewardXp: task.rewardXp,
                progressCurrent: task.progressCurrent,
                progressTarget: task.progressTarget,
                completed: task.completed && !claimMode,
              ),
              _TaskBody(
                title: task.title,
                progressCurrent: task.progressCurrent,
                progressTarget: task.progressTarget,
                completed: task.completed && !claimMode,
                centerContent: claimMode,
                dimProgress: claimMode,
                footerButton: claimMode
                    ? _ClaimXpButton(claimed: task.claimed)
                    : _TasksButton(showRewardBadge: task.completed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Притушенность выполненного, но не забранного задания. Кнопка "Задания"
// и её бейдж не притушиваются.
const double _kCompletedOpacity = 0.55;

class _RewardHeader extends StatelessWidget {
  const _RewardHeader({
    required this.rewardXp,
    required this.progressCurrent,
    required this.progressTarget,
    required this.completed,
  });

  final int rewardXp;
  final int progressCurrent;
  final int progressTarget;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const fullOpacity = 1.0;
    const doneBadgeLeft = 294.0;
    const doneBadgeTop = 44.0;

    return Stack(
      children: [
        Opacity(
          opacity: completed ? _kCompletedOpacity : fullOpacity,
          child: Container(
            height: 110,
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: colors.taskCardHeaderBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Image.asset(AppAssets.imageIconXpBp, width: 96, height: 96),
                const SizedBox(width: 12),
                Text(
                  '${AppStrings.taskRewardXpPrefix}$rewardXp',
                  textAlign: TextAlign.center,
                  style: theme.appTypography.mobileTypo.medium26.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 112,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.taskChipBg,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  // Место под галочку — сама она рисуется ниже без притушения.
                  child: completed
                      ? null
                      : Text.rich(
                          TextSpan(
                            style: theme.appTypography.mobileTypo.medium26
                                .copyWith(
                                  color: colors.progressRingFill, // textMuted
                                ),
                            children: [
                              TextSpan(
                                text: '$progressCurrent',
                                style: TextStyle(color: colors.claimGreenTop),
                              ),
                              TextSpan(
                                text:
                                    '${AppStrings.taskProgressSeparator}'
                                    '$progressTarget',
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        // Галочка поверх притушенной шапки, на месте плашки справа.
        if (completed)
          Positioned(
            left: doneBadgeLeft,
            top: doneBadgeTop,
            child: IgnorePointer(
              child: SvgPicture.asset(
                AppAssets.iconDone,
                width: 40,
                height: 22,
              ),
            ),
          ),
      ],
    );
  }
}

class _TaskBody extends StatelessWidget {
  const _TaskBody({
    required this.title,
    required this.progressCurrent,
    required this.progressTarget,
    required this.completed,
    required this.footerButton,
    this.centerContent = false,
    this.dimProgress = false,
  });

  final String title;
  final int progressCurrent;
  final int progressTarget;
  final bool completed;
  final Widget footerButton;

  /// В режиме получения заголовок центрирован и не притушен.
  final bool centerContent;

  /// Сегменты прогресса притушены и в режиме получения.
  final bool dimProgress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const fullOpacity = 1.0;

    return SizedBox(
      width: 400,
      child: Stack(
        children: [
          // Кнопка — отдельным слоем поверх, без притушения.
          Positioned.fill(
            child: Opacity(
              opacity: completed ? _kCompletedOpacity : fullOpacity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.taskCardBodyBg,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 44, 40, 20),
            child: Column(
              crossAxisAlignment: centerContent
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: completed ? _kCompletedOpacity : fullOpacity,
                  child: Text(
                    title,
                    textAlign: centerContent
                        ? TextAlign.center
                        : TextAlign.start,
                    style: theme.appTypography.mobileTypo.p1Med.copyWith(
                      color: colors.progressRingFill, // = textMuted
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Opacity(
                  opacity: (completed || dimProgress)
                      ? _kCompletedOpacity
                      : fullOpacity,
                  child: _ProgressDashes(
                    current: progressCurrent,
                    target: progressTarget,
                  ),
                ),
                const SizedBox(height: 34),
                footerButton,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDashes extends StatelessWidget {
  const _ProgressDashes({required this.current, required this.target});

  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(target, (index) {
        final filled = index < current;
        return Container(
          width: 54,
          height: 8,
          decoration: BoxDecoration(
            color: filled ? colors.textPrimary : colors.progressRingTrack,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        );
      }),
    );
  }
}

class _TasksButton extends StatelessWidget {
  const _TasksButton({this.showRewardBadge = false});

  final bool showRewardBadge;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    const badgeRight = -12.0;
    const badgeTop = -10.0;
    const badgeGlowBlurRadius = 10.0;
    const badgeGlowSpreadRadius = 2.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 320,
          padding: const EdgeInsets.fromLTRB(36, 20, 36, 23),
          decoration: BoxDecoration(
            color: colors.buttonOverlayStrong,
            borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.iconTasks, width: 30, height: 30),
              const SizedBox(width: 16),
              Text(
                AppStrings.tasksButtonLabel,
                style: theme.appTypography.mobileTypo.medium26.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Бейдж "есть невостребованная награда" — сидит в правом верхнем
        // углу кнопки, слегка выходя за её границы.
        if (showRewardBadge)
          Positioned(
            right: badgeRight,
            top: badgeTop,
            child: Container(
              width: 44,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: colors.glowShadow,
                    blurRadius: badgeGlowBlurRadius,
                    spreadRadius: badgeGlowSpreadRadius,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                AppAssets.iconStickerNew,
                width: 44,
                height: 46,
              ),
            ),
          ),
      ],
    );
  }
}

/// "Забрать опыт" / "Получено". Своего тапа нет — реагирует вся карточка.
class _ClaimXpButton extends StatelessWidget {
  const _ClaimXpButton({required this.claimed});

  final bool claimed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.appColors.mainColors;

    final claimXpButtonGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [colors.claimXpButtonTop, colors.claimXpButtonBottom],
    );

    return Container(
      width: 320,
      padding: const EdgeInsets.fromLTRB(36, 20, 36, 23),
      decoration: BoxDecoration(
        gradient: claimed ? null : claimXpButtonGradient,
        color: claimed ? colors.taskChipBg : null,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (claimed) ...[
            SvgPicture.asset(AppAssets.iconDone, width: 26, height: 14),
            const SizedBox(width: 14),
          ],
          Text(
            claimed ? AppStrings.xpClaimedLabel : AppStrings.claimXpButtonLabel,
            style: theme.appTypography.mobileTypo.medium26.copyWith(
              color: claimed ? colors.progressRingFill : colors.claimXpText,
            ),
          ),
        ],
      ),
    );
  }
}
