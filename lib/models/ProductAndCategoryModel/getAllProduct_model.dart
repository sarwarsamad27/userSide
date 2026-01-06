class GetAllProductModel {
  bool? success;
  String? message;
  Data? data;

  GetAllProductModel({this.success, this.message, this.data});

  GetAllProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
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
        products!.add(new Products.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
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
    createdAt = json['createdAt'];
    averageRating = json['averageRating'] != null
        ? (json['averageRating'] as num).toDouble()
        : 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['categoryId'] = this.categoryId;
    data['profileId'] = this.profileId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['images'] = this.images;
    data['beforeDiscountPrice'] = this.beforeDiscountPrice;
    data['afterDiscountPrice'] = this.afterDiscountPrice;
    data['discountAmount'] = this.discountAmount;
    data['discountPercentage'] = this.discountPercentage;
    data['size'] = this.size;
    data['color'] = this.color;
    data['stock'] = this.stock;
    data['averageRating'] = this.averageRating;
    data['createdAt'] = this.createdAt;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalPages'] = this.totalPages;
    data['hasMore'] = this.hasMore;
    return data;
  }
}
