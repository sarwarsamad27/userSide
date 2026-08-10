class EditReviewModel {
  bool? success;
  String? message;
  EditReview? review;

  EditReviewModel({this.success, this.message, this.review});

  EditReviewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    review =
        json['review'] != null ? EditReview.fromJson(json['review']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (review != null) {
      data['review'] = review!.toJson();
    }
    return data;
  }
}

class EditReview {
  String? sId;
  String? productId;
  UserId? userId;
  int? stars;
  String? text;
  String? createdAt;
  String? updatedAt;
  int? iV;

  EditReview(
      {this.sId,
      this.productId,
      this.userId,
      this.stars,
      this.text,
      this.createdAt,
      this.updatedAt,
      this.iV});

  EditReview.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productId = json['productId'];
    userId =
        json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    stars = json['stars'];
    text = json['text'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['productId'] = productId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['stars'] = stars;
    data['text'] = text;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    return data;
  }
}
