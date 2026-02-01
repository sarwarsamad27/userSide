import 'package:user_side/models/GetProfileAndProductModel/followUnFollow_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class FollowRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<FollowResponseModel> toggleFollow(String profileId) async {
    final userId = await LocalStorage.getUserId();

    if (userId == null || userId.isEmpty) {
      return FollowResponseModel(message: "You are not login");
    }

    final body = {
      "profileId": profileId,
      "userId": userId,
    };

    final response = await apiServices.postApi(Global.ToggleFollow, body);
    return FollowResponseModel.fromJson(response);
  }

  Future<FollowResponseModel> getFollowStatus(String profileId) async {
    final userId = await LocalStorage.getUserId();

    // ✅ userId optional now
    final url = (userId == null || userId.isEmpty)
        ? '${Global.GetFollowStatus}?profileId=$profileId'
        : '${Global.GetFollowStatus}?profileId=$profileId&userId=$userId';

    final response = await apiServices.getApi(url);
    return FollowResponseModel.fromJson(response);
  }
}
