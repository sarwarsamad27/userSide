import 'package:flutter/material.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class DeliverySettingsProvider with ChangeNotifier {
  final NetworkApiServices _api = NetworkApiServices();

  double defaultCharge = 200;
  double freeDeliveryThreshold = 10000;
  bool freeDeliveryEnabled = true;
  bool isLoaded = false;

  double getShipmentCharges(double productTotal) {
    if (freeDeliveryEnabled && freeDeliveryThreshold > 0 &&
        productTotal >= freeDeliveryThreshold) {
      return 0;
    }
    return defaultCharge;
  }

  bool isFreeDelivery(double productTotal) => getShipmentCharges(productTotal) == 0;

  Future<void> fetchSettings() async {
    if (isLoaded) return;
    try {
      final res = await _api.getApi(Global.DeliverySettings);
      defaultCharge = (res['defaultCharge'] as num?)?.toDouble() ?? 200;
      freeDeliveryThreshold =
          (res['freeDeliveryThreshold'] as num?)?.toDouble() ?? 10000;
      freeDeliveryEnabled = res['freeDeliveryEnabled'] as bool? ?? true;
      isLoaded = true;
      notifyListeners();
    } catch (_) {}
  }
}
