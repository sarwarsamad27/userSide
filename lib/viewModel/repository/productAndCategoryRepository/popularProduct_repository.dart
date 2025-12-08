import 'package:user_side/models/ProductAndCategoryModel/popularProduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetPopularProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetPopularProduct;

  Future<PopularProductModel> getPopularProduct() async {
    try {
      final response = await apiServices.getApi(apiUrl);
      return PopularProductModel.fromJson(response);
    } catch (e) {
      return PopularProductModel(success: false, products: []);
    }
  }
}
