class GetSingleProductModel {
  String? message;
  Product? product;
  String? profileName;
  String? profileImage;
  String? profileDescription;
  String? profileEmail;
  String? profilephoneNumber;
  double? averageRating;
  List<Reviews>? reviews;

  GetSingleProductModel({
    this.message,
    this.product,
    this.profileName,
    this.profileImage,
    this.profileDescription,
    this.profileEmail,
    this.profilephoneNumber,
    this.averageRating,
    this.reviews,
  });

  GetSingleProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    product = json['product'] != null
        ? Product.fromJson(json['product'])
        : null;
    profileName = json['profileName'];
    profileImage = json['profileImage'];
    profileDescription = json['profileDescription'];
    profileEmail = json['profileEmail'];
    profilephoneNumber = json['profilephoneNumber'];
    averageRating = json['averageRating'] != null
        ? (json['averageRating'] as num).toDouble()
        : 0.0;
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['profileName'] = profileName;
    data['profileImage'] = profileImage;
    data['profileDescription'] = profileDescription;
    data['profileEmail'] = profileEmail;
    data['profilephoneNumber'] = profilephoneNumber;
    data['averageRating'] = averageRating;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
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
  String? stock;
  int? quantity;
  String? videoUrl;
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
    this.quantity,
    this.videoUrl,
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
    quantity = json['quantity'];
    videoUrl = json['videoUrl'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
    data['size'] = size;
    data['color'] = color;
    data['stock'] = stock;
    data['quantity'] = quantity;
    data['videoUrl'] = videoUrl;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Reviews {
  String? sId;
  int? stars;
  String? text;
  String? userEmail;
  String? avatar;
  List<String>? images;
  String? video;
  String? replyText;
  String? repliedAt;
  List<String>? replyImages;
  String? replyVideo;
  String? createdAt;
  String? updatedAt;

  Reviews({
    this.sId,
    this.stars,
    this.text,
    this.userEmail,
    this.avatar,
    this.images,
    this.video,
    this.replyText,
    this.repliedAt,
    this.replyImages,
    this.replyVideo,
    this.createdAt,
    this.updatedAt,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    stars = json['stars'];
    text = json['text'];
    userEmail = json['userEmail'];
    avatar = json['avatar'];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    video = json['video'];
    replyText = json['replyText'];
    repliedAt = json['repliedAt'];
    replyImages = json['replyImages'] != null ? List<String>.from(json['replyImages']) : [];
    replyVideo = json['replyVideo'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['stars'] = stars;
    data['text'] = text;
    data['userEmail'] = userEmail;
    data['avatar'] = avatar;
    data['images'] = images;
    data['video'] = video;
    data['replyText'] = replyText;
    data['repliedAt'] = repliedAt;
    data['replyImages'] = replyImages;
    data['replyVideo'] = replyVideo;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
