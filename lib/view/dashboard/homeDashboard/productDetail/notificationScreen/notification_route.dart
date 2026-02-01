import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_screen.dart';

class NotificationRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> init() async {
    // iOS permission (safe on Android too)
    await FirebaseMessaging.instance.requestPermission();

    // If app opened from terminated state by tapping notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _openNotificationScreen();
    }

    // If app in background and opened by tapping notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _openNotificationScreen();
    });
  }

  static void _openNotificationScreen() {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }
}
