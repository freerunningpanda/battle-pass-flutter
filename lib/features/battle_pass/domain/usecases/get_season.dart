import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/season.dart';
import '../repositories/battle_pass_repository.dart';

class GetSeason extends UseCase<BattlePassSeason, NoParams> {
  const GetSeason(this._repository);

  final BattlePassRepository _repository;

  @override
  Future<Result<BattlePassSeason>> call(NoParams params) =>
      _repository.getSeason();
}
