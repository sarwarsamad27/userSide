
import 'package:user_side/models/GetProfileAndProductModel/getAllProfile_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetAllProfileRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetAllProfile;

  Future<GetAllProfileModel> getAllProfile() async {
    try {
      final response = await apiServices.getApi(apiUrl);
      return GetAllProfileModel.fromJson(response);
    } catch (e) {
      return GetAllProfileModel(message: "Error: $e", profiles: []);
    }
  }
}
