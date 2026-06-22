import 'package:user_side/models/GetProfileAndProductModel/relatedPrduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class RelatedProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.RelatedProduct;

  Future<RelatedProductModel> relatedProduct(int page, String productId, int limit) async {
    try {
      final response = await apiServices.cachedGetApi(
        'related_products_${productId}_p${page}_l$limit',
        "$apiUrl?productId=$productId&page=$page&limit=$limit",
      );
      return RelatedProductModel.fromJson(response);
    } catch (e) {
      return RelatedProductModel(relatedProducts: [], message: "Error: $e");
    }
  }
}
