import 'package:user_side/models/favouriteModel/getFavouriteList_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetFavouriteListRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetFavourite;

  Future<FavouriteListModel> getFavouriteList(String userId) async {
    try {
      final response = await apiServices.cachedGetApi(
        'favourites_$userId',
        '$apiUrl/?userId=$userId',
      );
      return FavouriteListModel.fromJson(response);
    } catch (e) {
      return FavouriteListModel(success: false, favourites: []);
    }
  }
}
