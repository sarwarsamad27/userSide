import 'package:user_side/models/GetProfileAndProductModel/followUnFollow_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class FollowRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<FollowResponseModel> toggleFollow(String profileId) async {
    try {
      final deviceId = await LocalStorage.getOrCreateDeviceId();
      final body = {
        "profileId": profileId,
        "deviceId": deviceId,
      };

      print("📤 TOGGLE FOLLOW API: ${Global.ToggleFollow}");
      print("📦 REQUEST BODY: $body");

      final response = await apiServices.postApi(Global.ToggleFollow, body);
      print("✅ TOGGLE API RESPONSE: $response");

      return FollowResponseModel.fromJson(response);
    } catch (e) {
      print("❌ TOGGLE API ERROR: $e");
      print("❌ ERROR TYPE: ${e.runtimeType}");
      rethrow;
    }
  }

  Future<FollowResponseModel> getFollowStatus(String profileId) async {
    try {
      final deviceId = await LocalStorage.getOrCreateDeviceId();
      final url = '${Global.GetFollowStatus}?profileId=$profileId&deviceId=$deviceId';

      print("📤 GET STATUS API: $url");

      final response = await apiServices.getApi(url);
      print("✅ STATUS API RESPONSE: $response");

      return FollowResponseModel.fromJson(response);
    } catch (e) {
      print("❌ STATUS API ERROR: $e");
      rethrow;
    }
  }
}