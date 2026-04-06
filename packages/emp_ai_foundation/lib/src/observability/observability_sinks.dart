import 'package:meta/meta.dart';

/// Product analytics — implement with Mixpanel, Firebase Analytics, Segment,
/// etc. Defaults for [identify] / [reset] are no-ops so single-backend sinks
/// only override [track] if needed.
@immutable
abstract class AnalyticsSink {
  const AnalyticsSink();

  void track(String eventName, [Map<String, Object?>? properties]);

  Future<void> identify(
    String userId, {
    Map<String, Object?>? traits,
  }) async {}

  Future<void> reset() async {}

  void setUserProperty(String key, Object? value) {}
}

/// Fan-out to many sinks (e.g. Mixpanel + Firebase + internal logging).
@immutable
final class CompositeAnalyticsSink extends AnalyticsSink {
  const CompositeAnalyticsSink(this.sinks);

  final List<AnalyticsSink> sinks;

  @override
  void track(String eventName, [Map<String, Object?>? properties]) {
    for (final AnalyticsSink s in sinks) {
      s.track(eventName, properties);
    }
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object?>? traits,
  }) async {
    for (final AnalyticsSink s in sinks) {
      await s.identify(userId, traits: traits);
    }
  }

  @override
  Future<void> reset() async {
    for (final AnalyticsSink s in sinks) {
      await s.reset();
    }
  }

  @override
  void setUserProperty(String key, Object? value) {
    for (final AnalyticsSink s in sinks) {
      s.setUserProperty(key, value);
    }
  }
}

/// Crash / error reporting — implement with Crashlytics, Sentry, etc.
@immutable
abstract class CrashReportingSink {
  const CrashReportingSink();

  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  void log(String message);
}

/// Default no-op; override in host [Provider] for production.
final class NoOpAnalyticsSink extends AnalyticsSink {
  const NoOpAnalyticsSink();

  @override
  void track(String eventName, [Map<String, Object?>? properties]) {}
}

/// Debug / console — safe default for dev builds.
final class DebugPrintAnalyticsSink extends AnalyticsSink {
  const DebugPrintAnalyticsSink();

  @override
  void track(String eventName, [Map<String, Object?>? properties]) {
    // ignore: avoid_print
    print('[analytics] $eventName ${properties ?? {}}');
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object?>? traits,
  }) async {
    // ignore: avoid_print
    print('[analytics] identify $userId traits=$traits');
  }

  @override
  Future<void> reset() async {
    // ignore: avoid_print
    print('[analytics] reset');
  }
}

final class NoOpCrashReportingSink extends CrashReportingSink {
  const NoOpCrashReportingSink();

  @override
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {}

  @override
  void log(String message) {}
}
