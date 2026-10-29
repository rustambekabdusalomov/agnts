import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:agnts_api/agnts_api.dart';

/// Push notifications through Firebase Cloud Messaging. Firebase needs the
/// platform config files (google-services.json, GoogleService-Info.plist);
/// without them push stays off and the rest of the app works.
class Push {
  Push._();
  static bool available = false;
  static String? _token;
  static final _local = FlutterLocalNotificationsPlugin();

  // Android channels the server names in its pushes: everything that needs
  // a look, and the silent steps of a running ticket.
  static const _channel = AndroidNotificationChannel(
    'agnts',
    'Tickets',
    description: 'Questions, reviews, failures and pushed changes',
    importance: Importance.high,
  );
  static const _quietChannel = AndroidNotificationChannel(
    'agnts_progress',
    'Ticket progress',
    description: 'An agent finished a step',
    importance: Importance.low,
    playSound: false,
    enableVibration: false,
  );

  /// Called on app start; [open] handles taps on notifications with the
  /// app route to show (a ticket, lessons, or a CI failure) and the id of
  /// the workspace it is in (0 when the server did not say). [showing]
  /// says whether a route is on screen now: a push about it is not shown.
  static Future<void> init(void Function(String route, int workspace) open, {bool Function(String route)? showing}) async {
    try {
      await Firebase.initializeApp();
      available = true;
    } catch (e) {
      debugPrint('push disabled: $e');
      return;
    }
    await _initLocal(open);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(m.data, open));
    // The system shows nothing while the app is open: we do, the same way.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions();
    FirebaseMessaging.onMessage.listen((m) => _showOpen(m, showing));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _open(initial.data, open);
  }

  static Future<void> _initLocal(void Function(String route, int workspace) open) async {
    try {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permission is asked for once, by Firebase in register.
          iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
        ),
        onDidReceiveNotificationResponse: (r) {
          final p = r.payload;
          if (p == null || p.isEmpty) return;
          try {
            _open(Map<String, dynamic>.from(jsonDecode(p) as Map), open);
          } catch (_) {}
        },
      );
      final android = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_channel);
      await android?.createNotificationChannel(_quietChannel);
    } catch (e) {
      debugPrint('local notifications: $e');
    }
  }

  /// Shows a push that arrived while the app is open, unless its screen
  /// is the one on show. One per tag: a ticket's next step replaces the last.
  static Future<void> _showOpen(RemoteMessage m, bool Function(String route)? showing) async {
    final n = m.notification;
    if (n == null) return;
    final route = _route(m.data);
    if (route != null && showing != null && showing(route)) return;
    final tag = '${m.data['tag'] ?? ''}';
    final quiet = m.data['quiet'] == 'true';
    final ch = quiet ? _quietChannel : _channel;
    final ticket = '${m.data['ticket'] ?? ''}';
    await _local.show(
      id: tag.isNotEmpty ? tag.hashCode : m.hashCode,
      title: n.title,
      body: n.body,
      payload: jsonEncode(m.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          ch.id,
          ch.name,
          channelDescription: ch.description,
          importance: ch.importance,
          priority: quiet ? Priority.low : Priority.high,
          playSound: !quiet,
          tag: tag.isEmpty ? null : tag,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: !quiet,
          threadIdentifier: ticket.isEmpty ? null : ticket,
          interruptionLevel: quiet ? InterruptionLevel.passive : InterruptionLevel.active,
        ),
      ),
    );
  }

  static void _open(Map<String, dynamic> data, void Function(String route, int workspace) open) {
    final route = _route(data);
    if (route != null) open(route, int.tryParse('${data['workspace'] ?? ''}') ?? 0);
  }

  /// The app route a push opens: its own (a ticket, lessons, a CI
  /// failure, or a meeting's call), else its ticket's.
  static String? _route(Map<String, dynamic> data) {
    final route = data['route'];
    final key = data['ticket'];
    if (route is String &&
        (route.startsWith('/tickets/') || route.startsWith('/learn') || route.startsWith('/ci/') || route.startsWith('/m/'))) {
      return route;
    }
    if (key is String && key.isNotEmpty) return '/tickets/$key';
    return null;
  }

  /// Asks permission and registers this device with the server.
  static Future<void> register(AgntsApi api, String appVersion) async {
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

  static Future<void> _send(AgntsApi api, String token, String appVersion) async {
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
  static Future<void> unregister(AgntsApi api) async {
    final t = _token;
    if (t == null) return;
    try {
      await api.getDevicesApi().unregisterDevice(unregisterDeviceRequest: UnregisterDeviceRequest(fcmToken: t));
    } catch (_) {}
  }
}
