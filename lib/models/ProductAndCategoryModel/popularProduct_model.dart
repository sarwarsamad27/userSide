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
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalProducts'] = this.totalProducts;
    data['totalPages'] = this.totalPages;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
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

  Products(
      {this.productId,
      this.profileId,
      this.categoryId,
      this.name,
      this.image,
      this.beforeDiscountPrice,
      this.afterDiscountPrice,
      this.discountPercentage,
      this.discountAmount});

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['profileId'] = this.profileId;
    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['beforeDiscountPrice'] = this.beforeDiscountPrice;
    data['afterDiscountPrice'] = this.afterDiscountPrice;
    data['discountPercentage'] = this.discountPercentage;
    data['discountAmount'] = this.discountAmount;
    return data;
  }
}
