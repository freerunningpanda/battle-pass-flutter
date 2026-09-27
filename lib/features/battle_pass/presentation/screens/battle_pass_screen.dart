import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../exports.dart';

class BattlePassScreen extends StatelessWidget {
  const BattlePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BattlePassCubit>(
      create: (_) => sl<BattlePassCubit>(),
      child: BlocProvider<TasksCubit>(
        create: (_) => sl<TasksCubit>(),
        // Мок-таск на тизер-карточке (см. TasksMockApi) свой под каждый
        // сценарий (разные xp/прогресс/текст) — держим его в синхроне со
        // scenario, а не только с начальным сценарием TasksCubit по
        // умолчанию. Сравниваем именно scenario, а не season.premiumOwned:
        // "премиум куплен/награда" и "макс. уровень" оба premiumOwned=true,
        // но с разными тасками.
        child: BlocListener<BattlePassCubit, BattlePassState>(
          listenWhen: (previous, current) =>
              current is BattlePassLoaded &&
              (previous is! BattlePassLoaded ||
                  previous.scenario != current.scenario),
          listener: (context, state) {
            if (state is BattlePassLoaded) {
              context.read<TasksCubit>().load(state.scenario);
            }
          },
          child: const _BattlePassView(),
        ),
      ),
    );
  }
}

class _BattlePassView extends StatelessWidget {
  const _BattlePassView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BattlePassCubit, BattlePassState>(
        builder: (context, state) {
          final colors = context.theme.appColors.mainColors;

          return switch (state) {
            BattlePassLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BattlePassError(:final message) => Center(
              child: Text(
                message,
                style: TextStyle(color: colors.appColorWhite),
              ),
            ),
            BattlePassLoaded(:final season, :final scenario) => _LoadedView(
              season: season,
              scenario: scenario,
            ),
          };
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.season, required this.scenario});

  final BattlePassSeason season;
  final BattlePassScenario scenario;

  @override
  Widget build(BuildContext context) {
    final layout = ScenarioLayout.of(scenario);
    final colors = context.theme.appColors.mainColors;
    final canClaimAll =
        layout.claimAllButton &&
        season.levels.any((l) => l.state == LevelState.claimable);

    return Stack(
      children: [
        DesignCanvas(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const BattlePassBackground(),
              const LeftNavPanel(),
              XpProgressPill(
                currentLevel: season.currentLevel,
                maxLevel: season.maxLevel,
                currentXp: season.currentXp,
                xpToNextLevel: season.currentLevel < season.levels.length
                    ? season.levels[season.currentLevel - 1].requiredXp
                    : 0,
              ),
              const EventTimerBanner(),
              if (layout.endedNotice)
                const BattlePassEndedNotice()
              else
                BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, tasksState) {
                    final task = switch (tasksState) {
                      TasksLoaded(:final overview) =>
                        overview.tasks.isEmpty ? null : overview.tasks.first,
                      _ => null,
                    };
                    return TasksTeaserCard(
                      task: task,
                      onTap: () => AppRouter.toTasks(context),
                      claimableInline: layout.inlineTaskClaim,
                      onClaimXp: task == null
                          ? null
                          : () =>
                                context.read<TasksCubit>().claimTaskXp(task.id),
                    );
                  },
                ),
              CentralItemDisplay(scenario: scenario),
              _DismissiblePremiumPromo(
                premiumOwned: season.premiumOwned,
                onUnlockPremium: () =>
                    context.read<BattlePassCubit>().purchasePremium(),
                onIncreaseLevel: () =>
                    context.read<BattlePassCubit>().increaseLevel(),
                maxLevelReached:
                    season.currentLevel >= season.maxLevel &&
                    !layout.levelUpEnabledAtMax,
                claimAllButton: canClaimAll
                    ? ClaimAllButton(
                        label: AppStrings.claimAllRewardsButton,
                        // Тот же зелёный, что и claimGreen* в теме
                        // (см. reward_tile.dart._ClaimButton), но
                        // слева направо, а не сверху вниз.
                        gradient: LinearGradient(
                          colors: [
                            colors.claimGreenTop,
                            colors.claimGreenBottom,
                          ],
                        ),
                        onPressed: () =>
                            context.read<BattlePassCubit>().claimAllRewards(),
                      )
                    : null,
              ),
              RewardsTrack(
                season: season,
                appearance: layout.track,
                onClaim: (levelNumber) async {
                  // Второй вызов должен дождаться первого: claimReward
                  // читает текущий cubit.state как снимок для copyWith,
                  // и если оба вызова стартуют не дожидаясь друг друга,
                  // они оба берут один и тот же снимок "до клейма" —
                  // тогда результат более позднего emit затирает более
                  // ранний (особенно заметно, когда премиум-награды на
                  // уровне нет: тот вызов — no-op, но всё равно
                  // переэмитит устаревший season поверх уже забранного).
                  final cubit = context.read<BattlePassCubit>();
                  await cubit.claimReward(levelNumber, isPremiumReward: false);
                  if (season.premiumOwned) {
                    await cubit.claimReward(levelNumber, isPremiumReward: true);
                  }
                },
                onUnlockPremium: () =>
                    context.read<BattlePassCubit>().purchasePremium(),
              ),
            ],
          ),
        ),
        ScenarioSwitcher(
          current: scenario,
          onChanged: (s) => context.read<BattlePassCubit>().switchScenario(s),
        ),
      ],
    );
  }
}

