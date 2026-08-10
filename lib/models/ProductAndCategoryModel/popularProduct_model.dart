class PopularProductModel {
  bool? success;
  int? page;
  int? limit;
  int? totalProducts;
  int? totalPages;
  List<Products>? products;

  PopularProductModel(
      {this.success,
      this.page,
      this.limit,
      this.totalProducts,
      this.totalPages,
      this.products});

  PopularProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    page = json['page'];
    limit = json['limit'];
    totalProducts = json['totalProducts'];
    totalPages = json['totalPages'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['page'] = page;
    data['limit'] = limit;
    data['totalProducts'] = totalProducts;
    data['totalPages'] = totalPages;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? productId;
  String? profileId;
  String? categoryId;
  String? name;
  String? image;
  int? beforeDiscountPrice;
  int? afterDiscountPrice;
  int? discountPercentage;
  int? discountAmount;
  int? quantity;

  Products(
      {this.productId,
      this.profileId,
      this.categoryId,
      this.name,
      this.image,
      this.beforeDiscountPrice,
      this.afterDiscountPrice,
      this.discountPercentage,
      this.discountAmount,
      this.quantity});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    profileId = json['profileId'];
    categoryId = json['categoryId'];
    name = json['name'];
    image = json['image'];
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    discountPercentage = json['discountPercentage'];
    discountAmount = json['discountAmount'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['profileId'] = profileId;
    data['categoryId'] = categoryId;
    data['name'] = name;
    data['image'] = image;
    data['beforeDiscountPrice'] = beforeDiscountPrice;
    data['afterDiscountPrice'] = afterDiscountPrice;
    data['discountPercentage'] = discountPercentage;
    data['discountAmount'] = discountAmount;
    data['quantity'] = quantity;
    return data;
  }
}
