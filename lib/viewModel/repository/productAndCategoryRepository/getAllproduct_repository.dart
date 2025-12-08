import 'package:user_side/models/ProductAndCategoryModel/getAllProduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetAllProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetAllProduct;

  Future<GetAllProductModel> getAllProduct({int page = 1}) async {
    try {
      final response = await apiServices.getApi("$apiUrl?page=$page");
      return GetAllProductModel.fromJson(response);
    } catch (e) {
      return GetAllProductModel(success: false, data: null);
    }
  }
}
