import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/view/auth/loginView.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/widgets/customBgContainer.dart';

// Providers for refresh
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProfile_provider.dart';
import 'package:user_side/viewModel/provider/notificationProvider/notification_provider.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/getFavourite_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularProduct_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/getMyOrder_provider.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGate({super.key, required this.child, this.fallback});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _wasLoggedIn = context.read<AuthSession>().isLoggedIn;
  }

  void _triggerRefresh(BuildContext context) {
    debugPrint("AuthGate: User logged in, refreshing all APIs...");

    // Refresh all relevant providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetAllProfileProvider>().refreshProfiles();
      context.read<NotificationProvider>().fetch();
      context.read<FavouriteProvider>().getFavourites();
      context.read<PopularProductProvider>().refresh();
      context.read<GetMyOrderProvider>().fetchMyOrders(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSession>();

    // Detect login transition
    if (!_wasLoggedIn && auth.isLoggedIn) {
      _triggerRefresh(context);
    }
    _wasLoggedIn = auth.isLoggedIn;

    if (!auth.initialized) {
      return Scaffold(body: Utils.loadingLottie());
    }

    if (!auth.isLoggedIn) {
      return widget.fallback ??
          Scaffold(
            body: CustomBgContainer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Login required"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: const Text("Go to Login"),
                    ),
                  ],
                ),
              ),
            ),
          );
    }

    return widget.child;
  }
}
