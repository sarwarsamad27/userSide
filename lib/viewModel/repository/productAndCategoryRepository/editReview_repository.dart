import 'dart:developer';

import 'package:user_side/models/ProductAndCategoryModel/editReview_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class EditReviewRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.EditReview;

  Future<EditReviewModel> editReview(
    String reviewId,
    String userId,
    String text,
    String stars,
  ) async {
    try {
      final url = '$apiUrl?reviewId=$reviewId&userId=$userId';
      final response = await apiServices.putApi(url, {
        "text": text,
        "stars": stars,
      });
      print(response);
      log(  response.toString());
      return EditReviewModel.fromJson(response);
    } catch (e) {
      return EditReviewModel(message: "Error: $e", review: null);
    }
  }
}
