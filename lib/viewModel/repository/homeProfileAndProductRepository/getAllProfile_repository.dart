import 'package:user_side/models/GetProfileAndProductModel/getAllProfile_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class GetAllProfileRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetAllProfile;

  Future<GetAllProfileModel> getAllProfile({
    
    required int page,
    required int limit,
  }) async {
    try {
      final deviceId = await LocalStorage.getOrCreateDeviceId();
      final response = await apiServices.getApi(
        "$apiUrl?deviceId=$deviceId&page=$page&limit=$limit",
      );
      return GetAllProfileModel.fromJson(response);
    } catch (e) {
      return GetAllProfileModel(message: "Error: $e", profiles: []);
    }
  }
}
