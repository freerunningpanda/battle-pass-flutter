import '../../../../core/result/result.dart';
import '../entities/tasks_overview.dart';

abstract class TasksRepository {
  Future<Result<TasksOverview>> getTasks();
}
