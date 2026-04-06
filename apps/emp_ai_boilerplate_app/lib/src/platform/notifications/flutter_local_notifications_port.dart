import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// [LocalNotificationPort] using [FlutterLocalNotificationsPlugin].
final class FlutterLocalNotificationsPort extends LocalNotificationPort {
  static const String _androidChannelId = 'boilerplate_default';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    _androidChannelId,
    'Boilerplate',
    description: 'Sample local notifications',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  late final Future<void> _ready = _bootstrap();

  Future<void> _bootstrap() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  @override
  Future<void> initialize() => _ready;

  @override
  Future<void> show({
    required String title,
    String? body,
    String? payload,
  }) async {
    await _ready;
    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: title.hashCode & 0x7fffffff,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  @override
  Future<void> cancelAll() async {
    await _ready;
    await _plugin.cancelAll();
  }
}
