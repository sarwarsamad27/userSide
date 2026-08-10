class GetAllProductModel {
  bool? success;
  String? message;
  Data? data;

  GetAllProductModel({this.success, this.message, this.data});

  GetAllProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Products>? products;
  Pagination? pagination;

  Data({this.products, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Products {
  String? productId;
  String? categoryId;
  String? profileId;
  String? name;
  String? description;
  List<String>? images;
  int? beforeDiscountPrice;
  int? afterDiscountPrice;
  int? discountAmount;
  int? discountPercentage;
  List<String>? size;
  List<String>? color;
  String? stock;
  int? quantity;
  double? averageRating; // ⭐ NEW
  String? createdAt;

  Products({
    this.productId,
    this.categoryId,
    this.profileId,
    this.name,
    this.description,
    this.images,
    this.beforeDiscountPrice,
    this.afterDiscountPrice,
    this.discountAmount,
    this.discountPercentage,
    this.size,
    this.color,
    this.stock,
    this.quantity,
    this.averageRating,
    this.createdAt,
  });

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    categoryId = json['categoryId'];
    profileId = json['profileId'];
    name = json['name'];
    description = json['description'];
    images = json['images'].cast<String>();
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    discountAmount = json['discountAmount'];
    discountPercentage = json['discountPercentage'];
    size = json['size'].cast<String>();
    color = json['color'].cast<String>();
    stock = json['stock'];
    quantity = json['quantity'];
    createdAt = json['createdAt'];
    averageRating = json['averageRating'] != null
        ? (json['averageRating'] as num).toDouble()
        : 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['categoryId'] = categoryId;
    data['profileId'] = profileId;
    data['name'] = name;
    data['description'] = description;
    data['images'] = images;
    data['beforeDiscountPrice'] = beforeDiscountPrice;
    data['afterDiscountPrice'] = afterDiscountPrice;
    data['discountAmount'] = discountAmount;
    data['discountPercentage'] = discountPercentage;
    data['size'] = size;
    data['color'] = color;
    data['stock'] = stock;
    data['quantity'] = quantity;
    data['averageRating'] = averageRating;
    data['createdAt'] = createdAt;
    return data;
  }
}

class Pagination {
  int? totalCount;
  int? page;
  int? limit;
  int? totalPages;
  bool? hasMore;

  Pagination({
    this.totalCount,
    this.page,
    this.limit,
    this.totalPages,
    this.hasMore,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    hasMore = json['hasMore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['hasMore'] = hasMore;
    return data;
  }
}
