import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/repositories/announcement_media_repository.dart';

/// HTTP implementation with in-memory cache (per repository instance).
final class AnnouncementMediaRepositoryImpl implements AnnouncementMediaRepository {
  AnnouncementMediaRepositoryImpl(
    this._dio, {
    required String announcementServiceBaseUrl,
  }) : _baseUrl = announcementServiceBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  final Dio _dio;
  final String _baseUrl;

  final Map<String, String?> _cache = <String, String?>{};

  @override
  Future<Map<String, String?>> resolveAssetUrls(Iterable<String> assetKeys) async {
    final List<String> keys = assetKeys
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (keys.isEmpty || _baseUrl.isEmpty) {
      return <String, String?>{};
    }

    final List<String> missing = <String>[];
    for (final String k in keys) {
      if (!_cache.containsKey(k)) {
        missing.add(k);
      }
    }

    if (missing.isNotEmpty) {
      try {
        final Response<dynamic> res = await _dio.post<dynamic>(
          '$_baseUrl/media/assets/files',
          data: <String, dynamic>{'asset_keys': missing},
        );
        final List<Map<String, dynamic>> rows = _extractAssetRows(res.data);
        final Map<String, String?> found = <String, String?>{};
        for (final Map<String, dynamic> row in rows) {
          final String? key = _readString(row, const <String>['asset_key', 'assetKey']);
          final String? url = _pickAssetUrl(row);
          if (key != null && key.isNotEmpty) {
            found[key] = url;
          }
        }
        for (int i = 0; i < missing.length && i < rows.length; i++) {
          final String k = missing[i];
          found.putIfAbsent(k, () => _pickAssetUrl(rows[i]));
        }
        for (final String k in missing) {
          _cache[k] = found[k];
        }
      } on Object {
        for (final String k in missing) {
          _cache[k] = null;
        }
      }
    }

    return <String, String?>{
      for (final String k in keys) k: _cache[k],
    };
  }
}

List<Map<String, dynamic>> _extractAssetRows(dynamic raw) {
  final Object? decoded = _decodeIfNeeded(raw);
  if (decoded is! Map) {
    return <Map<String, dynamic>>[];
  }
  final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
  final Object? sc = map['status_code'];
  if (sc is int && sc != 200 && sc != 201) {
    return <Map<String, dynamic>>[];
  }
  final Object? data = map['data'];
  if (data is! List<dynamic>) {
    return <Map<String, dynamic>>[];
  }
  return data
      .map((dynamic e) {
        if (e is Map<String, dynamic>) {
          return e;
        }
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{};
      })
      .where((Map<String, dynamic> m) => m.isNotEmpty)
      .toList(growable: false);
}

Object? _decodeIfNeeded(dynamic raw) {
  if (raw is String) {
    return jsonDecode(raw);
  }
  return raw;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final String k in keys) {
    final Object? v = json[k];
    if (v == null) {
      continue;
    }
    final String s = v is String ? v : v.toString();
    final String t = s.trim();
    if (t.isNotEmpty) {
      return t;
    }
  }
  return null;
}

String? _pickAssetUrl(Map<String, dynamic> row) {
  for (final String k in const <String>[
    'asset_uri',
    'assetUri',
    'signed_url',
    'signedUrl',
    'file_url',
    'fileUrl',
    'url',
  ]) {
    final String? s = _readString(row, <String>[k]);
    if (s != null && s.startsWith('http')) {
      return s;
    }
  }
  final String? id = _readString(row, const <String>['asset_id', 'assetId']);
  if (id != null && id.startsWith('http')) {
    return id;
  }
  return id;
}
