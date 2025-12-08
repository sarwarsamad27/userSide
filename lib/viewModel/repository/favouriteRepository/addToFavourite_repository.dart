import 'package:user_side/models/favouriteModel/addToFavourite_model.dart';
import 'package:user_side/network/base_api_services.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class AddToFavouriteRepository {
  final BaseApiServices apiService = NetworkApiServices();

  Future<AddToFavouriteModel> addToFavourite({
    required String productId,
    required String userId,
    required List<String> selectedColors,
    required List<String> selectedSizes,
  }) async {
    try {
      final response = await apiService.postApi(Global.AddToFavourite, {
        "productId": productId,
        "userId": userId,
        "selectedColors": selectedColors,
        "selectedSizes": selectedSizes,
      });

      return AddToFavouriteModel.fromJson(response);
    } catch (e) {
      return AddToFavouriteModel(message: "Error occurred: $e", success: false);
    }
  }
}
