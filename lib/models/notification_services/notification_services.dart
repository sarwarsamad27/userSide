import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // change this
  static String baseUrl = Global.BaseUrl;

  static Future<void> initAndRegisterToken() async {
    // iOS permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // get deviceId (guest + login)
    final deviceId = await LocalStorage.getOrCreateDeviceId();
    final buyerId = await LocalStorage.getUserId();
    // get token
    final token = await _fcm.getToken();
    if (token != null && token.isNotEmpty) {
      await _sendTokenToBackend(
        deviceId: deviceId,
        token: token,
        buyerId: buyerId,
      );
    }

    // refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _sendTokenToBackend(
        deviceId: deviceId,
        token: newToken,
        buyerId: buyerId,
      );
      final token = await FirebaseMessaging.instance.getToken();
      print("FCM TOKEN: $token");
    });
  }

  static Future<void> _sendTokenToBackend({
    required String deviceId,
    required String token,
    String? buyerId,
  }) async {
    final uri = Uri.parse("$baseUrl/buyer/save/fcm-token");

    final platform = Platform.isAndroid
        ? "android"
        : Platform.isIOS
        ? "ios"
        : "unknown";

    final payload = {
      "deviceId": deviceId,
      "token": token,
      "buyerId": buyerId, // optional
      "platform": platform,
    };

    try {
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      print("response daikho $resp");
      // optional: log
      // print("FCM save status: ${resp.statusCode} body: ${resp.body}");
    } catch (e) {
      // swallow errors (do not crash app)
      // print("FCM save failed: $e");
    }
  }
}
