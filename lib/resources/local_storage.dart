import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalStorage {
  static const String _deviceKey = "deviceId";

  /// Reviewed products key
  static const String _reviewedProductsKey = "reviewedProductIds";

  /// -------- DEVICE ID (GUEST + LOGIN BOTH) --------
  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    String? deviceId = prefs.getString(_deviceKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceKey, deviceId);
    }

    return deviceId;
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userId");
  }

  /// -------------------- TOKEN --------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// -------------------- USER ID --------------------
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  /// -------------------- REVIEWED PRODUCTS (SharedPreferences) --------------------
  static Future<Set<String>> getReviewedProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reviewedProductsKey) ?? <String>[];
    return list.toSet();
  }

  static Future<bool> hasReviewedProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reviewedProductsKey) ?? <String>[];
    return list.contains(productId);
  }

  static Future<void> markProductReviewed(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reviewedProductsKey) ?? <String>[];
    if (!list.contains(productId)) {
      list.add(productId);
      await prefs.setStringList(_reviewedProductsKey, list);
    }
  }

  static Future<void> removeReviewedProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reviewedProductsKey) ?? <String>[];
    list.remove(productId);
    await prefs.setStringList(_reviewedProductsKey, list);
  }

  static Future<void> clearReviewedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reviewedProductsKey);
  }

  /// -------------------- CLEAR ALL --------------------
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
