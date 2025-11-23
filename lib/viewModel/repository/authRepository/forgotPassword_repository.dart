
import 'package:user_side/models/auth/forgotPassword_model.dart';
import 'package:user_side/network/base_api_services.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class ForgotPasswordRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.ForgotPassword;

  Future<ForgotPasswordModel> forgotPassword(String email) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "email": email,
      });
      print(response);
      return ForgotPasswordModel.fromJson(response);
    } catch (e) {
      return ForgotPasswordModel(message: "Error occurred: $e");
    }
  }
}
