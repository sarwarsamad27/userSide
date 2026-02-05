import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:user_side/models/auth/login_model.dart';
import 'package:user_side/models/notification_services/notification_services.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/repository/authRepository/login_repository.dart';

// ✅ CHANGE: AuthSession import added
import 'package:user_side/resources/authSession.dart';

class LoginProvider with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginModel? _loginData;
  LoginModel? get loginData => _loginData;

  bool _submitted = false;
  bool get submitted => _submitted;

  void setSubmitted(bool value) {
    _submitted = value;
    notifyListeners();
  }

  final LoginRepository repository = LoginRepository();

  Future<void> loginProvider() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      _loginData = await repository.login(email, password);

      final token = _loginData?.token;
      final userId = _loginData?.user?.id;

      if (token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty) {
        final fcm = await FirebaseMessaging.instance.getToken();

        // ✅ 1) Save first
        await LocalStorage.saveToken(token);
        await LocalStorage.saveUserId(userId);

        // ✅ CHANGE: Update AuthSession in-memory (AuthGate instantly rebuild)
        await AuthSession.instance.setUser(userId);

        // ✅ 2) Then register FCM token (now userId exists)
        await NotificationService.registerTokenIfLoggedIn();
        print("FCM TOKEN HINT: ...${fcm?.substring((fcm?.length ?? 10) - 10)}");
        print("Saved userId: ${await LocalStorage.getUserId()}");
      } else {
        _errorMessage = _loginData?.message ?? "Login failed";
      }
    } catch (e) {
      _errorMessage = "Something went wrong. Please try again.";
    }

    _loading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _submitted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
