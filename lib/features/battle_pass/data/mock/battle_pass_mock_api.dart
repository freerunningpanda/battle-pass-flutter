import '../../../../core/demo/demo_scenario.dart';

typedef _Icon = ({String icon, int amount});

/// Данные одного сценария: всё, что не укладывается в общие правила
/// [BattlePassMockApi._buildSeason], задано точечными оверрайдами по Figma.
typedef _ScenarioData = ({
  int currentLevel,
  bool premiumOwned,
  bool allClaimed,
  Set<int> claimableLevels,
  Set<int> claimedLevels,
  Map<int, _Icon> icons,
  Map<int, String> rarities,
});

/// Мок "сервера": отдаёт JSON-подобные Map под текущий сценарий экрана,
/// чтобы Model.fromJson реально разбирал данные, а не просто оборачивал
/// Dart-объекты.
class BattlePassMockApi {
  BattlePassMockApi({required DemoScenarioStore scenario})
    : _scenario = scenario;

  final DemoScenarioStore _scenario;

  /// Один дедлайн на сессию — таймер не сбрасывается при смене сценария.
  final _seasonEndsAt = DateTime.now().add(
    const Duration(days: 15, hours: 12, minutes: 42),
  );

  static const _maxLevel = 100;
  static const _images = 'assets/images/battle_pass';

  static const _rewardIcons = [
    '$_images/reward_lollipop.png',
    '$_images/reward_passport.png',
    '$_images/reward_mask_devil.png',
    '$_images/reward_mask_ghost.png',
  ];

  static _Icon _icon(String name, [int amount = 1]) =>
      (icon: '$_images/$name.png', amount: amount);

  /// Уровни 6–8, общие для большинства сценариев.
  static final _monsters = {
    6: _icon('blue_devil'),
    7: _icon('green_monster'),
    8: _icon('bull'),
  };

  static const _epic6to8 = {6: 'epic', 7: 'epic', 8: 'epic'};

  static final _withRewardIcons = {
    5: _icon('premium_teaser_bag'),
    6: _icon('filter'),
    7: _icon('blue_devil'),
    8: _icon('green_monster'),
  };

  static final _noRewardIcons = {
    4: _icon('reward_mask_ghost'),
    5: _icon('premium_teaser_bag'),
    ..._monsters,
  };

  static const _noRewardRarities = {4: 'common', 5: 'common', ..._epic6to8};

  static _ScenarioData _rewardsEnded({required bool premiumOwned}) => _data(
    currentLevel: 12,
    premiumOwned: premiumOwned,
    claimableLevels: const {4, 5, 6, 7, 8, 95, 96, 97, 98, 99, 100},
    icons: {
      ..._withRewardIcons,
      4: _icon('bullets', 16),
      95: _icon('reward_mask_ghost'),
      96: _icon('premium_teaser_bag'),
      97: _icon('bullets'),
      98: _icon('blue_devil'),
      99: _icon('green_monster'),
      100: _icon('bull'),
    },
    rarities: const {
      5: 'common',
      ..._epic6to8,
      95: 'common',
      96: 'common',
      97: 'common',
      98: 'epic',
      99: 'epic',
      100: 'legendary',
    },
  );

  static final Map<BattlePassScenario, _ScenarioData> _scenarios = {
    BattlePassScenario.premiumLocked: _data(
      currentLevel: 5,
      premiumOwned: false,
    ),
    BattlePassScenario.premiumUnlockedWithReward: _data(
      currentLevel: 12,
      // По Figma 4–8 не забраны — вопреки правилу "claimable только 3
      // уровня перед текущим".
      claimableLevels: const {4, 5, 6, 7, 8},
      icons: {..._withRewardIcons, 4: _icon('boss', 16)},
      rarities: const {5: 'common', ..._epic6to8},
    ),
    BattlePassScenario.premiumUnlockedNoReward: _data(
      currentLevel: 12,
      claimableLevels: const {5, 6, 7, 8},
      // Юбилейный 10-й уже забран.
      claimedLevels: const {10},
      icons: _noRewardIcons,
      rarities: _noRewardRarities,
    ),
    BattlePassScenario.maxLevel: _data(
      currentLevel: _maxLevel,
      claimableLevels: const {4, 5},
      icons: {
        ..._noRewardIcons,
        4: _icon('reward_mask_ghost', 16),
        5: _icon('premium_teaser_bag', 16),
      },
      rarities: const {5: 'common', ..._epic6to8},
    ),
    BattlePassScenario.maxLevelNoReward: _data(
      currentLevel: _maxLevel,
      allClaimed: true,
      icons: _noRewardIcons,
      rarities: _noRewardRarities,
    ),
    BattlePassScenario.completed: _data(
      currentLevel: 12,
      // Итоговое сообщение зовёт забрать оставшиеся награды — они есть.
      claimableLevels: const {4, 5, 6, 7, 8},
      icons: {..._noRewardIcons, 4: _icon('reward_mask_ghost', 16)},
      rarities: const {5: 'common', ..._epic6to8},
    ),
    BattlePassScenario.rewardsEndedPremiumOwned: _rewardsEnded(
      premiumOwned: true,
    ),
    BattlePassScenario.rewardsEndedPremiumNotOwned: _rewardsEnded(
      premiumOwned: false,
    ),
  };

