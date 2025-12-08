import 'package:user_side/models/order/myOrderModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetMyOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetMyOrder;

  Future<MyOrderModel> getMyOrder(String buyerId, int limit, int page) async {
    try {
      final response = await apiServices
          .getApi("$apiUrl?buyerId=$buyerId&page=$page&limit=$limit");
      return MyOrderModel.fromJson(response);
    } catch (e) {
      return MyOrderModel(success: false, orders: []);
    }
  }
}
