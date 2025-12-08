class GetSingleProductModel {
  String? message;
  Product? product;
  String? profileName;
  String? profileImage;
  String? profileDescription;
  String? profileEmail;
  String? profilephoneNumber;
  List<Reviews>? reviews;

  GetSingleProductModel({
    this.message,
    this.product,
    this.profileName,
    this.profileImage,
    this.profileDescription,
    this.profileEmail,
    this.profilephoneNumber,
    this.reviews,
  });

  GetSingleProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    product = json['product'] != null
        ? new Product.fromJson(json['product'])
        : null;
    profileName = json['profileName'];
    profileImage = json['profileImage'];
    profileDescription = json['profileDescription'];
    profileEmail = json['profileEmail'];
    profilephoneNumber = json['profilephoneNumber'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(new Reviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    data['profileName'] = this.profileName;
    data['profileImage'] = this.profileImage;
    data['profileDescription'] = this.profileDescription;
    data['profileEmail'] = this.profileEmail;
    data['profilephoneNumber'] = this.profilephoneNumber;
    if (this.reviews != null) {
      data['reviews'] = this.reviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
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
  int? stock;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Product({
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
  });

  Product.fromJson(Map<String, dynamic> json) {
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
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['profileId'] = this.profileId;
    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['images'] = this.images;
    data['beforeDiscountPrice'] = this.beforeDiscountPrice;
    data['afterDiscountPrice'] = this.afterDiscountPrice;
    data['discountPercentage'] = this.discountPercentage;
    data['size'] = this.size;
    data['color'] = this.color;
    data['stock'] = this.stock;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Reviews {
  String? sId;
  String? productId;
  UserId? userId;
  int? stars;
  String? text;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? userEmail;
  String? avatar;

  Reviews({
    this.sId,
    this.productId,
    this.userId,
    this.stars,
    this.text,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.userEmail,
    this.avatar,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productId = json['productId'];
    userId = json['userId'] != null
        ? new UserId.fromJson(json['userId'])
        : null;
    stars = json['stars'];
    text = json['text'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    userEmail = json['userEmail'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['productId'] = this.productId;
    if (this.userId != null) {
      data['userId'] = this.userId!.toJson();
    }
    data['stars'] = this.stars;
    data['text'] = this.text;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['userEmail'] = this.userEmail;
    data['avatar'] = this.avatar;
    return data;
  }
}

class UserId {
  String? sId;
  String? email;

  UserId({this.sId, this.email});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['email'] = this.email;
    return data;
  }
}
