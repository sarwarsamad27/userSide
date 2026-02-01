import 'package:user_side/models/chatModel/chatThreadModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class ChatThreadRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<ChatThreadListModel> getChatThreads(String buyerId) async {
    try {
      print("📩 Fetching chat threads for buyerId: $buyerId");

      final response = await apiServices.getApi(
        "${Global.ChatThreads}?buyerId=$buyerId",
      );

      print("✅ Chat threads response: $response");

      return ChatThreadListModel.fromJson(response);
    } catch (e) {
      print("❌ Error fetching chat threads: $e");
      return ChatThreadListModel(
        success: false,
        message: "Error: $e",
        threads: [],
      );
    }
  }
}