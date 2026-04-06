import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_welcome_local_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/entities/sample_message.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/repositories/samples_repository.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';

final class SamplesRepositoryImpl implements SamplesRepository {
  const SamplesRepositoryImpl(this._remote, this._local);

  final SamplesRemoteDataSource _remote;
  final SamplesWelcomeLocalDataSource _local;

  @override
  Future<AppResult<SampleMessage>> loadWelcome() async {
    try {
      final String? cached = await _local.readWelcome();
      if (cached != null && cached.isNotEmpty) {
        return AppSuccess(SampleMessage(cached));
      }
      final String text = await _remote.fetchWelcomeMessage();
      await _local.writeWelcome(text);
      return AppSuccess(SampleMessage(text));
    } on Object catch (e, _) {
      return AppFailure(
        code: 'samples_load',
        message: e.toString(),
        cause: e,
      );
    }
  }
}
