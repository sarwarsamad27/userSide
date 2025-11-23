import 'package:user_side/models/auth/signUp_model.dart';
import 'package:user_side/network/base_api_services.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class SignUpRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.SignUp;

  Future<SignUpModel> signUp(String email, String password) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "email": email,
        "password": password,
      });

      return SignUpModel.fromJson(response);
    } catch (e) {
      return SignUpModel(message: "Error occurred: $e");
    }
  }
}
