import '../../../../core/result/result.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/tasks_overview.dart';
import '../repositories/tasks_repository.dart';

class GetTasks extends UseCase<TasksOverview, NoParams> {
  const GetTasks(this._repository);

  final TasksRepository _repository;

  @override
  Future<Result<TasksOverview>> call(NoParams params) => _repository.getTasks();
}
