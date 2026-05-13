import 'package:flutter/material.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class ActiveCategoryChipsProvider with ChangeNotifier {
  final NetworkApiServices _api = NetworkApiServices();

  List<String> chips = [];
  bool isLoading = false;
  bool _fetched = false;

  Future<void> fetch({bool force = false}) async {
    if (_fetched && !force) return;
    isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getApi(Global.ActiveCategoryChips);
      final raw = res['chips'];
      if (raw is List) {
        chips = raw.map((e) => e.toString()).toList();
      }
      _fetched = true;
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }
}
