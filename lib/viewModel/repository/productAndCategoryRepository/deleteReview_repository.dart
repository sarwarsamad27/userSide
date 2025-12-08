import 'dart:developer';

import 'package:user_side/models/ProductAndCategoryModel/deleteReview_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class DeleteReviewRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.DeleteReview;

  Future<DeleteReviewModel> editReview(String reviewId, String userId) async {
    try {
      final url = '$apiUrl?reviewId=$reviewId&userId=$userId';
      final response = await apiServices.deleteApi(url);
      print(response);
      log(response.toString());
      return DeleteReviewModel.fromJson(response);
    } catch (e) {
      return DeleteReviewModel(message: "Error: $e", success: false);
    }
  }
}
