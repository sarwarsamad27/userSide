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
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Review({
    this.productId,
    this.userId,
    this.stars,
    this.text,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Review.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    userId = json['userId'] != null
        ? new UserId.fromJson(json['userId'])
        : null;
    stars = json['stars'];
    text = json['text'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    if (this.userId != null) {
      data['userId'] = this.userId!.toJson();
    }
    data['stars'] = this.stars;
    data['text'] = this.text;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
