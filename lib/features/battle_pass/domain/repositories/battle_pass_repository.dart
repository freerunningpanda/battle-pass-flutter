import '../../../../core/result/result.dart';
import '../entities/season.dart';

abstract class BattlePassRepository {
  Future<Result<BattlePassSeason>> getSeason();

  /// Забирает награды уровня — см. [BattlePassSeason.claimLevel].
  Future<Result<BattlePassSeason>> claimLevel(
    BattlePassSeason season,
    int levelNumber,
  );

  Future<Result<BattlePassSeason>> claimAllRewards(BattlePassSeason season);
}
