class GetAllCategoryProfileWiseModel {
  String? message;
  int? total;
  List<Categories> categories;

  GetAllCategoryProfileWiseModel({
    this.message,
    this.total,
    List<Categories>? categories,
  }) : categories = categories ?? [];

  GetAllCategoryProfileWiseModel.fromJson(Map<String, dynamic> json)
    : categories = [] {
    message = json['message'];
    total = json['total'];
    if (json['categories'] != null) {
      json['categories'].forEach((v) {
        categories.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['total'] = total;
    data['categories'] = categories.map((v) => v.toJson()).toList();
    return data;
  }
}

class Categories {
  String? sId;
  String? profileId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Categories(
      {this.sId,
      this.profileId,
      this.name,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Categories.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    profileId = json['profileId'];
    name = json['name'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['profileId'] = profileId;
    data['name'] = name;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
