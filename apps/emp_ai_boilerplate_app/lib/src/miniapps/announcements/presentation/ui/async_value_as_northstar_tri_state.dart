import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueNorthstarTriX<T> on AsyncValue<T> {
  NorthstarTriState<T> get asNorthstarTriState {
    return when(
      data: (T v) => NorthstarTriData<T>(v),
      error: (Object e, StackTrace st) => NorthstarTriError<T>(e, st),
      loading: () => NorthstarTriLoading<T>(),
    );
  }
}
