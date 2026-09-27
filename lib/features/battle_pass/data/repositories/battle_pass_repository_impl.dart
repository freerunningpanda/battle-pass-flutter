import '../../../../core/repositories/base_repository.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/season.dart';
import '../../domain/repositories/battle_pass_repository.dart';
import '../mock/battle_pass_mock_api.dart';
import '../models/season_model.dart';

/// Мок-реализация: сезон приходит из [BattlePassMockApi], а получение наград
/// считается локально — настоящий сервер вернул бы обновлённый сезон сам.
class BattlePassRepositoryImpl extends BaseRepository
    implements BattlePassRepository {
  BattlePassRepositoryImpl({required BattlePassMockApi mockApi})
    : _mockApi = mockApi;

  final BattlePassMockApi _mockApi;

  @override
  Future<Result<BattlePassSeason>> getSeason() => execute(
    () async => SeasonModel.fromJson(_mockApi.fetchSeason()),
    const Failure('Не удалось загрузить боевой пропуск'),
  );

  @override
  Future<Result<BattlePassSeason>> claimLevel(
    BattlePassSeason season,
    int levelNumber,
  ) => execute(
    () async => season.claimLevel(levelNumber),
    const Failure('Не удалось забрать награду'),
  );

  @override
  Future<Result<BattlePassSeason>> claimAllRewards(BattlePassSeason season) =>
      execute(
        () async => season.claimAll(),
        const Failure('Не удалось забрать награды'),
      );
}
