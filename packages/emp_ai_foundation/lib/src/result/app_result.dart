import 'package:meta/meta.dart';

/// Typed result for use cases and repositories — mirrors common `Either` usage
/// without pulling `dartz` into foundation consumers.
///
/// Hosts may map [AppFailure] to UI ([AsyncValue], snackbars) or logging.
@immutable
sealed class AppResult<T> {
  const AppResult._();
}

@immutable
final class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.value) : super._();

  final T value;
}

/// Implements [Exception] so [AsyncValue.guard] and `throw` paths stay simple.
@immutable
final class AppFailure<T> extends AppResult<T> implements Exception {
  const AppFailure({
    required this.code,
    this.message,
    this.cause,
  }) : super._();

  /// Stable machine-readable code, e.g. `network`, `samples_load`.
  final String code;

  final String? message;

  final Object? cause;

  @override
  String toString() =>
      'AppFailure($code${message != null ? ': $message' : ''})';
}

extension AppResultX<T> on AppResult<T> {
  bool get isSuccess => this is AppSuccess<T>;

  bool get isFailure => this is AppFailure<T>;

  T? get valueOrNull => switch (this) {
        AppSuccess(:final value) => value,
        AppFailure() => null,
      };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure<T> failure) onFailure,
  }) {
    return switch (this) {
      AppSuccess(:final value) => onSuccess(value),
      final AppFailure<T> f => onFailure(f),
    };
  }
}
