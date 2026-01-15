import 'package:user_side/models/auth/googleLogin_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GoogleLoginRepository {
  final NetworkApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.GoogleLogin;

  Future<GoogleLoginModel> googleLogin(String idToken) async {
    try {
      // ✅ No Authorization header for Google login
      final response = await apiService.postApiNoAuth(apiUrl, {"idToken": idToken});
      print(response);

      // If server error wrapper returned
      if (response['code_status'] == false) {
        return GoogleLoginModel(message: response['message'] ?? 'Login failed');
      }

      return GoogleLoginModel.fromJson(response);
    } catch (e) {
      return GoogleLoginModel(message: "Error occurred: $e");
    }
  }
}
