import 'package:equatable/equatable.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;

  factory Result.failure(Failure failure) = ResultFailure<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success(:final data) => onSuccess(data),
    ResultFailure(:final failure) => onFailure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}

/// Ошибка, пригодная для показа пользователю.
class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
