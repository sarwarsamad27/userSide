// repository/recommendation_repository.dart

import 'package:user_side/models/ProductAndCategoryModel/recommendedProduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class RecommendationRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<RecommendedProductModel> getRecommendedProducts(
    String deviceId,
  ) async {
    try {
      final url = "${Global.RecommendedProducts}?deviceId=$deviceId";
      final response = await apiServices.getApi(url);
      print(response);
      return RecommendedProductModel.fromJson(response);
    } catch (e) {
      return RecommendedProductModel(success: false, products: []);
    }
  }
}
