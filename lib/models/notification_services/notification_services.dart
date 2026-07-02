import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static String baseUrl = Global.BaseUrl;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.max,
  );

  static Future<void> init() async {
    // ✅ Android 13+ + iOS permission (FCM handles it)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // iOS foreground banners/sound
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ local notifications init (v17+)
    const androidInit = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: androidInit);

    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        // handle tap if needed
      },
    );

    // ✅ create Android channel
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // ✅ FOREGROUND: show local notif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';
      await _showLocal(title: title, body: body, data: message.data);
    });

    // Tap-to-open navigation is handled by NotificationRouter (see
    // notification_route.dart) — no listener needed here.

    // ✅ token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await registerTokenIfLoggedIn(tokenOverride: newToken);
    });
  }

  static Future<void> _showLocal({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
        color: const Color(0xFFDB9F3A), // Gold color from logo
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
    );

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(data ?? {}),
    );
  }

  static Future<void> registerTokenIfLoggedIn({String? tokenOverride}) async {
    final userId = await LocalStorage.getUserId();
    if (userId == null || userId.isEmpty) return;

    final token = tokenOverride ?? await _fcm.getToken();
    if (token == null || token.isEmpty) return;

    await _sendTokenToBackend(userId: userId, token: token);
  }

  /// Call on logout. If [userId] is supplied, first tells the backend to
  /// unregister this device's token — otherwise a shared/reused device would
  /// keep receiving this buyer's notifications after signing out — before
  /// deleting the token locally.
  static Future<void> clearToken({String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      try {
        final token = await _fcm.getToken();
        if (token != null && token.isNotEmpty) {
          await _removeTokenFromBackend(userId: userId, token: token);
        }
      } catch (e) {
        print("FCM remove-from-server failed (non-fatal): $e");
      }
    }

    try {
      await _fcm.deleteToken();
      print("FCM token deleted successfully");
    } catch (e) {
      print("FCM token deletion failed: $e");
    }
  }

  static Future<void> _sendTokenToBackend({
    required String userId,
    required String token,
  }) async {
    final uri = Uri.parse("$baseUrl/buyer/save/fcm-token");

    final platform = Platform.isAndroid
        ? "android"
        : Platform.isIOS
        ? "ios"
        : "unknown";

    final payload = {"userId": userId, "token": token, "platform": platform};

    try {
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      print("FCM save status: ${resp.statusCode} body: ${resp.body}");
    } catch (e) {
      print("FCM save failed: $e");
    }
  }

  static Future<void> _removeTokenFromBackend({
    required String userId,
    required String token,
  }) async {
    final uri = Uri.parse("$baseUrl/buyer/remove/fcm-token");
    final resp = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "token": token}),
    );
    print("FCM remove status: ${resp.statusCode} body: ${resp.body}");
  }
}
