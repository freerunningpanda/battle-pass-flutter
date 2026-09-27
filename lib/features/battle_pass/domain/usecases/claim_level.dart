import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/season.dart';
import '../repositories/battle_pass_repository.dart';

class ClaimLevelParams extends Equatable {
  const ClaimLevelParams({required this.season, required this.levelNumber});

  final BattlePassSeason season;
  final int levelNumber;

  @override
  List<Object?> get props => [season, levelNumber];
}

class ClaimLevel extends UseCase<BattlePassSeason, ClaimLevelParams> {
  const ClaimLevel(this._repository);

  final BattlePassRepository _repository;

  @override
  Future<Result<BattlePassSeason>> call(ClaimLevelParams params) =>
      _repository.claimLevel(params.season, params.levelNumber);
}
