import 'dart:convert';

import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_read_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AnnouncementsReadLocalDataSourceImpl
    implements AnnouncementsReadLocalDataSource {
  AnnouncementsReadLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'announcements_read_ids_v1';

  @override
  Future<Set<String>> readIds() async {
    final String? raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((dynamic e) => e.toString()).toSet();
    } on Object {
      return <String>{};
    }
  }

  @override
  Future<void> addReadId(String id) async {
    final Set<String> next = <String>{...await readIds(), id};
    await _prefs.setString(_key, jsonEncode(next.toList(growable: false)));
  }
}
