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
        child: MultiBlocListener(
          listeners: [
            // Задания зависят от сценария мок-бэкенда — перезагружаем их
            // при каждой его смене.
            BlocListener<BattlePassCubit, BattlePassState>(
              listenWhen: (previous, current) =>
                  current is BattlePassLoaded &&
                  (previous is! BattlePassLoaded ||
                      previous.scenario != current.scenario),
              listener: (context, _) => context.read<TasksCubit>().load(),
            ),
            BlocListener<BattlePassCubit, BattlePassState>(
              listenWhen: (_, current) =>
                  current is BattlePassLoaded && current.actionError != null,
              listener: (context, state) {
                final error = (state as BattlePassLoaded).actionError!;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.message)));
              },
            ),
          ],
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
              XpProgressPill(season: season),
              EventTimerBanner(deadline: season.seasonEndsAt),
              if (layout.endedNotice)
                BattlePassEndedNotice(deadline: season.seasonEndsAt)
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
              // Ключ по сценарию: при его смене закрытый баннер снова
              // показывается, а трек заново встаёт в начальную позицию.
              _DismissiblePremiumPromo(
                key: ValueKey((#promo, scenario)),
                premiumOwned: season.premiumOwned,
                onUnlockPremium: () =>
                    context.read<BattlePassCubit>().purchasePremium(),
                onIncreaseLevel: () =>
                    context.read<BattlePassCubit>().increaseLevel(),
                maxLevelReached:
                    season.isMaxLevel && !layout.levelUpEnabledAtMax,
                claimAllButton: canClaimAll
                    ? ClaimAllButton(
                        label: AppStrings.claimAllRewardsButton,
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
                key: ValueKey((#track, scenario)),
                season: season,
                appearance: layout.track,
                onClaim: context.read<BattlePassCubit>().claimLevel,
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

/// Баннер премиума с кнопкой закрытия. Видимость — локальное состояние,
/// чтобы закрытие не перестраивало остальной экран.
class _DismissiblePremiumPromo extends StatefulWidget {
  const _DismissiblePremiumPromo({
    required this.premiumOwned,
    super.key,
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
    const claimAllButtonBottomAnchor = 748.0;
    const claimAllButtonBottomMargin = 8.0;
    const closeButtonRight = 80.0;
    const closeButtonTop = 50.0;

    return Positioned.fill(
      child: Stack(
        children: [
          PremiumBanner(
            premiumOwned: widget.premiumOwned,
            onPressed: widget.premiumOwned
                ? widget.onIncreaseLevel
                : widget.onUnlockPremium,
            maxLevelReached: widget.maxLevelReached,
          ),
          // Кнопка привязана низом к верхнему краю превью юбилейного уровня
          // (его положение на холсте фиксировано), чтобы не наезжать на него.
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
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(32),
                  child: SvgPicture.asset(
                    AppAssets.iconClose,
                    width: 36,
                    height: 36,
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
