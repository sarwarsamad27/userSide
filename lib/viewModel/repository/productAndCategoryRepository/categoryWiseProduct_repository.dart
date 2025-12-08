import 'package:user_side/models/ProductAndCategoryModel/categoryWiseProduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetCategoryWiseProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.CategoryWiseProduct;

  Future<CategoryWiseProductModel> getCategoryWiseProduct(String categoryName, int limit, int page) async {
    try {
      final response = await apiServices
          .getApi("$apiUrl?category=$categoryName&page=$page&limit=$limit");
          print(response);
      return CategoryWiseProductModel.fromJson(response);
    } catch (e) {
      return CategoryWiseProductModel(data: [], );
    }
  }
}
