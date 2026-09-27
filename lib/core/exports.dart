// Единая точка импорта для lib/core/**.

// Core
export 'demo/demo_scenario.dart';
export 'result/result.dart';
export 'usecase/use_case.dart';

// DI
export '../core/di/injection_container.dart';

// Battle Pass — data/domain/presentation (нужны injection_container.dart)
export '../features/battle_pass/data/mock/battle_pass_mock_api.dart';
export '../features/battle_pass/data/repositories/battle_pass_repository_impl.dart';
export '../features/battle_pass/domain/repositories/battle_pass_repository.dart';
export '../features/battle_pass/domain/usecases/claim_all_rewards.dart';
export '../features/battle_pass/domain/usecases/claim_level.dart';
export '../features/battle_pass/domain/usecases/get_season.dart';
export '../features/battle_pass/presentation/cubit/battle_pass_cubit.dart';

// Tasks — data/domain/presentation (нужны injection_container.dart/app_router.dart)
export '../features/tasks/data/mock/tasks_mock_api.dart';
export '../features/tasks/data/repositories/tasks_repository_impl.dart';
export '../features/tasks/domain/repositories/tasks_repository.dart';
export '../features/tasks/domain/usecases/get_tasks.dart';
export '../features/tasks/presentation/cubit/tasks_cubit.dart';
export '../features/tasks/presentation/screens/tasks_screen.dart';

// Typography — base
export '../core/theme/typography/base/mobile_typo.dart';
export '../core/theme/typography/base/base_typography.dart';

// Theme
export '../core/theme/typography/impl/app_typography.dart';
export '../core/theme/app_theme.dart';

// Extensions
export '../core/extensions/build_context_extension.dart';
