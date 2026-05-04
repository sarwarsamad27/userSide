import 'package:user_side/models/ProductAndCategoryModel/createReview_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class CreateReviewRepository {
  final NetworkApiServices apiService = NetworkApiServices();

  Future<CreateReviewModel> createReview({
    required String productId,
    required String userId,
    required String stars,
    required String text,
    List<String> images = const [],
    String? video,
  }) async {
    try {
      final response = await apiService.postApi(Global.CreateReview, {
        "productId": productId,
        "userId": userId,
        "stars": stars,
        "text": text,
        if (images.isNotEmpty) "images": images,
        if (video != null) "video": video,
      });
      return CreateReviewModel.fromJson(response);
    } catch (e) {
      return CreateReviewModel(message: "Error occurred: $e");
    }
  }
}
