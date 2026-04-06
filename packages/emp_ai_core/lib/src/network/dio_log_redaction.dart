import 'dart:convert';

/// Masks values for debug HTTP logging (never log raw bearer tokens or refresh tokens).
abstract final class DioLogRedaction {
  const DioLogRedaction._();

  static const Set<String> sensitiveHeaderKeys = <String>{
    'authorization',
  };

  /// Keys commonly used in OAuth / token payloads and introspection bodies.
  static const Set<String> sensitiveMapKeys = <String>{
    'refresh_token',
    'access_token',
    'id_token',
    'password',
    'client_secret',
    'token',
  };

  static Map<String, Object?> maskHeaders(Map<String, dynamic> headers) {
    return headers.map((String k, dynamic v) {
      if (sensitiveHeaderKeys.contains(k.toLowerCase())) {
        return MapEntry<String, Object?>(k, _maskAuthorizationValue(v));
      }
      return MapEntry<String, Object?>(k, v);
    });
  }

  static String _maskAuthorizationValue(Object? v) {
    final String s = v?.toString() ?? '';
    if (s.isEmpty) {
      return '<redacted>';
    }
    if (s.toLowerCase().startsWith('bearer ')) {
      return 'Bearer <redacted>';
    }
    return '<redacted>';
  }

  /// Deep-redacts maps/lists, JSON strings, and standalone JWT-shaped strings.
  static dynamic redactPayload(dynamic data) {
    if (data == null) {
      return data;
    }
    if (data is Map) {
      return data.map((dynamic k, dynamic v) {
        final String ks = k.toString().toLowerCase();
        if (sensitiveMapKeys.contains(ks)) {
          return MapEntry<dynamic, dynamic>(k, '<redacted>');
        }
        return MapEntry<dynamic, dynamic>(k, redactPayload(v));
      });
    }
    if (data is List) {
      return data.map(redactPayload).toList();
    }
    if (data is String) {
      if (_looksLikeCompactJwt(data)) {
        return '<redacted:jwt>';
      }
      try {
        final Object? decoded = jsonDecode(data);
        if (decoded is Map || decoded is List) {
          return jsonEncode(redactPayload(decoded));
        }
      } on Object {
        // not JSON
      }
      return data;
    }
    return data;
  }

  static bool _looksLikeCompactJwt(String s) {
    if (s.length < 40 || !s.contains('.')) {
      return false;
    }
    final List<String> parts = s.split('.');
    if (parts.length < 3) {
      return false;
    }
    return parts.every((String p) => p.length >= 4);
  }
}
