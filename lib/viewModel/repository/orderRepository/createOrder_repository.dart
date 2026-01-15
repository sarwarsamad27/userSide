import 'package:user_side/models/order/createOrder_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class CreateOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.CreateOrder;
  Future<CreateOrderModel> createOrder({
    required String buyerId,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? additionalNote,
    required List<Map<String, dynamic>> products,
    required int shipmentCharges,
  }) async {
    final deviceId = await LocalStorage.getOrCreateDeviceId();

    try {
      final Map<String, dynamic> fields = {
        "buyerId": buyerId,
        "buyerDetails": {
          "name": name,
          "deviceId": deviceId,
          "email": email,
          "phone": phone,
          "address": address,
          "additionalNote": additionalNote ?? "",
        },
        "products": products,
        "shipmentCharges": shipmentCharges,
      };
      print("CreateOrder Response: $name");
      print("CreateOrder email: $email");
      print("CreateOrder phone: $phone");
      print("CreateOrder address: $address");
      print("CreateOrder additionalNote: $additionalNote");
      print("CreateOrder buyerId: $buyerId");
      print("CreateOrder shipmentCharges: $shipmentCharges");
      print("CreateOrder products: $products");

      final response = await apiServices.postApi(apiUrl, fields);
      print("CreateOrder Response: $response");
      return CreateOrderModel.fromJson(response);
    } catch (e) {
      return CreateOrderModel(message: "Error: $e");
    }
  }
}
