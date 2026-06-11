import 'package:user_side/models/aiAssistantModel/AiAssistantModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class AiAssistantRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<AiAssistantModel> sendMessage({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    try {
      final response = await _apiService.postApi(Global.BuyerAiAssistant, {
        'message': message,
        'history': history,
      });

      if (response['code_status'] == false) {
        return AiAssistantModel(
          message: response['message'] ?? 'Failed to get a response',
        );
      }

      return AiAssistantModel.fromJson(response);
    } catch (e) {
      return AiAssistantModel(message: 'Error: $e');
    }
  }
}
