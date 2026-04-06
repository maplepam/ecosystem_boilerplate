import 'dart:async';

import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// [AnalyticsSink] backed by Mixpanel (project token from host resolution).
final class MixpanelAnalyticsSink extends AnalyticsSink {
  // ignore: prefer_const_constructors_in_immutables — holds live [Mixpanel].
  MixpanelAnalyticsSink(this._mixpanel);

  final Mixpanel _mixpanel;

  @override
  void track(String eventName, [Map<String, Object?>? properties]) {
    unawaited(
      _mixpanel.track(
        eventName,
        properties: _toDynamicMap(properties),
      ),
    );
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object?>? traits,
  }) async {
    await _mixpanel.identify(userId);
    final People people = _mixpanel.getPeople();
    if (traits == null) {
      return;
    }
    for (final MapEntry<String, Object?> e in traits.entries) {
      people.set(e.key, e.value);
    }
  }

  @override
  Future<void> reset() async {
    await _mixpanel.reset();
  }

  @override
  void setUserProperty(String key, Object? value) {
    _mixpanel.getPeople().set(key, value);
  }

  static Map<String, dynamic>? _toDynamicMap(Map<String, Object?>? properties) {
    if (properties == null) {
      return null;
    }
    return properties.map(
      (String k, Object? v) => MapEntry<String, dynamic>(k, v),
    );
  }
}
