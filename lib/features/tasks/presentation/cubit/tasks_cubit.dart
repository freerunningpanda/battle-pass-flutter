import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../exports.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit({required GetTasks getTasks})
    : _getTasks = getTasks,
      super(const TasksLoading()) {
    load();
  }

  final GetTasks _getTasks;

  /// Без промежуточного [TasksLoading] — старый таск остаётся на экране до
  /// прихода нового.
  Future<void> load() async {
    final result = await _getTasks(const NoParams());
    emit(
      result.fold(
        onSuccess: TasksLoaded.new,
        onFailure: (failure) => TasksError(failure.message),
      ),
    );
  }

  /// Мок-получение опыта за задание: помечает таск полученным.
  void claimTaskXp(int taskId) {
    final current = state;
    if (current is! TasksLoaded) return;
    final tasks = current.overview.tasks
        .map((task) => task.id == taskId ? task.copyWith(claimed: true) : task)
        .toList(growable: false);
    emit(
      TasksLoaded(
        TasksOverview(
          premiumOwned: current.overview.premiumOwned,
          premiumXpBuffActive: current.overview.premiumXpBuffActive,
          tasks: tasks,
        ),
      ),
    );
  }
}
