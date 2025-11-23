import 'package:user_side/models/GetProfileAndProductModel/getAllProductCategoryWise_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetAllProductCategoryWiseRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetAllProductCategoryWise;

  Future<GetAllProductCategoryWiseModel> getAllCategoryProfileWise(String categoryId,
      String profileId) async {
    try {
      final url = '$apiUrl?profileId=$profileId&categoryId=$categoryId';
      final response = await apiServices.getApi(url);
      return GetAllProductCategoryWiseModel.fromJson(response);
    } catch (e) {
      return GetAllProductCategoryWiseModel(
        message: "Error: $e",
        products: [],
      );
    }
  }
}
