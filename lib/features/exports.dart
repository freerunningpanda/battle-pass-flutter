// Единая точка импорта для presentation-слоя features/**: вместо набора
// относительных путей в каждом файле — один `import '.../exports.dart';`.
// Затрагивает только screens/widgets/cubit — domain- и data-слои сюда
// намеренно не включены (см. обсуждение рефакторинга).

// Core
export '../core/di/injection_container.dart';
export '../core/extensions/build_context_extension.dart';
export '../core/navigation/app_router.dart';
export '../core/theme/app_assets.dart';
export '../core/theme/app_dimens.dart';
export '../core/theme/app_padding.dart';
export '../core/theme/app_radius.dart';
export '../core/theme/app_sized_boxes.dart';
export '../core/theme/app_sizes.dart';
export '../core/theme/app_strings.dart';
export '../core/theme/app_theme.dart';
export '../core/theme/exports.dart';

// Battle Pass — domain
export 'battle_pass/domain/entities/level.dart';
export 'battle_pass/domain/entities/reward.dart';
export 'battle_pass/domain/entities/season.dart';
export 'battle_pass/domain/repositories/battle_pass_repository.dart';
export 'battle_pass/domain/usecases/claim_all_rewards.dart';
export 'battle_pass/domain/usecases/claim_reward.dart';
export 'battle_pass/domain/usecases/get_season.dart';

// Battle Pass — presentation
export 'battle_pass/presentation/cubit/battle_pass_cubit.dart';
export 'battle_pass/presentation/cubit/battle_pass_state.dart';
export 'battle_pass/presentation/widgets/battle_pass_background.dart';
export 'battle_pass/presentation/widgets/battle_pass_ended_notice.dart';
export 'battle_pass/presentation/widgets/central_item_display.dart';
export 'battle_pass/presentation/widgets/claim_all_button.dart';
export 'battle_pass/presentation/widgets/design_canvas.dart';
export 'battle_pass/presentation/widgets/event_countdown.dart';
export 'battle_pass/presentation/widgets/event_timer_banner.dart';
export 'battle_pass/presentation/widgets/left_nav_panel.dart';
export 'battle_pass/presentation/widgets/premium_banner.dart';
export 'battle_pass/presentation/widgets/premium_teaser_cluster.dart';
export 'battle_pass/presentation/widgets/reward_carousel_tile.dart';
export 'battle_pass/presentation/widgets/reward_tile.dart';
export 'battle_pass/presentation/widgets/rewards_track.dart';
export 'battle_pass/presentation/widgets/scenario_flavor.dart';
export 'battle_pass/presentation/widgets/scenario_layout.dart';
export 'battle_pass/presentation/widgets/scenario_switcher.dart';
export 'battle_pass/presentation/widgets/tasks_teaser_card.dart';
export 'battle_pass/presentation/widgets/track_appearance.dart';
export 'battle_pass/presentation/widgets/xp_progress_pill.dart';
export 'battle_pass/presentation/screens/battle_pass_screen.dart';

// Tasks — domain
export 'tasks/domain/entities/task.dart';
export 'tasks/domain/entities/tasks_overview.dart';
export 'tasks/domain/usecases/get_tasks.dart';

// Tasks — presentation
export 'tasks/presentation/cubit/tasks_cubit.dart';
export 'tasks/presentation/cubit/tasks_state.dart';
