import 'package:user_side/models/courier/leopards_tracking_model.dart';
import 'package:user_side/network/base_api_services.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class LeopardsTrackingRepository {
  final BaseApiServices apiService = NetworkApiServices();

  Future<List<LeopardsTrackingModel>> trackParcel(String trackNumber) async {
    try {
      final response = await apiService.getApi(
        Global.leopardsTrack(trackNumber),
      );
      if (response != null && response['status'] == 1) {
        final List data = response['data'] ?? [];
        return data.map((e) => LeopardsTrackingModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("❌ LeopardsTrackingRepository Error: $e");
      return [];
    }
  }
}
