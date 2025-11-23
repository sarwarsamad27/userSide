import 'package:user_side/models/auth/updatePassword_model.dart';
import 'package:user_side/network/base_api_services.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class UpdatePasswordRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.UpdatePassword;

  Future<UpdatePasswordModel> updatePassword(String email, String newPassword) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "email": email,
        "newPassword": newPassword,
      });
      print(response);
      return UpdatePasswordModel.fromJson(response);
    } catch (e) {
      return UpdatePasswordModel(message: "Error occurred: $e");
    }
  }
}
