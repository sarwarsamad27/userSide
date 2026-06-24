import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/models/notification_services/notification_services.dart';

import 'package:user_side/resources/appTheme.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/auth/splashView.dart';
import 'package:user_side/view/dashboard/DashboardScreen.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/notificationScreen/notification_route.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/viewModel/provider/connectivity_provider.dart';
import 'package:user_side/viewModel/provider/multiProvider/multiProvider.dart';
import 'package:user_side/viewModel/provider/syncCoordinator_provider.dart';
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
    return AppMultiProvider(
      child: _OfflineSyncRegistrar(child: const MyApp()),
    );
  }
}

/// Registers offline-queue flush callbacks with ConnectivityProvider once
/// the full provider tree is available.
class _OfflineSyncRegistrar extends StatefulWidget {
  final Widget child;
  const _OfflineSyncRegistrar({required this.child});
  @override
  State<_OfflineSyncRegistrar> createState() => _OfflineSyncRegistrarState();
}

class _OfflineSyncRegistrarState extends State<_OfflineSyncRegistrar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final connectivity = context.read<ConnectivityProvider>();
      connectivity.addReconnectCallback(
        context.read<SyncCoordinator>().syncAll,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
    // Admin "Account Visit": shookoo://impersonate?token=...&userId=...&email=...
    if (uri.scheme == "shookoo" && uri.host == "impersonate") {
      _handleImpersonation(uri);
      return;
    }

    // Handles both:
    //   shookoo://p/<productId>/<slug>?profileId=xxx&categoryId=yyy   (custom scheme)
    //   https://<host>/p/<productId>/<slug>?profileId=xxx&categoryId=yyy (App Links)
    List<String> segments;
    if (uri.scheme == "shookoo" && uri.host == "p") {
      segments = uri.pathSegments; // [productId, slug]
    } else if ((uri.scheme == "https" || uri.scheme == "http") &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == "p") {
      segments = uri.pathSegments.skip(1).toList(); // drop leading "p"
    } else {
      return;
    }

    if (segments.isEmpty) return;

    final productId  = segments[0];
    // Optional — older links (or the web landing page's internal app-link)
    // may still carry these, but ProductDetailScreen resolves them itself
    // from the product if absent, so only productId is required here.
    final profileId  = uri.queryParameters["profileId"];
    final categoryId = uri.queryParameters["categoryId"];

    if (productId.isEmpty) return;

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

  // Saves the impersonation token/userId/email exactly like a normal login
  // would, then jumps straight to the dashboard — bypassing the splash
  // screen and AuthGate entirely, since they only gate on userId presence,
  // not token validity (the backend enforces the 1-hour expiry per-request).
  Future<void> _handleImpersonation(Uri uri) async {
    final token = uri.queryParameters['token'];
    final userId = uri.queryParameters['userId'];
    final email = uri.queryParameters['email'];
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      return;
    }

    await LocalStorage.saveToken(token);
    await AuthSession.instance.setUser(userId, email: email);

    NotificationRouter.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeNavBarScreen()),
      (route) => false,
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
              navigatorKey: NotificationRouter.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'SHOOKOO',
              theme: AppTheme.lightTheme,
              home: SplashScreen(),
              builder: (context, child) => Column(
                children: [
                  if (!connectivity.isConnected)
                    Material(
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          width: double.infinity,
                          color: const Color(0xFFE65100),
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_off,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'No internet — cached data',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(child: child!),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
