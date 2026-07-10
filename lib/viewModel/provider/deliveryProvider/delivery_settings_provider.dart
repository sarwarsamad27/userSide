import 'package:flutter/material.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class DeliverySettingsProvider with ChangeNotifier {
  final NetworkApiServices _api = NetworkApiServices();

  double sameCityCharge = 200;
  double otherCityCharge = 300;
  double freeDeliveryThreshold = 10000;
  bool freeDeliveryEnabled = true;
  bool isLoaded = false;

  Future<void> fetchSettings() async {
    if (isLoaded) return;
    try {
      final res = await _api.getApi(Global.DeliverySettings);
      sameCityCharge = (res['sameCityCharge'] as num?)?.toDouble() ?? 200;
      otherCityCharge = (res['otherCityCharge'] as num?)?.toDouble() ?? 300;
      freeDeliveryThreshold =
          (res['freeDeliveryThreshold'] as num?)?.toDouble() ?? 10000;
      freeDeliveryEnabled = res['freeDeliveryEnabled'] as bool? ?? true;
      isLoaded = true;
      notifyListeners();
    } catch (_) {}
  }
}
