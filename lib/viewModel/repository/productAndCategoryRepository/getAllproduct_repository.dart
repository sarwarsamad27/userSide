import 'package:user_side/models/ProductAndCategoryModel/getAllProduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetAllProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetAllProduct;

  /// page + limit both supported
  Future<GetAllProductModel> getAllProduct({
    int page = 1,
    int limit = 20, // ✅ default limit
  }) async {
    try {
      final response = await apiServices.getApi("$apiUrl?page=$page&limit=$limit");
      return GetAllProductModel.fromJson(response);
    } catch (e) {
      return GetAllProductModel(success: false, data: null);
    }
  }
}
