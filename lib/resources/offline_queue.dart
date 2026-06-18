import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores write operations (favorite toggle, COD order) that failed due to
/// no internet. Processed automatically when connectivity is restored.
class OfflineQueue {
  static const _key = 'offline_queue';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  static Future<List<Map<String, dynamic>>> _all() async {
    final p = await _p;
    final raw = p.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<Map<String, dynamic>> items) async {
    final p = await _p;
    await p.setString(_key, jsonEncode(items));
  }

  /// Add a pending operation. [type] is 'favorite_toggle' | 'cod_order'.
  static Future<void> enqueue({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final items = await _all();
    items.add({
      'id': '${type}_${DateTime.now().millisecondsSinceEpoch}',
      'type': type,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await _save(items);
  }

  static Future<List<Map<String, dynamic>>> getAll() => _all();

  static Future<void> remove(String id) async {
    final items = await _all();
    items.removeWhere((e) => e['id'] == id);
    await _save(items);
  }

  static Future<void> clear() async {
    final p = await _p;
    await p.remove(_key);
  }

  static Future<bool> get isEmpty async => (await _all()).isEmpty;
}
