import 'package:meta/meta.dart';

/// Local (scheduled / foreground) alerts — implement with
/// `flutter_local_notifications` in the host. Opt out: use [NoOpLocalNotificationPort].
@immutable
abstract class LocalNotificationPort {
  const LocalNotificationPort();

  Future<void> initialize();

  Future<void> show({
    required String title,
    String? body,
    String? payload,
  });

  Future<void> cancelAll();
}

/// Push (FCM / APNs) — implement in host after platform setup.
/// Opt out: [NoOpPushNotificationPort].
@immutable
abstract class PushNotificationPort {
  const PushNotificationPort();

  Future<void> initialize();

  /// Call when FCM gives a token; no-op for hosts without push.
  Future<void> registerToken(String token);

  Stream<String>? get onTokenRefresh;
}

final class NoOpLocalNotificationPort extends LocalNotificationPort {
  const NoOpLocalNotificationPort();

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> show({
    required String title,
    String? body,
    String? payload,
  }) async {}
}

final class NoOpPushNotificationPort extends PushNotificationPort {
  const NoOpPushNotificationPort();

  @override
  Future<void> initialize() async {}

  @override
  Stream<String>? get onTokenRefresh => null;

  @override
  Future<void> registerToken(String token) async {}
}
