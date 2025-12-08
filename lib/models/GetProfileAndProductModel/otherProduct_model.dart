class OtherProductModel {
  String? message;
  int? total;
  int? page;
  int? limit;
  int? totalPages;
  List<OtherProducts>? otherProducts;

  OtherProductModel(
      {this.message,
      this.total,
      this.page,
      this.limit,
      this.totalPages,
      this.otherProducts});

  OtherProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    if (json['otherProducts'] != null) {
      otherProducts = <OtherProducts>[];
      json['otherProducts'].forEach((v) {
        otherProducts!.add(new OtherProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['total'] = this.total;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalPages'] = this.totalPages;
    if (this.otherProducts != null) {
      data['otherProducts'] =
          this.otherProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OtherProducts {
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

  OtherProducts(
      {this.sId,
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
      this.iV});

  OtherProducts.fromJson(Map<String, dynamic> json) {
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
