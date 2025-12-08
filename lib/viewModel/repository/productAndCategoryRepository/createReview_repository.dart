import 'package:user_side/models/ProductAndCategoryModel/createReview_model.dart';
import 'package:user_side/network/base_api_services.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class CreateReviewRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.CreateReview;

  Future<CreateReviewModel> createReview(String productId, String userId,String stars, String text) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "productId": productId,
        "userId": userId,
        "stars": stars,
        "text": text,
      });
      print(response);
      return CreateReviewModel.fromJson(response);
    } catch (e) {
      return CreateReviewModel(message: "Error occurred: $e");
    }
  }
}
