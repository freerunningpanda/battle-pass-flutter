import 'dart:developer' as developer;

import '../exports.dart';

abstract class BaseRepository {
  /// Выполняет [action] и заворачивает исключение в [failure]. Техническая
  /// причина уходит в лог, пользователю — только текст [failure].
  Future<Result<T>> execute<T>(
    Future<T> Function() action,
    Failure failure,
  ) async {
    try {
      return Result.success(await action());
    } catch (error, stackTrace) {
      developer.log(
        failure.message,
        name: runtimeType.toString(),
        error: error,
        stackTrace: stackTrace,
      );
      return Result.failure(failure);
    }
  }
}
