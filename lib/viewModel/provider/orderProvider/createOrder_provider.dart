import 'package:flutter/material.dart';
import 'package:user_side/models/order/createOrder_model.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/repository/orderRepository/createOrder_repository.dart';

class CreateOrderProvider with ChangeNotifier {
  final CreateOrderRepository repository = CreateOrderRepository();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CreateOrderModel? _orderData;
  CreateOrderModel? get orderData => _orderData;

  Future<void> placeOrder({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? additionalNote,
    required List<Map<String, dynamic>> products,
    required int shipmentCharges,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get buyerId from local storage (logged-in user)
      String? buyerId = await LocalStorage.getUserId();
      if (buyerId == null) {
        _errorMessage = "User not logged in";
        _loading = false;
        notifyListeners();
        return;
      }

      _orderData = await repository.createOrder(
        buyerId: buyerId,
        name: name,
        email: email,
        phone: phone,
        address: address,
        additionalNote: additionalNote,
        products: products,
        shipmentCharges: shipmentCharges,
      );
    } catch (e) {
      _errorMessage = "Error: $e";
    }

    _loading = false;
    notifyListeners();
  }
}
