import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/authSession.dart';

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
        '900853727644-a6m3k2sf0bdumpfkvm7h2hhlal4ct76i.apps.googleusercontent.com',
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
          email: _loginData!.user!.email,
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
    // Clear global session (including FCM and LocalStorage)
    await AuthSession.instance.logout();

    // Clear Google session
    await googleSignIn.signOut();

    // If you want account picker next time, you can also do:
    // await googleSignIn.disconnect();
  }

  /// ✅ Show confirmation dialog, then logout — no navigation. The buyer app
  /// is browsable as a guest, so logout just clears the session in place;
  /// every screen that reads AuthSession (e.g. ProfileScreen's `isLoggedIn`
  /// via `context.watch<AuthSession>()`) re-renders itself into its
  /// logged-out state automatically once logout() calls notifyListeners(),
  /// the same way it would if the user had never logged in.
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

    if (result != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColor.appimagecolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitThreeBounce(color: AppColor.whiteColor, size: 28.0),
                const SizedBox(height: 16),
                const Text(
                  "Logging out...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await logout();
    } catch (_) {
      // Optional: show toast/snackbar
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
