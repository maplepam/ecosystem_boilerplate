import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/entities/sample_message.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';

/// Repository contract (domain). Implementation lives in `data/`.
abstract interface class SamplesRepository {
  Future<AppResult<SampleMessage>> loadWelcome();
}
