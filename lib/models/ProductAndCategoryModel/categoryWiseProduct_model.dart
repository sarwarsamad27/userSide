class CategoryWiseProductModel {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  List<Data>? data;

  CategoryWiseProductModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.data,
  });

  CategoryWiseProductModel.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    data['totalPages'] = totalPages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
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
  int? quantity;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<Reviews>? reviews;
  double? averageRating;

  Data({
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
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.reviews,
    this.averageRating,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    profileId = json['profileId'];
    categoryId = json['categoryId'];
    name = json['name'];
    description = json['description'];
    images = json['images'].cast<String>();
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    discountPercentage = json['discountPercentage'];
    size = json['size'].cast<String>();
    color = json['color'].cast<String>();
    stock = json['stock'];
    quantity = json['quantity'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
    averageRating = json['averageRating'] != null
        ? (json['averageRating'] as num).toDouble()
        : 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    data['quantity'] = quantity;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    data['averageRating'] = averageRating;
    return data;
  }
}

class Reviews {
  String? sId;
  String? productId;
  String? userId;
  int? stars;
  String? text;
  Reply? reply;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Reviews({
    this.sId,
    this.productId,
    this.userId,
    this.stars,
    this.text,
    this.reply,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productId = json['productId'];
    userId = json['userId'];
    stars = json['stars'];
    text = json['text'];
    reply = json['reply'] != null ? Reply.fromJson(json['reply']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['productId'] = productId;
    data['userId'] = userId;
    data['stars'] = stars;
    data['text'] = text;
    if (reply != null) {
      data['reply'] = reply!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Reply {
  String? text;
  String? repliedAt;

  Reply({this.text, this.repliedAt});

  Reply.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    repliedAt = json['repliedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['repliedAt'] = repliedAt;
    return data;
  }
}
