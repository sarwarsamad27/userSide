import 'package:user_side/models/favouriteModel/deleteFavourite_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class DeleteFavouriteRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.DeleteFavourite;

  Future<DeleteFavouriteProductModel> deleteFavourite(
    String userId,
    String productId,
  ) async {
    try {
      final url = '$apiUrl?userId=$userId&productId=$productId';
      final response = await apiServices.deleteApi(url);
      return DeleteFavouriteProductModel.fromJson(response);
    } catch (e) {
      return DeleteFavouriteProductModel(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }
}
