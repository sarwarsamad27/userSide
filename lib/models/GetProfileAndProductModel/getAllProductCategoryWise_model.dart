class GetAllProductCategoryWiseModel {
  String? message;
  int? total;
  List<Products>? products;

  GetAllProductCategoryWiseModel({this.message, this.total, this.products});

  GetAllProductCategoryWiseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    total = json['total'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['total'] = total;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? sId;
  String? profileId;
  String? categoryId;
  String? name;
  String? description;
  List<String>? images;
  int? beforeDiscountPrice;
  int? afterDiscountPrice;
  int? discountPercentage;
  List<String>? size;
  List<String>? color;
  String? stock;
  String? createdAt;
  String? updatedAt;
  int? iV;

  // ✅ ADDED
  double? averageRating;

  Products({
    this.sId,
    this.profileId,
    this.categoryId,
    this.name,
    this.description,
    this.images,
    this.beforeDiscountPrice,
    this.afterDiscountPrice,
    this.discountPercentage,
    this.size,
    this.color,
    this.stock,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.averageRating, // ✅
  });

  Products.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    profileId = json['profileId'];
    categoryId = json['categoryId'];
    name = json['name'];
    description = json['description'];
    images = json['images']?.cast<String>();
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    discountPercentage = json['discountPercentage'];
    size = json['size']?.cast<String>();
    color = json['color']?.cast<String>();
    stock = json['stock'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

    // ✅ SAFE
    averageRating = json['averageRating'] != null
        ? (json['averageRating'] as num).toDouble()
        : 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['profileId'] = profileId;
    data['categoryId'] = categoryId;
    data['name'] = name;
    data['description'] = description;
    data['images'] = images;
    data['beforeDiscountPrice'] = beforeDiscountPrice;
    data['afterDiscountPrice'] = afterDiscountPrice;
    data['discountPercentage'] = discountPercentage;
    data['size'] = size;
    data['color'] = color;
    data['stock'] = stock;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;

    // ✅ ADDED
    data['averageRating'] = averageRating;
    return data;
  }
}
