import 'dart:developer';

import 'package:user_side/models/ProductAndCategoryModel/popularCategory_model.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class GetPopularCategoryRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetPopularCategory;

  Future<PopularCategoryModel> getPopularCategory() async {
    try {
      final response =
          await apiServices.cachedGetApi('popular_categories', apiUrl);
      log("repo $response");
      return PopularCategoryModel.fromJson(response);
    } catch (e) {
      log("Error in Popular Category Repository: $e");
      return PopularCategoryModel(success: false, categories: []);
    }
  }
}
