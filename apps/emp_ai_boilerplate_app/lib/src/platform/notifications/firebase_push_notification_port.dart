import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// [PushNotificationPort] using Firebase Cloud Messaging.
///
/// Call [initialize] after [Firebase.initializeApp]. [registerToken] is a
/// no-op hook for sending the token to your backend.
final class FirebasePushNotificationPort extends PushNotificationPort {
  @override
  Future<void> initialize() async {
    if (kIsWeb || Firebase.apps.isEmpty) {
      return;
    }
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await messaging.getToken();
    } on Object {
      // Missing entitlements / config.
    }
  }

  @override
  Stream<String>? get onTokenRefresh {
    if (kIsWeb || Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseMessaging.instance.onTokenRefresh;
  }

  @override
  Future<void> registerToken(String token) async {}
}
