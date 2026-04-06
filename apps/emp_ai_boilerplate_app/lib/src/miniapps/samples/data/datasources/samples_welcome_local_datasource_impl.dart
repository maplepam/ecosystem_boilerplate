import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_welcome_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SharedPreferences]-backed cache for the samples welcome line.
final class SamplesWelcomeLocalDataSourceImpl
    implements SamplesWelcomeLocalDataSource {
  SamplesWelcomeLocalDataSourceImpl(this._prefs);

  static const String _key = 'samples_welcome_v1';

  final SharedPreferences _prefs;

  @override
  Future<String?> readWelcome() async => _prefs.getString(_key);

  @override
  Future<void> writeWelcome(String value) async {
    await _prefs.setString(_key, value);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
