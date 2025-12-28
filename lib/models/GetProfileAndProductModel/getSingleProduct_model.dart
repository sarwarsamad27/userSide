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
  int? stars;
  String? text;
  String? userEmail;
  String? avatar;
  String? replyText;
  String? repliedAt;
  String? createdAt;
  String? updatedAt;

  Reviews({
    this.sId,
    this.stars,
    this.text,
    this.userEmail,
    this.avatar,
    this.replyText,
    this.repliedAt,
    this.createdAt,
    this.updatedAt,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    stars = json['stars'];
    text = json['text'];
    userEmail = json['userEmail'];
    avatar = json['avatar'];
    replyText = json['replyText'];
    repliedAt = json['repliedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['stars'] = this.stars;
    data['text'] = this.text;
    data['userEmail'] = this.userEmail;
    data['avatar'] = this.avatar;
    data['replyText'] = this.replyText;
    data['repliedAt'] = this.repliedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
