import 'package:user_side/models/GetProfileAndProductModel/productSharedModel.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';

class ProductShareRepository {
  final NetworkApiServices _api = NetworkApiServices();

  Future<ProductShareModel> getShareLink({
    required String productId,
    required String profileId,
  }) async {
    final url =
        "${Global.ShareLink}?productId=$productId&profileId=$profileId";

    final response = await _api.getApi(url);
    return ProductShareModel.fromJson(response);
  }
}
