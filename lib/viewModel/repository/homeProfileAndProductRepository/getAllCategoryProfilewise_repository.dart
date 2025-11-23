import 'package:user_side/models/GetProfileAndProductModel/getAllCategoryProfileWise_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetAllCategoryProfileWiseRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetAllCategoryProfileWise;

  Future<GetAllCategoryProfileWiseModel> getAllCategoryProfileWise(
      String profileId) async {
    try {
      final url = '$apiUrl?profileId=$profileId';
      final response = await apiServices.getApi(url);
      return GetAllCategoryProfileWiseModel.fromJson(response);
    } catch (e) {
      return GetAllCategoryProfileWiseModel(
        message: "Error: $e",
        categories: [],
      );
    }
  }
}
