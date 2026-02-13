import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:user_side/resources/premium_toast.dart';

class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._internal();
  ConnectivityService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkStatus(results);
    });
  }

  Future<void> _checkStatus(List<ConnectivityResult> results) async {
    bool isConnected = false;

    // Check if any of the results indicate a valid connection type
    if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
      // Even if connectivity says we have wifi/mobile, verify actual internet access
      isConnected = await _verifyInternet();
    }

    if (!isConnected) {
      _wasOffline = true;
      PremiumToast.error(null, "No Internet Connection");
    } else {
      if (_wasOffline) {
        _wasOffline = false;
        PremiumToast.success(null, "Internet Restored!");
      }
    }
  }

  Future<bool> _verifyInternet() async {
    try {
      final result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  // Helper for one-time check
  static Future<bool> isConnected() async {
    var results = await Connectivity().checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

// ✅ Compatibility with old global calls
Future<bool> isConnected() => ConnectivityService.isConnected();
