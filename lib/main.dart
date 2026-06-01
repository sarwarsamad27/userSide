import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/notification_services/notification_services.dart';

import 'package:user_side/resources/appTheme.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/view/auth/splashView.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_route.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/viewModel/provider/multiProvider/multiProvider.dart';
import 'package:user_side/view/common/no_internet_screen.dart';
import 'package:user_side/viewModel/provider/connectivity_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) rethrow;
  }
  await NotificationService.init();

  await NotificationRouter.init();
  await AuthSession.instance.init();
  // ConnectivityService.instance.init();
  runApp(const AppWrapper());
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AppMultiProvider(child: const MyApp());
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
    // Cold start — app was not running when link was tapped
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      // Delay so navigator is ready after splash
      Future.delayed(const Duration(milliseconds: 800), () => _handleDeepLink(initialUri));
    }

    // App already running — link tapped while app is open/background
    _sub = _appLinks.uriLinkStream.listen(_handleDeepLink, onError: (_) {});
  }

  void _handleDeepLink(Uri uri) {
    // Handles: shookoo://p/<productId>/<slug>?profileId=xxx&categoryId=yyy
    if (uri.scheme != "shookoo" || uri.host != "p") return;

    final segments   = uri.pathSegments; // [productId, slug]
    if (segments.isEmpty) return;

    final productId  = segments[0];
    final profileId  = uri.queryParameters["profileId"] ?? '';
    final categoryId = uri.queryParameters["categoryId"] ?? '';

    if (productId.isEmpty || profileId.isEmpty || categoryId.isEmpty) return;

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
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ConnectivityProvider>(
          builder: (context, connectivity, child) {
            return MaterialApp(
              navigatorKey: NotificationRouter.navigatorKey, // ✅ single key
              debugShowCheckedModeBanner: false,
              title: 'SHOOKOO',
              theme: AppTheme.lightTheme,
              home: !connectivity.isConnected
                  ? NoInternetScreen(
                      onRetry: () {
                        // Handled by provider
                      },
                    )
                  : SplashScreen(),
            );
          },
        );
      },
    );
  }
}
