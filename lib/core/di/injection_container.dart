import 'package:get_it/get_it.dart';

import '../exports.dart';

final GetIt sl = GetIt.instance;

void initDependencyInjection() {
  sl.registerLazySingleton(DemoScenarioStore.new);
  _initBattlePass();
  _initTasks();
}

void _initBattlePass() {
  sl
    ..registerLazySingleton(() => BattlePassMockApi(scenario: sl()))
    ..registerLazySingleton<BattlePassRepository>(
      () => BattlePassRepositoryImpl(mockApi: sl()),
    )
    ..registerLazySingleton(() => GetSeason(sl()))
    ..registerLazySingleton(() => ClaimLevel(sl()))
    ..registerLazySingleton(() => ClaimAllRewards(sl()))
    ..registerFactory(
      () => BattlePassCubit(
        getSeason: sl(),
        claimLevel: sl(),
        claimAllRewards: sl(),
        demoScenario: sl(),
      ),
    );
}

void _initTasks() {
  sl
    ..registerLazySingleton(() => TasksMockApi(scenario: sl()))
    ..registerLazySingleton<TasksRepository>(
      () => TasksRepositoryImpl(mockApi: sl()),
    )
    ..registerLazySingleton(() => GetTasks(sl()))
    ..registerFactory(() => TasksCubit(getTasks: sl()));
}
