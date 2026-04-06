import 'dart:async';

import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// [AnalyticsSink] backed by Firebase Analytics (requires [Firebase.initializeApp]).
final class FirebaseAnalyticsSink extends AnalyticsSink {
  // ignore: prefer_const_constructors_in_immutables — holds [FirebaseAnalytics].
  FirebaseAnalyticsSink(this._analytics);

  final FirebaseAnalytics _analytics;

  static final RegExp _nonEventChars = RegExp(r'[^a-zA-Z0-9_]');

  @override
  void track(String eventName, [Map<String, Object?>? properties]) {
    unawaited(_safeLogEvent(eventName, properties));
  }

  Future<void> _safeLogEvent(
    String eventName,
    Map<String, Object?>? properties,
  ) async {
    try {
      await _analytics.logEvent(
        name: _sanitizeEventName(eventName),
        parameters: _firebaseParameters(properties),
      );
    } on Object {
      // Invalid event name / parameter shape — avoid crashing the app.
    }
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object?>? traits,
  }) async {
    await _analytics.setUserId(id: userId);
    if (traits == null) {
      return;
    }
    for (final MapEntry<String, Object?> e in traits.entries) {
      final String? name = _sanitizeUserPropertyName(e.key);
      if (name == null) {
        continue;
      }
      try {
        await _analytics.setUserProperty(
          name: name,
          value: e.value?.toString(),
        );
      } on Object {
        // Invalid name per Firebase rules.
      }
    }
  }

  @override
  Future<void> reset() async {
    await _analytics.setUserId(id: null);
    await _analytics.resetAnalyticsData();
  }

  @override
  void setUserProperty(String key, Object? value) {
    final String? name = _sanitizeUserPropertyName(key);
    if (name == null) {
      return;
    }
    unawaited(
      _analytics.setUserProperty(name: name, value: value?.toString()),
    );
  }

  static String _sanitizeEventName(String raw) {
    var name = raw
        .toLowerCase()
        .replaceAll(_nonEventChars, '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (name.startsWith('firebase_')) {
      name = 'evt_$name';
    }
    if (name.isEmpty) {
      name = 'event';
    }
    const int maxLen = 40;
    return name.length > maxLen ? name.substring(0, maxLen) : name;
  }

  static String? _sanitizeUserPropertyName(String raw) {
    var name = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (name.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[a-zA-Z]').hasMatch(name)) {
      name = 'p_$name';
    }
    if (name.length > 24) {
      name = name.substring(0, 24);
    }
    if (name.startsWith('firebase_')) {
      return null;
    }
    return name;
  }

  static Map<String, Object>? _firebaseParameters(Map<String, Object?>? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, Object> out = <String, Object>{};
    for (final MapEntry<String, Object?> e in raw.entries) {
      final Object? v = e.value;
      if (v == null) {
        continue;
      }
      if (v is String || v is num || v is bool) {
        out[e.key] = v;
      } else {
        out[e.key] = v.toString();
      }
    }
    return out.isEmpty ? null : out;
  }
}
