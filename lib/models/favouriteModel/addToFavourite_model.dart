class AddToFavouriteModel {
  bool? success;
  String? message;
  Favourite? favourite;

  AddToFavouriteModel({this.success, this.message, this.favourite});

  AddToFavouriteModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    favourite = json['favourite'] != null
        ? Favourite.fromJson(json['favourite'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    if (favourite != null) data['favourite'] = favourite!.toJson();
    return data;
  }
}

class Favourite {
  String? userId;
  String? productId;
  List<String>? selectedSizes;
  List<String>? selectedColors;
  String? sId;
  String? createdAt;
  int? iV;

  Favourite({
    this.userId,
    this.productId,
    this.selectedSizes,
    this.selectedColors,
    this.sId,
    this.createdAt,
    this.iV,
  });

  Favourite.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    productId = json['productId'];
    selectedSizes = json['selectedSizes'] != null
        ? List<String>.from(json['selectedSizes'])
        : [];
    selectedColors = json['selectedColors'] != null
        ? List<String>.from(json['selectedColors'])
        : [];
    sId = json['_id'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'selectedSizes': selectedSizes,
      'selectedColors': selectedColors,
      '_id': sId,
      'createdAt': createdAt,
      '__v': iV,
    };
  }
}
