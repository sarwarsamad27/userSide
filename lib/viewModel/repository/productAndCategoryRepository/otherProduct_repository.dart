import 'package:user_side/models/GetProfileAndProductModel/otherProduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class OtherProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.OtherProduct;

  Future<OtherProductModel> otherProduct(int page , String productId , int limit) async {
    try {
      final response = await apiServices.getApi("$apiUrl?productId=$productId&page=$page&limit=$limit");
      return OtherProductModel.fromJson(response);
    } catch (e) {
      return OtherProductModel(otherProducts: [], message: "Error: $e");
    }
  }
}
