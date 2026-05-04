class CreateReviewModel {
  bool? success;
  String? message;
  Review? review;

  CreateReviewModel({this.success, this.message, this.review});

  CreateReviewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    review = json['review'] != null
        ? new Review.fromJson(json['review'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.review != null) {
      data['review'] = this.review!.toJson();
    }
    return data;
  }
}

class Review {
  String? productId;
  UserId? userId;
  int? stars;
  String? text;
  List<String>? images;
  String? video;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Review({
    this.productId,
    this.userId,
    this.stars,
    this.text,
    this.images,
    this.video,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Review.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    stars = json['stars'];
    text = json['text'];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    video = json['video'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    if (userId != null) data['userId'] = userId!.toJson();
    data['stars'] = stars;
    data['text'] = text;
    data['images'] = images;
    data['video'] = video;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
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
