import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Riverpod-free loading / error / data tri-state for enterprise screens
/// (map from [AsyncValue] in the host via a small extension).
@immutable
sealed class NorthstarTriState<T> {
  const NorthstarTriState._();
}

@immutable
final class NorthstarTriLoading<T> extends NorthstarTriState<T> {
  const NorthstarTriLoading() : super._();
}

@immutable
final class NorthstarTriError<T> extends NorthstarTriState<T> {
  const NorthstarTriError(this.error, [this.stackTrace]) : super._();

  final Object error;
  final StackTrace? stackTrace;
}

@immutable
final class NorthstarTriData<T> extends NorthstarTriState<T> {
  const NorthstarTriData(this.value) : super._();

  final T value;
}

/// Renders one phase; keeps Material apps free of nested `when` boilerplate.
class NorthstarTriStateBody<T> extends StatelessWidget {
  const NorthstarTriStateBody({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final NorthstarTriState<T> state;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, Object error, StackTrace? st)?
      errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (state is NorthstarTriData<T>) {
      return dataBuilder(
        context,
        (state as NorthstarTriData<T>).value,
      );
    }
    if (state is NorthstarTriLoading<T>) {
      return loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }
    if (state is NorthstarTriError<T>) {
      final NorthstarTriError<T> err = state as NorthstarTriError<T>;
      return errorBuilder?.call(context, err.error, err.stackTrace) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(NorthstarSpacing.space24),
              child: Text('${err.error}'),
            ),
          );
    }
    return const SizedBox.shrink();
  }
}
