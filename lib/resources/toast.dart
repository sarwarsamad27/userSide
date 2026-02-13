import 'package:user_side/resources/premium_toast.dart';

class AppToast {
  // 🔵 General Toast
  static void show(String message) {
    PremiumToast.info(null, message);
  }

  // 🟢 Success Toast
  static void success(String message) {
    PremiumToast.success(null, message);
  }

  // 🔴 Error Toast
  static void error(String message) {
    PremiumToast.error(null, message);
  }

  // 🟡 Warning Toast
  static void warning(String message) {
    PremiumToast.warning(null, message);
  }

  // 🔵 Info Toast
  static void info(String message) {
    PremiumToast.info(null, message);
  }
}
