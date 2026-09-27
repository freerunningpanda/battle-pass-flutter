import '../../../../core/demo/demo_scenario.dart';

/// Мок заданий: один таск для тизера на главном экране (экран "Задания" —
/// заглушка, см. README).
class TasksMockApi {
  TasksMockApi({required DemoScenarioStore scenario}) : _scenario = scenario;

  final DemoScenarioStore _scenario;

  Map<String, dynamic> fetchTasks() {
    switch (_scenario.current) {
      case BattlePassScenario.premiumLocked:
        return _overview(premiumOwned: false, task: _activeTask);
      case BattlePassScenario.premiumUnlockedWithReward:
      case BattlePassScenario.premiumUnlockedNoReward:
      case BattlePassScenario.maxLevelNoReward:
      case BattlePassScenario.rewardsEndedPremiumOwned:
        return _overview(premiumOwned: true, task: _completedRewardTask);
      case BattlePassScenario.rewardsEndedPremiumNotOwned:
        return _overview(premiumOwned: false, task: _completedRewardTask);
      case BattlePassScenario.maxLevel:
        // Свой таск, забирается прямо с тизера.
        return _overview(premiumOwned: true, task: _classicModeTask);
      case BattlePassScenario.completed:
        return _overview(premiumOwned: true, task: _completedRewardTask);
    }
  }

  Map<String, dynamic> _overview({
    required bool premiumOwned,
    required Map<String, dynamic> task,
  }) => {
    'premium_owned': premiumOwned,
    'premium_xp_buff_active': false,
    'tasks': <Map<String, dynamic>>[task],
  };

  static const _activeTask = {
    'id': 1,
    'title': 'Используйте определенный предмет (Энергетик) 10 раз.',
    'progress_current': 3,
    'progress_target': 5,
    'reward_xp': 25,
    'completed': false,
    'claimed': false,
  };

  static const _completedRewardTask = {
    'id': 1,
    'title': 'Используйте определенный предмет (Энергетик) 10 раз.',
    'progress_current': 5,
    'progress_target': 5,
    'reward_xp': 100,
    'completed': true,
    'claimed': false,
  };

  static const _classicModeTask = {
    'id': 1,
    'title':
        'Используйте определенный предмет (Энергетик) 10 раз в '
        'классическом режиме.',
    'progress_current': 5,
    'progress_target': 5,
    'reward_xp': 250,
    'completed': true,
    'claimed': false,
  };
}
