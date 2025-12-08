import 'package:user_side/models/GetProfileAndProductModel/relatedPrduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class RelatedProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.RelatedProduct;

  Future<RelatedProductModel> relatedProduct(int page , String productId , String categoryId, int limit) async {
    try {
      final response = await apiServices.getApi("$apiUrl?productId=$productId&categoryId=$categoryId&page=$page&limit=$limit");
      return RelatedProductModel.fromJson(response);
    } catch (e) {
      return RelatedProductModel(relatedProducts: [], message: "Error: $e");
    }
  }
}
