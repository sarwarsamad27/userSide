import 'package:user_side/models/ProductAndCategoryModel/popularCategory_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetPopularCategoryRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetPopularCategory;

  Future<PopularCategoryModel> getPopularCategory() async {
    try {
      final response = await apiServices.getApi(apiUrl);
      return PopularCategoryModel.fromJson(response);
    } catch (e) {
      return PopularCategoryModel(success: false, categories: []);
    }
  }
}
