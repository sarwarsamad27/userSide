import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetSingleProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetSingleProduct;

  Future<GetSingleProductModel> getSingleProduct(String categoryId,
      String profileId,
      String productId,
      ) async {
    try {
      final url = '$apiUrl?profileId=$profileId&categoryId=$categoryId&productId=$productId';
      final response = await apiServices.getApi(url);
      return GetSingleProductModel.fromJson(response);
    } catch (e) {
      return GetSingleProductModel(
        message: "Error: $e",
        product: null,
      );
    }
  }
}
