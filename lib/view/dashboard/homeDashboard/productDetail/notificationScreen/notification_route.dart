import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_screen.dart';

class NotificationRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> init() async {
    // iOS permission (safe on Android too)
    await FirebaseMessaging.instance.requestPermission();

    // If app in background and opened by tapping notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _openNotificationScreen();
    });

    // If app opened from terminated state by tapping notification. This runs
    // before runApp(), so the Navigator isn't mounted yet — defer the push
    // until after the first frame instead of pushing immediately.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openNotificationScreen());
    }
  }

  static void _openNotificationScreen() {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }
}
