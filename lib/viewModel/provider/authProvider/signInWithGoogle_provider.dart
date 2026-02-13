import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/view/auth/loginView.dart';

import '../../../models/auth/googleLogin_model.dart';
import '../../repository/authRepository/signInWithGoogle_repository.dart';

class GoogleLoginProvider with ChangeNotifier {
  final GoogleLoginRepository repository = GoogleLoginRepository();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  GoogleLoginModel? _loginData;
  GoogleLoginModel? get loginData => _loginData;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId:
        '42694486923-frbnu8ts0ph8glgo5u3jv1ovtpv9i0jf.apps.googleusercontent.com',
  );

  Future<void> loginWithGoogle() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = "Google Sign-In cancelled";
        _loading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) {
        _errorMessage = "Google token not found";
        _loading = false;
        notifyListeners();
        return;
      }

      _loginData = await repository.googleLogin(idToken);

      _loading = false;
      notifyListeners();

      if (_loginData?.token != null &&
          _loginData!.token!.isNotEmpty &&
          _loginData!.user != null &&
          _loginData!.user!.id != null) {
        await LocalStorage.saveToken(_loginData!.token!);
        await LocalStorage.saveUserId(_loginData!.user!.id!);
        await AuthSession.instance.setUser(
          _loginData!.user!.id!,
        ); // ✅ Update global session
      } else {
        _errorMessage = _loginData?.message ?? "Login failed";
        notifyListeners();
      }
    } catch (e) {
      _loading = false;
      _errorMessage = "Google Sign-In error: $e";
      notifyListeners();
    }
  }

  /// ✅ Actual logout (NO dialog, NO navigation)
  Future<void> logout() async {
    // Clear app auth only (don’t clear deviceId if you use it)
    await LocalStorage.clearAuth();

    // Clear Google session
    await googleSignIn.signOut();

    // If you want account picker next time, you can also do:
    // await googleSignIn.disconnect();
  }

  /// ✅ Show confirmation dialog, then logout + navigate
  Future<void> confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await logout();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        // Optional: show toast/snackbar
        // AppToast.error("Logout error: $e");
      }
    }
  }
}
