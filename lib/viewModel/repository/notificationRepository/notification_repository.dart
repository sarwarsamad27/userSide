import 'package:user_side/models/notification_services/notificationModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';

class NotificationRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

 Future<BuyerNotificationResponse> fetchNotifications() async {
  try {
    final userId = await LocalStorage.getUserId();
    final deviceId = await LocalStorage.getOrCreateDeviceId();
  
    final url = (userId != null && userId.isNotEmpty)
        ? "${Global.getBuyerNotifications}?userId=$userId"
        : "${Global.getBuyerNotifications}?deviceId=$deviceId";

    final response = await apiServices.getApi(url);
    return BuyerNotificationResponse.fromJson(response);
  } catch (e) {
    return BuyerNotificationResponse(
      message: "Error: $e",
      unreadCount: 0,
      notifications: [],
    );
  }
}

 Future<bool> markRead(String notificationId) async {
  try {
    final response = await apiServices.putApiNoAuth(
      Global.markNotificationRead,
      {"notificationId": notificationId},
    );

    // support multiple API formats
    if (response == null) return false;
    if (response is Map && response['success'] == true) return true;
    if (response is Map && response['message'] != null) return true;

    return false;
  } catch (_) {
    return false;
  }
}
}
