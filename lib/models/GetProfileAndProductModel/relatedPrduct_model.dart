class RelatedProductModel {
  String? message;
  int? total;
  int? page;
  int? limit;
  int? totalPages;
  List<RelatedProducts>? relatedProducts;

  RelatedProductModel({
    this.message,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.relatedProducts,
  });

  RelatedProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];

    if (json['relatedProducts'] != null) {
      relatedProducts = List<RelatedProducts>.from(
        json['relatedProducts'].map(
          (x) => RelatedProducts.fromJson(x),
        ),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'relatedProducts':
          relatedProducts?.map((e) => e.toJson()).toList(),
    };
  }
}

class RelatedProducts {
  String? id;
  String? profileId;
  String? categoryId;
  String? name;
  String? description;
  List<String> images;
  int? beforeDiscountPrice;
  int? afterDiscountPrice;
  List<String> size;
  List<String> color;
  String? stock;
  String? createdAt;
  String? updatedAt;
  int? v;

  /// ⭐ Rating
  double averageRating;

  RelatedProducts({
    this.id,
    this.profileId,
    this.categoryId,
    this.name,
    this.description,
    this.images = const [],
    this.beforeDiscountPrice,
    this.afterDiscountPrice,
    this.size = const [],
    this.color = const [],
    this.stock,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.averageRating = 0.0,
  });

  RelatedProducts.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        profileId = json['profileId'],
        categoryId = json['categoryId'],
        name = json['name'],
        description = json['description'],
        images = json['images'] != null
            ? List<String>.from(json['images'])
            : [],
        beforeDiscountPrice = json['beforeDiscountPrice'],
        afterDiscountPrice = json['afterDiscountPrice'],
        size = json['size'] != null
            ? List<String>.from(json['size'])
            : [],
        color = json['color'] != null
            ? List<String>.from(json['color'])
            : [],
        stock = json['stock'],
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'],
        v = json['__v'],
        averageRating = json['averageRating'] != null
            ? (json['averageRating'] as num).toDouble()
            : 0.0;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'profileId': profileId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'images': images,
      'beforeDiscountPrice': beforeDiscountPrice,
      'afterDiscountPrice': afterDiscountPrice,
      'size': size,
      'color': color,
      'stock': stock,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'averageRating': averageRating,
    };
  }
}
