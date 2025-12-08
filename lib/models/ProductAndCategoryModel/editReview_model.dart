class EditReviewModel {
  bool? success;
  String? message;
  EditReview? review;

  EditReviewModel({this.success, this.message, this.review});

  EditReviewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    review =
        json['review'] != null ? new EditReview.fromJson(json['review']) : null;
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
        json['userId'] != null ? new UserId.fromJson(json['userId']) : null;
    stars = json['stars'];
    text = json['text'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
