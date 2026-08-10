class DeleteFavouriteProductModel {
  bool? success;
  String? message;
  Favourite? favourite;

  DeleteFavouriteProductModel({this.success, this.message, this.favourite});

  DeleteFavouriteProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    favourite = json['favourite'] != null
        ? Favourite.fromJson(json['favourite'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (favourite != null) {
      data['favourite'] = favourite!.toJson();
    }
    return data;
  }
}

class Favourite {
  String? sId;
  String? userId;
  String? productId;
  List<String>? selectedSizes;
  List<String>? selectedColors;
  String? createdAt;
  int? iV;

  Favourite(
      {this.sId,
      this.userId,
      this.productId,
      this.selectedSizes,
      this.selectedColors,
      this.createdAt,
      this.iV});

  Favourite.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    productId = json['productId'];
    selectedSizes = json['selectedSizes'].cast<String>();
    selectedColors = json['selectedColors'].cast<String>();
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['productId'] = productId;
    data['selectedSizes'] = selectedSizes;
    data['selectedColors'] = selectedColors;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}