/// Баннер премиума + кнопка закрытия — своё локальное состояние видимости,
/// изолированное в отдельном виджете: скрытие/показ не должно триггерить
/// перестройку соседей по Stack (трек наград и т.п.), которые с баннером
/// никак не связаны.
class _DismissiblePremiumPromo extends StatefulWidget {
  const _DismissiblePremiumPromo({
    required this.premiumOwned,
    required this.onUnlockPremium,
    required this.onIncreaseLevel,
    this.claimAllButton,
    this.maxLevelReached = false,
  });

  final bool premiumOwned;
  final VoidCallback onUnlockPremium;
  final VoidCallback onIncreaseLevel;
  final Widget? claimAllButton;
  final bool maxLevelReached;

  @override
  State<_DismissiblePremiumPromo> createState() =>
      _DismissiblePremiumPromoState();
}

class _DismissiblePremiumPromoState extends State<_DismissiblePremiumPromo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    void dismiss() => setState(() => _visible = false);

    const claimAllButtonRight = 6.0;
    // Нижний край кнопки "Забрать все награды" должен оставаться выше
    // плавающего превью юбилейного уровня в RewardsTrack — см. комментарий
    // ниже про Positioned(bottom: AppDimens.designHeight - ...).
    const claimAllButtonBottomAnchor = 748.0;
    const claimAllButtonBottomMargin = 8.0;
    const closeButtonRight = 80.0;
    const closeButtonTop = 50.0;

    return Positioned.fill(
      child: Stack(
        children: [
          PremiumBanner(
            premiumOwned: widget.premiumOwned,
            // Кнопка баннера переключает сценарий в обоих состояниях —
            // "Прокачать" ведёт на премиум, "Повысить уровень" на макс.
            // уровень; скрытие баннера остаётся отдельным действием
            // крестика рядом, а не побочным эффектом этой кнопки.
            onPressed: widget.premiumOwned
                ? widget.onIncreaseLevel
                : widget.onUnlockPremium,
            maxLevelReached: widget.maxLevelReached,
          ),
          // Отдельный элемент Stack, а не часть колонки баннера — баннер
          // фиксированной высоты, и добавление кнопки внутрь неё раньше
          // сдвигало заголовок/подзаголовок вверх (растущий снизу-вверх
          // bottom-anchored Column). "top: height+24" (сразу под баннером)
          // наезжал на плавающее превью юбилейного уровня из RewardsTrack —
          // оно якорится от низа холста (Positioned(bottom:24,height:300) +
          // сама карточка 268+12+34=314 снизу с отступом 14 в rewards_track
          // .dart), поэтому её верхний край фиксирован в координатах холста:
          // designHeight-24-14-314=728. Поднимаем кнопку по низу (не по
          // верху — так не нужно знать точную высоту самой кнопки), чтобы
          // её нижний край гарантированно оставался выше этой отметки.
          if (widget.claimAllButton != null)
            Positioned(
              right: claimAllButtonRight,
              bottom:
                  AppDimens.designHeight -
                  claimAllButtonBottomAnchor +
                  claimAllButtonBottomMargin,
              width: PremiumBanner.width,
              child: Center(child: widget.claimAllButton),
            ),
          Positioned(
            right: closeButtonRight,
            top: closeButtonTop,
            child: Material(
              color: context.theme.appColors.mainColors.buttonOverlayWeak,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: dismiss,
                child: Container(
                  width: AppSizes.allSize100,
                  height: AppSizes.allSize100,
                  padding: AppPadding.allPadding32,
                  child: SvgPicture.asset(
                    AppAssets.iconClose,
                    width: AppSizes.allSize36,
                    height: AppSizes.allSize36,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
