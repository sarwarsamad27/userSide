import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'local_storage.dart';

// Providers for refresh
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProfile_provider.dart';
import 'package:user_side/viewModel/provider/notificationProvider/notification_provider.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/getFavourite_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularProduct_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/getMyOrder_provider.dart';
import 'package:user_side/viewModel/provider/productProvider/getPopularCategory_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/recommendedProduct_provider.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/chatThread_provider.dart';
import 'package:user_side/models/notification_services/notification_services.dart';

class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? _userId;
  String? _userEmail;
  bool _initialized = false;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get initialized => _initialized;

  bool get isLoggedIn => _userId != null && _userId!.trim().isNotEmpty;

  /// call once on app start
  Future<void> init() async {
    _userId = await LocalStorage.getUserId();
    _userEmail = await LocalStorage.getUserEmail();
    _initialized = true;
    notifyListeners();
  }

  /// call after login success (jab API se userId milay)
  Future<void> setUser(String userId, {String? email}) async {
    await LocalStorage.saveUserId(userId);
    if (email != null) {
      await LocalStorage.saveUserEmail(email);
    }
    _userId = userId;
    _userEmail = email;
    notifyListeners();
  }

  /// call on logout
  Future<void> logout() async {
    await NotificationService.clearToken();
    await LocalStorage.clearAuth(); // removes token + userId + email
    _userId = null;
    _userEmail = null;
    notifyListeners();
  }

  /// optional: if you need force sync with storage
  Future<void> reload() async {
    _userId = await LocalStorage.getUserId();
    _userEmail = await LocalStorage.getUserEmail();
    notifyListeners();
  }

  /// ✅ Central Orchestration for Refresh (Called from Login buttons or AuthGate)
  static void refreshAppData(BuildContext context) {
    debugPrint("AuthSession: Refreshing all data after login...");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<GetAllProfileProvider>().refreshProfiles();
      context.read<NotificationProvider>().fetch(
        showLoader: false,
        force: true,
      );
      context.read<FavouriteProvider>().getFavourites();
      context.read<PopularProductProvider>().refresh();
      context.read<GetMyOrderProvider>().fetchMyOrders(isRefresh: true);
      context.read<PopularCategoryProvider>().refresh();

      final deviceId = await LocalStorage.getOrCreateDeviceId();
      context.read<RecommendationProvider>().fetchRecommendations(deviceId);

      final userId = instance.userId;
      if (userId != null) {
        context.read<ChatThreadProvider>().fetchThreads(userId);
      }
    });
  }
}
