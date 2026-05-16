import 'package:flutter/material.dart';
import 'package:user_side/resources/premium_toast.dart';

class AppToast {
  // 🔵 General Toast
  static void show(String message, {BuildContext? context}) {
    PremiumToast.info(context, message);
  }

  // 🟢 Success Toast
  static void success(String message, {BuildContext? context}) {
    PremiumToast.success(context, message);
  }

  // 🔴 Error Toast
  static void error(String message, {BuildContext? context}) {
    PremiumToast.error(context, message);
  }

  // 🟡 Warning Toast
  static void warning(String message, {BuildContext? context}) {
    PremiumToast.warning(context, message);
  }

  // 🔵 Info Toast
  static void info(String message, {BuildContext? context}) {
    PremiumToast.info(context, message);
  }
}
