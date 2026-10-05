import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hiro_api/hiro_api.dart';

/// Push notifications through Firebase Cloud Messaging. Firebase needs the
/// platform config files (google-services.json, GoogleService-Info.plist);
/// without them push stays off and the rest of the app works.
class Push {
  Push._();
  static bool available = false;
  static String? _token;

  /// Called on app start; [open] handles taps on notifications with the
  /// app route to show (a ticket, or lessons).
  static Future<void> init(void Function(String route) open) async {
    try {
      await Firebase.initializeApp();
      available = true;
    } catch (e) {
      debugPrint('push disabled: $e');
      return;
    }
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(m, open));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _open(initial, open);
  }

  static void _open(RemoteMessage m, void Function(String route) open) {
    final route = m.data['route'];
    final key = m.data['ticket'];
    if (route is String && (route.startsWith('/tickets/') || route.startsWith('/learn'))) {
      open(route);
    } else if (key is String && key.isNotEmpty) {
      open('/tickets/$key');
    }
  }

  /// Asks permission and registers this device with the server.
  static Future<void> register(HiroApi api, String appVersion) async {
    if (!available) return;
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    _token = token;
    await _send(api, token, appVersion);
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      _token = t;
      unawaited(_send(api, t, appVersion));
    });
  }

  static Future<void> _send(HiroApi api, String token, String appVersion) async {
    try {
      await api.getDevicesApi().registerDevice(
            deviceRegistration: DeviceRegistration(
              platform: Platform.isIOS ? DeviceRegistrationPlatformEnum.ios : DeviceRegistrationPlatformEnum.android,
              fcmToken: token,
              appVersion: appVersion,
            ),
          );
    } catch (e) {
      debugPrint('register device: $e');
    }
  }

  /// Stops pushes to this phone (on sign-out).
  static Future<void> unregister(HiroApi api) async {
    final t = _token;
    if (t == null) return;
    try {
      await api.getDevicesApi().unregisterDevice(unregisterDeviceRequest: UnregisterDeviceRequest(fcmToken: t));
    } catch (_) {}
  }
}
