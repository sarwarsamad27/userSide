import 'package:flutter/foundation.dart';
import 'local_storage.dart';

class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? _userId;
  bool _initialized = false;

  String? get userId => _userId;
  bool get initialized => _initialized;

  bool get isLoggedIn => _userId != null && _userId!.trim().isNotEmpty;

  /// call once on app start
  Future<void> init() async {
    _userId = await LocalStorage.getUserId();
    _initialized = true;
    notifyListeners();
  }

  /// call after login success (jab API se userId milay)
  Future<void> setUser(String userId) async {
    await LocalStorage.saveUserId(userId);
    _userId = userId;
    notifyListeners();
  }

  /// call on logout
  Future<void> logout() async {
    await LocalStorage.clearAuth(); // removes token + userId
    _userId = null;
    notifyListeners();
  }

  /// optional: if you need force sync with storage
  Future<void> reload() async {
    _userId = await LocalStorage.getUserId();
    notifyListeners();
  }
}
