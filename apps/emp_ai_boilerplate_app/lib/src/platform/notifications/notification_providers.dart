import 'package:emp_ai_boilerplate_app/src/config/boilerplate_experimental_flags.dart';
import 'package:emp_ai_boilerplate_app/src/platform/notifications/firebase_push_notification_port.dart';
import 'package:emp_ai_boilerplate_app/src/platform/notifications/flutter_local_notifications_port.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `ENABLE_LOCAL_NOTIFICATIONS=true` (non-web) uses [FlutterLocalNotificationsPort].
final localNotificationPortProvider = Provider<LocalNotificationPort>(
  (ref) {
    if (kBoilerplateEnableLocalNotifications && !kIsWeb) {
      return FlutterLocalNotificationsPort();
    }
    return const NoOpLocalNotificationPort();
  },
);

/// `ENABLE_FCM=true` with Firebase initialized uses [FirebasePushNotificationPort].
final pushNotificationPortProvider = Provider<PushNotificationPort>(
  (ref) {
    if (kBoilerplateEnableFcm) {
      return FirebasePushNotificationPort();
    }
    return const NoOpPushNotificationPort();
  },
);
