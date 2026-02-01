import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/notification_services/notification_services.dart';

import 'package:user_side/resources/appTheme.dart';
import 'package:user_side/view/auth/splashView.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_route.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/viewModel/provider/multiProvider/multiProvider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   await NotificationService.init();

  // ✅ Push tap -> NotificationScreen
  await NotificationRouter.init();

  runApp(const AppWrapper());
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AppMultiProvider(
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Cold start deep link
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Foreground/background deep link
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (_) {});
  }

  void _handleDeepLink(Uri uri) {
    // expecting: shookoo://product?productId=...&categoryId=...&profileId=...
    if (uri.scheme != "shookoo" || uri.host != "product") return;

    final productId = uri.queryParameters["productId"];
    final categoryId = uri.queryParameters["categoryId"];
    final profileId = uri.queryParameters["profileId"];

    if (productId == null || categoryId == null || profileId == null) return;

    // ✅ Use the SAME navigatorKey as push routing
    NotificationRouter.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          profileId: profileId,
          categoryId: categoryId,
          productId: productId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: NotificationRouter.navigatorKey, // ✅ single key
          debugShowCheckedModeBanner: false,
          title: 'SHOOKOO',
          theme: AppTheme.lightTheme,
          home: SplashScreen(),
        );
      },
    );
  }
}