  static _ScenarioData _data({
    required int currentLevel,
    bool premiumOwned = true,
    bool allClaimed = false,
    Set<int> claimableLevels = const {},
    Set<int> claimedLevels = const {},
    Map<int, _Icon> icons = const {},
    Map<int, String> rarities = const {},
  }) => (
    currentLevel: currentLevel,
    premiumOwned: premiumOwned,
    allClaimed: allClaimed,
    claimableLevels: claimableLevels,
    claimedLevels: claimedLevels,
    icons: icons,
    rarities: rarities,
  );

  Map<String, dynamic> fetchSeason() =>
      _buildSeason(_scenarios[_scenario.current]!);

  Map<String, dynamic> _buildSeason(_ScenarioData data) {
    final currentLevel = data.currentLevel;
    final levels = List.generate(_maxLevel, (index) {
      final number = index + 1;
      final state = _levelState(number, data);
      final claimed = state == 'claimed';
      final rarity = data.rarities[number] ?? _rarityFor(number);
      // Премиум-награда есть только на уровнях с редким бесплатным
      // предметом — именно они "продают" апгрейд.
      final hasPremiumTier = rarity != 'common';
      return {
        'number': number,
        'required_xp': number * 1000,
        'state': state,
        'free_reward': _reward(
          number,
          premium: false,
          claimed: claimed,
          icon: data.icons[number],
          rarity: data.rarities[number],
        ),
        'premium_reward': hasPremiumTier
            ? _reward(
                number,
                premium: true,
                claimed: data.premiumOwned && claimed,
              )
            : null,
      };
    });

    return {
      'season_id': 1,
      'season_name': 'Сезон «Экспедиция»',
      'premium_owned': data.premiumOwned,
      'current_level': currentLevel,
      // Текущий уровень ещё не пройден — опыта чуть меньше его порога; на
      // максимальном копить дальше нечего, он пройден полностью.
      'current_xp': currentLevel >= _maxLevel
          ? currentLevel * 1000
          : currentLevel * 1000 - 450,
      'max_level': _maxLevel,
      'levels': levels,
      'season_ends_at_ms': _seasonEndsAt.millisecondsSinceEpoch,
    };
  }

  /// Оверрайды сценария важнее общих правил: так, 95–100 в "Конец наград"
  /// доступны, хотя выше текущего уровня.
  String _levelState(int number, _ScenarioData data) {
    if (data.allClaimed || data.claimedLevels.contains(number)) {
      return 'claimed';
    }
    if (data.claimableLevels.contains(number)) return 'claimable';
    if (number > data.currentLevel) return 'locked';
    if (number == data.currentLevel) return 'current';
    return data.currentLevel - number <= 3 ? 'claimable' : 'claimed';
  }

  String _rarityFor(int level) => level % 10 == 0
      ? 'legendary'
      : level % 5 == 0
      ? 'epic'
      : level % 3 == 0
      ? 'rare'
      : 'common';

  Map<String, dynamic> _reward(
    int level, {
    required bool premium,
    required bool claimed,
    _Icon? icon,
    String? rarity,
  }) {
    final iconIndex = (level - 1) % _rewardIcons.length;
    // Количество (×N) по умолчанию только у леденца.
    final isLollipop = iconIndex == 0;
    return {
      'id': level * 10 + (premium ? 1 : 0),
      'name': premium ? 'Премиум-награда $level ур.' : 'Награда $level ур.',
      'icon_asset':
          icon?.icon ??
          (level == 10 ? '$_images/case_audi.png' : _rewardIcons[iconIndex]),
      'amount': icon?.amount ?? (premium ? 50 : (isLollipop ? 16 : 1)),
      'rarity': rarity ?? _rarityFor(level),
      'claimed': claimed,
    };
  }
}
